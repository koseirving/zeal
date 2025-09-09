import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import axios from 'axios';

// Initialize Firebase Admin SDK
admin.initializeApp();

// Get configuration
const config = functions.config();

interface ReceiptValidationRequest {
  receiptData: string;
  productId: string;
  transactionId: string;
  userId?: string;
}

interface AppleReceiptResponse {
  status: number;
  receipt?: any;
  'is-retryable'?: boolean;
  environment?: string;
}

// Apple's receipt validation URLs
const APPLE_PRODUCTION_URL = 'https://buy.itunes.apple.com/verifyReceipt';
const APPLE_SANDBOX_URL = 'https://sandbox.itunes.apple.com/verifyReceipt';

// Status codes from Apple
const APPLE_STATUS = {
  SUCCESS: 0,
  SANDBOX_RECEIPT_ON_PRODUCTION: 21007,
  PRODUCTION_RECEIPT_ON_SANDBOX: 21008,
};

/**
 * Verify iOS receipt with Apple's servers
 * Automatically handles production/sandbox environment switching
 */
export const verifyReceipt = functions.https.onCall(
  async (data: ReceiptValidationRequest, context) => {
    // Log the request for debugging
    console.log('Receipt verification requested', {
      productId: data.productId,
      transactionId: data.transactionId,
      userId: data.userId || context?.auth?.uid || 'anonymous',
      hasReceipt: !!data.receiptData,
      receiptDataLength: data.receiptData?.length || 0,
    });

    // Validate input
    if (!data.receiptData) {
      console.error('No receipt data provided');
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Receipt data is required'
      );
    }
    
    // Ensure receipt data is properly formatted (base64)
    let formattedReceiptData = data.receiptData;
    
    // If the receipt data doesn't look like base64, try to encode it
    if (!isBase64(formattedReceiptData)) {
      console.log('Receipt data appears to not be base64, encoding it');
      formattedReceiptData = Buffer.from(formattedReceiptData).toString('base64');
    }

    if (!data.productId) {
      console.error('No product ID provided');
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Product ID is required'
      );
    }

    try {
      // First, try production environment
      console.log('Attempting production environment validation...');
      let response = await validateWithApple(
        formattedReceiptData,
        APPLE_PRODUCTION_URL
      );

      // If we get sandbox receipt error (21007), retry with sandbox URL
      if (response.status === APPLE_STATUS.SANDBOX_RECEIPT_ON_PRODUCTION) {
        console.log('Receipt is from sandbox, retrying with sandbox URL...');
        response = await validateWithApple(
          formattedReceiptData,
          APPLE_SANDBOX_URL
        );
      }

      // Check if validation was successful
      if (response.status !== APPLE_STATUS.SUCCESS) {
        console.error('Receipt validation failed with status:', response.status);
        throw new functions.https.HttpsError(
          'invalid-argument',
          `Receipt validation failed with status ${response.status}`
        );
      }

      // Receipt is valid, process the purchase
      console.log('Receipt validated successfully');
      
      // Extract receipt info
      const receipt = response.receipt;
      const environment = response.environment || 'Production';
      
      // Verify the product ID matches
      const inAppPurchases = receipt.in_app || [];
      const matchingPurchase = inAppPurchases.find(
        (purchase: any) => purchase.product_id === data.productId
      );

      if (!matchingPurchase) {
        console.error('Product ID not found in receipt', {
          expectedProductId: data.productId,
          receiptProducts: inAppPurchases.map((p: any) => p.product_id),
        });
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Product ID does not match receipt'
        );
      }

      // Save the validated purchase to Firestore
      const userId = data.userId || context?.auth?.uid || 'anonymous';
      const purchaseData = {
        userId,
        productId: data.productId,
        transactionId: data.transactionId,
        appleTransactionId: matchingPurchase.transaction_id,
        purchaseDate: matchingPurchase.purchase_date_ms
          ? new Date(parseInt(matchingPurchase.purchase_date_ms))
          : admin.firestore.FieldValue.serverTimestamp(),
        environment,
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        receiptData: {
          bundleId: receipt.bundle_id,
          applicationVersion: receipt.application_version,
          originalPurchaseDate: receipt.original_purchase_date_ms
            ? new Date(parseInt(receipt.original_purchase_date_ms))
            : null,
        },
      };

      // Store in Firestore
      await admin
        .firestore()
        .collection('verified_purchases')
        .doc(data.transactionId)
        .set(purchaseData);

      console.log('Purchase recorded successfully', {
        transactionId: data.transactionId,
        environment,
      });

      // Return success response
      return {
        success: true,
        environment,
        transactionId: matchingPurchase.transaction_id,
        message: 'Receipt validated and purchase recorded successfully',
      };
    } catch (error: any) {
      // If it's already an HttpsError, re-throw it
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      // Log unexpected errors
      console.error('Unexpected error during receipt validation:', error);
      
      // Return a generic error
      throw new functions.https.HttpsError(
        'internal',
        'An error occurred during receipt validation',
        error.message
      );
    }
  }
);

/**
 * Helper function to validate receipt with Apple's servers
 */
async function validateWithApple(
  receiptData: string,
  url: string
): Promise<AppleReceiptResponse> {
  try {
    // Build request body with optional shared secret
    const requestBody: any = {
      'receipt-data': receiptData,
      'exclude-old-transactions': true,
    };
    
    // Add shared secret if configured
    const sharedSecret = config.appstore?.shared_secret || process.env.APP_STORE_SHARED_SECRET;
    if (sharedSecret) {
      requestBody['password'] = sharedSecret;
      console.log('Using shared secret for validation');
    }

    console.log(`Validating with Apple at: ${url}`);
    
    const response = await axios.post<AppleReceiptResponse>(
      url,
      requestBody,
      {
        timeout: 30000, // 30 second timeout
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    console.log(`Apple response status: ${response.data.status}`);
    
    return response.data;
  } catch (error: any) {
    console.error('Error calling Apple validation API:', error.message);
    
    if (error.response) {
      console.error('Response data:', error.response.data);
      console.error('Response status:', error.response.status);
    }
    
    throw new functions.https.HttpsError(
      'unavailable',
      'Failed to connect to Apple validation servers'
    );
  }
}

/**
 * Helper function to check if a string is base64 encoded
 */
function isBase64(str: string): boolean {
  if (!str || str.length === 0) return false;
  
  // Check if string contains only base64 characters
  const base64Regex = /^[A-Za-z0-9+/]*={0,2}$/;
  
  // Also check if the string length is a multiple of 4
  return base64Regex.test(str) && str.length % 4 === 0;
}

/**
 * Health check endpoint for monitoring
 */
export const healthCheck = functions.https.onRequest((req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'receipt-validation',
  });
});