# Firebase Functions for Zeal App

## Overview

This directory contains Firebase Cloud Functions for the Zeal app, primarily for handling In-App Purchase receipt validation with Apple's servers.

## Setup

### 1. Install dependencies

```bash
cd functions
npm install
```

### 2. Configure environment variables (optional)

Copy `.env.example` to `.env` and add your App Store Shared Secret:

```bash
cp .env.example .env
```

Edit `.env` and add your shared secret from App Store Connect.

**Note:** The shared secret is optional but recommended for additional security.

### 3. Build the functions

```bash
npm run build
```

## Deployment

### Deploy to production

```bash
npm run deploy
```

Or from the project root:

```bash
firebase deploy --only functions
```

### Deploy a specific function

```bash
firebase deploy --only functions:verifyReceipt
```

## Functions

### `verifyReceipt`

Validates iOS receipt data with Apple's servers.

**Features:**
- Automatically handles production/sandbox environment switching
- Validates receipt with Apple's servers
- Stores verified purchases in Firestore
- Returns verification status to client

**Request:**
```javascript
{
  receiptData: string,    // Base64 encoded receipt
  productId: string,      // Product ID to verify
  transactionId: string,  // Transaction ID
  userId?: string         // Optional user ID
}
```

**Response:**
```javascript
{
  success: boolean,
  environment: string,    // "Production" or "Sandbox"
  transactionId: string,
  message: string
}
```

### `healthCheck`

Simple health check endpoint for monitoring.

**URL:** `https://[region]-[project].cloudfunctions.net/healthCheck`

## Testing

### Local testing with emulator

```bash
npm run serve
```

This will start the Firebase emulator for functions.

### View logs

```bash
npm run logs
```

## Error Handling

The receipt validation function handles the following scenarios:

1. **Invalid receipt data** - Returns error if receipt is missing or invalid
2. **Sandbox receipt on production** - Automatically retries with sandbox URL
3. **Product ID mismatch** - Returns error if product ID doesn't match receipt
4. **Network errors** - Returns appropriate error message

## Security

- Receipt validation is performed server-side to prevent tampering
- Optional shared secret can be used for additional security
- All purchases are logged to Firestore for audit trail

## Troubleshooting

### Function deployment fails

1. Ensure you're logged in to Firebase:
   ```bash
   firebase login
   ```

2. Check your project is correctly set:
   ```bash
   firebase use zeal-product
   ```

### Receipt validation fails

1. Check the function logs:
   ```bash
   firebase functions:log
   ```

2. Verify the product ID matches what's configured in App Store Connect

3. Ensure the app is using the correct environment (production vs sandbox)

### Environment variables not working

Set environment variables for production:
```bash
firebase functions:config:set appstore.shared_secret="your_secret_here"
```

Then redeploy the functions.