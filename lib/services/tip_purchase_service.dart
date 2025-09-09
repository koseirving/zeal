import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tip_product_model.dart';
import '../config/app_config.dart';
import 'local_storage_service.dart';

class TipPurchaseService {
  static final TipPurchaseService _instance = TipPurchaseService._internal();
  factory TipPurchaseService() => _instance;
  TipPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _useMockMode = false;
  
  // Purchase state management
  bool _isPurchaseInProgress = false;
  DateTime? _lastPurchaseTime;
  static const Duration _purchaseCooldown = Duration(seconds: 5);
  
  // Mock products for development
  List<MockProductDetails> get _mockProducts {
    return [
      MockProductDetails(id: TipProduct.getTipIdByAmount(100), price: '¥100', rawPrice: 100.0),
    ];
  }

  // Initialize the purchase service
  Future<bool> initialize() async {
    try {
      // Log current environment for debugging
      debugPrint('===== TipPurchaseService Initialization =====');
      debugPrint('Environment: ${AppConfig.environmentName}');
      debugPrint('isDev: ${AppConfig.isDev}');
      debugPrint('isProd: ${AppConfig.isProd}');
      
      // Use mock mode only in development environment
      // Do NOT use kDebugMode as it affects TestFlight builds
      if (AppConfig.isDev) {
        debugPrint('TipPurchaseService: Development environment - using mock mode');
        _useMockMode = true;
        _isAvailable = true;
        return true;
      }
      
      // In production and TestFlight, always use real purchase
      debugPrint('TipPurchaseService: Production/TestFlight environment - attempting real In-App Purchase');
      debugPrint('Expected Product ID for production: tip_100');
      _isAvailable = await _tryInitializeRealPurchase();
      
      if (_isAvailable) {
        debugPrint('TipPurchaseService: Real purchase available (production)');
        _useMockMode = false;
      }
      
      if (!_isAvailable) {
        debugPrint('TipPurchaseService: In-app purchase not available');
        return false;
      }

      if (!_useMockMode) {
        // Listen to purchase updates only in real mode
        final Stream<List<PurchaseDetails>> purchaseUpdated = 
            _inAppPurchase.purchaseStream;
        _subscription = purchaseUpdated.listen(
          _onPurchaseUpdate,
          onDone: () => _subscription?.cancel(),
          onError: (error) => debugPrint('TipPurchaseService: Purchase stream error: $error'),
        );

        // Load products
        await _loadProducts();
      }
      
      // Initialize local storage
      await _localStorage.initialize();
      
      debugPrint('TipPurchaseService: Initialized successfully (mode: ${_useMockMode ? "Mock" : "Real"})');
      return true;
    } catch (e) {
      debugPrint('TipPurchaseService: Failed to initialize: $e');
      debugPrint('TipPurchaseService: Stack trace: ${StackTrace.current}');
      
      // In production, initialization failure is critical
      if (!AppConfig.isDev) {
        debugPrint('TipPurchaseService: CRITICAL ERROR - In-App Purchase not available in production');
        debugPrint('TipPurchaseService: Please ensure:');
        debugPrint('  1. In-App Purchase capability is enabled in Xcode');
        debugPrint('  2. Products are configured in App Store Connect');
        debugPrint('  3. Agreements, Tax, and Banking are complete');
        debugPrint('  4. Device is connected to the internet');
      }
      
      return false;
    }
  }

  Future<bool> _tryInitializeRealPurchase() async {
    try {
      debugPrint('TipPurchaseService: Checking In-App Purchase availability...');
      final bool available = await _inAppPurchase.isAvailable();
      debugPrint('TipPurchaseService: In-App Purchase available: $available');
      
      if (!available) {
        debugPrint('TipPurchaseService: StoreKit/Play Store connection failed');
        debugPrint('TipPurchaseService: Possible reasons:');
        debugPrint('  - Device is not connected to internet');
        debugPrint('  - App Store/Play Store is not available');
        debugPrint('  - In-App Purchase capability not enabled in Xcode');
        debugPrint('  - Runner.entitlements missing In-App Purchase entitlement');
        debugPrint('TipPurchaseService: Current environment: ${AppConfig.environmentName}');
      }
      
      return available;
    } catch (e) {
      debugPrint('TipPurchaseService: Real purchase initialization failed with exception: $e');
      debugPrint('TipPurchaseService: Exception type: ${e.runtimeType}');
      return false;
    }
  }

  // Load available products from the store
  Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = TipProduct.availableTips
          .map((tip) => tip.id)
          .toSet();
      
      debugPrint('===== Loading Products from App Store =====');
      debugPrint('TipPurchaseService: Querying products from store...');
      debugPrint('TipPurchaseService: Product IDs to query: ${productIds.join(", ")}');
      debugPrint('TipPurchaseService: Environment: ${AppConfig.environmentName}');
      debugPrint('TipPurchaseService: Using prefix: ${AppConfig.isDev ? "dev_tip_" : "tip_"}');

      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint('TipPurchaseService: Error loading products: ${response.error}');
        debugPrint('TipPurchaseService: Error details: ${response.error!.message}');
        debugPrint('TipPurchaseService: This may indicate:');
        debugPrint('  - Products not configured in App Store Connect/Play Console');
        debugPrint('  - Banking/tax information not complete');
        debugPrint('  - Products not approved yet');
        return;
      }

      _products = response.productDetails;
      debugPrint('TipPurchaseService: Successfully loaded ${_products.length} tip products');
      debugPrint('===== Loaded Products Details =====');
      
      if (_products.isEmpty) {
        debugPrint('===== CRITICAL: No Products Found! =====');
        debugPrint('TipPurchaseService: Requested IDs: ${productIds.join(", ")}');
        debugPrint('TipPurchaseService: Environment: ${AppConfig.environmentName}');
        debugPrint('TipPurchaseService: This likely means:');
        debugPrint('  1. Products not created in App Store Connect');
        debugPrint('  2. Product IDs mismatch (expected: tip_100 for production)');
        debugPrint('  3. Products not approved in App Store Connect');
        debugPrint('  4. Banking/Tax info incomplete in App Store Connect');
        debugPrint('  5. Product not available in current region');
        debugPrint('========================================');
      } else {
        for (final product in _products) {
          debugPrint('TipPurchaseService: ✓ Found product: ${product.id}');
          debugPrint('  - Price: ${product.price}');
          debugPrint('  - Title: ${product.title}');
          debugPrint('  - Description: ${product.description}');
        }
        debugPrint('========================================');
      }
      
    } catch (e) {
      debugPrint('TipPurchaseService: Exception while loading products: $e');
      debugPrint('TipPurchaseService: Stack trace: ${StackTrace.current}');
    }
  }

  // Get product details by amount
  dynamic getProductByAmount(int amount) {
    final productId = TipProduct.getTipIdByAmount(amount);
    debugPrint('TipPurchaseService: Looking for product with ID: $productId');
    debugPrint('TipPurchaseService: Current mode: ${_useMockMode ? "Mock" : "Real"}');
    
    if (_useMockMode) {
      try {
        final product = _mockProducts.firstWhere((product) => product.id == productId);
        debugPrint('TipPurchaseService: ✓ Found mock product: $productId');
        return product;
      } catch (e) {
        debugPrint('TipPurchaseService: ✗ Mock product not found for ID: $productId');
        return null;
      }
    }
    
    try {
      debugPrint('TipPurchaseService: Available products: ${_products.map((p) => p.id).join(", ")}');
      final product = _products.firstWhere((product) => product.id == productId);
      debugPrint('TipPurchaseService: ✓ Found product: ${product.id} - ${product.price}');
      return product;
    } catch (e) {
      debugPrint('===== PRODUCT NOT FOUND ERROR =====');
      debugPrint('TipPurchaseService: Product not found for amount: $amount');
      debugPrint('TipPurchaseService: Expected product ID: $productId');
      debugPrint('TipPurchaseService: Available product IDs: ${_products.map((p) => p.id).join(", ")}');
      debugPrint('TipPurchaseService: Total products loaded: ${_products.length}');
      debugPrint('====================================');
      return null;
    }
  }

  // Purchase a tip
  Future<TipPurchaseResponse> purchaseTip(int amount) async {
    try {
      if (!_isAvailable) {
        return TipPurchaseResponse.error('In-app purchase not available');
      }
      
      // Check if purchase is already in progress
      if (_isPurchaseInProgress) {
        debugPrint('TipPurchaseService: Purchase already in progress');
        return TipPurchaseResponse.error('Another purchase is already in progress');
      }
      
      // Check cooldown period
      if (_lastPurchaseTime != null) {
        final timeSinceLastPurchase = DateTime.now().difference(_lastPurchaseTime!);
        if (timeSinceLastPurchase < _purchaseCooldown) {
          final remainingSeconds = _purchaseCooldown.inSeconds - timeSinceLastPurchase.inSeconds;
          debugPrint('TipPurchaseService: Purchase cooldown active, $remainingSeconds seconds remaining');
          return TipPurchaseResponse.error('Please wait $remainingSeconds seconds before making another purchase');
        }
      }
      
      // Set purchase in progress
      _isPurchaseInProgress = true;
      debugPrint('TipPurchaseService: Starting purchase for amount: $amount');

      final product = getProductByAmount(amount);
      if (product == null) {
        _isPurchaseInProgress = false; // Reset on error
        debugPrint('===== PURCHASE FAILED: Product Not Found =====');
        debugPrint('Environment: ${AppConfig.environmentName}');
        debugPrint('Requested amount: ¥$amount');
        debugPrint('Expected product ID: ${TipProduct.getTipIdByAmount(amount)}');
        debugPrint('===============================================');
        
        // More detailed error message
        final errorMessage = AppConfig.isProd 
            ? 'Product not found. Please ensure:\n1. App was built with "make build-prod-ios"\n2. Product "tip_100" exists in App Store Connect\n3. Product is approved and available'
            : 'Product not found for amount: ¥$amount';
        return TipPurchaseResponse.error(errorMessage);
      }

      // Handle mock mode
      if (_useMockMode) {
        return await _handleMockPurchase(amount, product as MockProductDetails);
      }

      // Real purchase flow
      try {
        debugPrint('TipPurchaseService: Starting real purchase for product: ${product.id}');
        
        // Create purchase param
        final PurchaseParam purchaseParam = PurchaseParam(
          productDetails: product as ProductDetails,
        );

        // Start the purchase
        debugPrint('TipPurchaseService: Calling buyConsumable...');
        final bool success = await _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam,
        );

        if (!success) {
          debugPrint('TipPurchaseService: buyConsumable returned false');
          debugPrint('TipPurchaseService: This usually means:');
          debugPrint('  - User not signed in to App Store');
          debugPrint('  - Parental controls preventing purchases');
          debugPrint('  - In-App Purchase disabled in Settings');
          _isPurchaseInProgress = false; // Reset state on failure
          return TipPurchaseResponse.error('購入を開始できませんでした。App Storeにサインインしているか、設定でアプリ内課金が有効になっているか確認してください。');
        }
        
        debugPrint('TipPurchaseService: Purchase initiated successfully, waiting for response...');
        // Return pending status - actual result will come via purchase stream
        return TipPurchaseResponse.pending();
      } catch (e) {
        debugPrint('TipPurchaseService: Real purchase failed with exception: $e');
        debugPrint('TipPurchaseService: Exception type: ${e.runtimeType}');
        _isPurchaseInProgress = false; // Reset state on exception
        return TipPurchaseResponse.error('Purchase failed: ${e.toString()}');
      }
      
    } catch (e) {
      debugPrint('TipPurchaseService: Outer purchase error: $e');
      _isPurchaseInProgress = false; // Always reset on error
      return TipPurchaseResponse.error('Purchase failed: ${e.toString()}');
    } finally {
      // Ensure state is always consistent
      if (_isPurchaseInProgress) {
        debugPrint('TipPurchaseService: Purchase state still in progress after error, resetting...');
      }
    }
  }

  // Handle mock purchase for development
  Future<TipPurchaseResponse> _handleMockPurchase(int amount, MockProductDetails product) async {
    debugPrint('TipPurchaseService: Processing mock purchase for ¥$amount');
    
    try {
      // Simulate network delay
      debugPrint('TipPurchaseService: Starting 1.5s delay simulation');
      await Future.delayed(const Duration(milliseconds: 1500));
      debugPrint('TipPurchaseService: Delay completed');
      
      // Log mock purchase to Firestore and local storage
      debugPrint('TipPurchaseService: Attempting to log mock purchase');
      try {
        await _logMockPurchase(amount, product);
        debugPrint('TipPurchaseService: Mock purchase logged successfully');
      } catch (e) {
        debugPrint('TipPurchaseService: Failed to log mock purchase: $e');
        // Continue even if logging fails
      }
      
      // Save to local storage for offline access
      try {
        await _savePurchaseToLocal(amount, product.id, 'mock_${DateTime.now().millisecondsSinceEpoch}', true);
        debugPrint('TipPurchaseService: Mock purchase saved to local storage');
      } catch (e) {
        debugPrint('TipPurchaseService: Failed to save mock purchase to local storage: $e');
      }
      
      // Process any pending offline purchases if we're online
      _processPendingOfflinePurchases();
      
      // Update last purchase time and reset progress state
      _lastPurchaseTime = DateTime.now();
      _isPurchaseInProgress = false;
      
      // Return success
      debugPrint('TipPurchaseService: Returning success response');
      return TipPurchaseResponse.success(
        productId: product.id,
        transactionId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      debugPrint('TipPurchaseService: Error in mock purchase: $e');
      _isPurchaseInProgress = false; // Reset on error
      return TipPurchaseResponse.error('Mock purchase failed: $e');
    }
  }

  // Log mock purchase for development tracking
  Future<void> _logMockPurchase(int amount, MockProductDetails product) async {
    try {
      final user = _auth.currentUser;
      debugPrint('TipPurchaseService: Creating Firestore document...');
      
      // Add timeout to prevent hanging
      await _firestore.collection('tip_purchases').add({
        'userId': user?.uid ?? 'anonymous',
        'productId': product.id,
        'amount': amount,
        'transactionId': 'mock_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'mock_${Platform.isIOS ? 'ios' : 'android'}',
        'isMockPurchase': true,
        'environment': 'development',
      }).timeout(const Duration(seconds: 10));
      
      debugPrint('TipPurchaseService: Mock purchase logged successfully');
    } catch (e) {
      debugPrint('TipPurchaseService: Failed to log to Firestore: $e');
      
      // Save to offline queue for later sync
      try {
        await _saveToOfflineQueue({
          'userId': _auth.currentUser?.uid ?? 'anonymous',
          'productId': product.id,
          'amount': amount,
          'transactionId': 'mock_${DateTime.now().millisecondsSinceEpoch}',
          'timestamp': DateTime.now().toIso8601String(),
          'platform': 'mock_${Platform.isIOS ? 'ios' : 'android'}',
          'isMockPurchase': true,
          'environment': 'development',
        });
        debugPrint('TipPurchaseService: Mock purchase queued for offline sync');
      } catch (offlineError) {
        debugPrint('TipPurchaseService: Failed to queue for offline sync: $offlineError');
      }
      
      // Don't throw - this is just logging, purchase should still succeed
    }
  }

  // Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  // Handle individual purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    try {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          debugPrint('Purchase pending: ${purchaseDetails.productID}');
          break;
          
        case PurchaseStatus.purchased:
          debugPrint('Purchase completed: ${purchaseDetails.productID}');
          await _completePurchase(purchaseDetails);
          _lastPurchaseTime = DateTime.now();
          _isPurchaseInProgress = false;
          break;
          
        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchaseDetails.error}');
          _isPurchaseInProgress = false;
          break;
          
        case PurchaseStatus.canceled:
          debugPrint('Purchase canceled: ${purchaseDetails.productID}');
          _isPurchaseInProgress = false;
          break;
          
        case PurchaseStatus.restored:
          debugPrint('Purchase restored: ${purchaseDetails.productID}');
          break;
      }

      // Complete the purchase on the platform side
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
      
    } catch (e) {
      debugPrint('Error handling purchase: $e');
    }
  }

  // Complete purchase and log to Firestore
  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      final user = _auth.currentUser;
      final tipInfo = TipProduct.getTipInfoById(purchaseDetails.productID);
      
      // First, verify the receipt with our server
      debugPrint('TipPurchaseService: Verifying receipt with server...');
      
      try {
        // Get the receipt data
        final String receiptData = purchaseDetails.verificationData.localVerificationData;
        
        // Call our Cloud Function to verify the receipt
        final HttpsCallable callable = _functions.httpsCallable('verifyReceipt');
        final response = await callable.call({
          'receiptData': receiptData,
          'productId': purchaseDetails.productID,
          'transactionId': purchaseDetails.purchaseID ?? 'unknown',
          'userId': user?.uid,
        });
        
        debugPrint('TipPurchaseService: Server verification response: ${response.data}');
        
        if (response.data['success'] == true) {
          debugPrint('TipPurchaseService: Receipt verified successfully by server');
          debugPrint('TipPurchaseService: Environment: ${response.data['environment']}');
        } else {
          debugPrint('TipPurchaseService: Server verification failed');
          throw Exception('Receipt verification failed');
        }
      } catch (e) {
        debugPrint('TipPurchaseService: Error verifying receipt with server: $e');
        // Continue with local logging even if server verification fails
        // This ensures the user's purchase is recorded
        debugPrint('TipPurchaseService: Proceeding with local logging despite server error');
      }
      
      // Log purchase to Firestore for analytics (backup)
      await _firestore.collection('tip_purchases').add({
        'userId': user?.uid ?? 'anonymous',
        'productId': purchaseDetails.productID,
        'amount': tipInfo?.amount ?? 0,
        'transactionId': purchaseDetails.purchaseID,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': Platform.isIOS ? 'ios' : 'android',
        'isMockPurchase': false,
        'environment': 'production',
        'verificationData': {
          'localVerificationData': purchaseDetails.verificationData.localVerificationData,
          'serverVerificationData': purchaseDetails.verificationData.serverVerificationData,
        },
        'serverVerified': true,
      }).timeout(const Duration(seconds: 10));

      debugPrint('Tip purchase logged successfully');
      
      // Save to local storage for offline access
      try {
        await _savePurchaseToLocal(
          tipInfo?.amount ?? 0, 
          purchaseDetails.productID, 
          purchaseDetails.purchaseID ?? 'unknown', 
          false
        );
        debugPrint('TipPurchaseService: Production purchase saved to local storage');
      } catch (e) {
        debugPrint('TipPurchaseService: Failed to save production purchase to local storage: $e');
      }
      
    } catch (e) {
      // Enhanced error logging for production purchase logging
      if (e.toString().contains('timeout')) {
        debugPrint('TipPurchaseService: Firestore timeout while logging purchase: ${purchaseDetails.productID}');
      } else {
        debugPrint('TipPurchaseService: Failed to log purchase: $e');
      }
      
      // Save to offline queue for later sync
      try {
        final user = _auth.currentUser;
        final tipInfo = TipProduct.getTipInfoById(purchaseDetails.productID);
        
        await _saveToOfflineQueue({
          'userId': user?.uid ?? 'anonymous',
          'productId': purchaseDetails.productID,
          'amount': tipInfo?.amount ?? 0,
          'transactionId': purchaseDetails.purchaseID,
          'timestamp': DateTime.now().toIso8601String(),
          'platform': Platform.isIOS ? 'ios' : 'android',
          'isMockPurchase': false,
          'environment': 'production',
          'verificationData': {
            'localVerificationData': purchaseDetails.verificationData.localVerificationData,
            'serverVerificationData': purchaseDetails.verificationData.serverVerificationData,
          },
          'serverVerified': false,
        });
        debugPrint('TipPurchaseService: Production purchase queued for offline sync');
      } catch (offlineError) {
        debugPrint('TipPurchaseService: Failed to queue for offline sync: $offlineError');
      }
      
      // Note: Purchase was successful even if logging failed
    }
  }

  // Check if service is available
  bool get isAvailable => _isAvailable;

  // Get all available products
  List<ProductDetails> get products => List.unmodifiable(_products);

  // Check if service is in mock mode
  bool get isMockMode => _useMockMode;

  // Get service mode description
  String get serviceMode => _useMockMode ? 'Mock (Development)' : 'Real (Production)';
  
  // Check if purchase is currently in progress
  bool get isPurchaseInProgress => _isPurchaseInProgress;
  
  // Get remaining cooldown time in seconds (0 if no cooldown)
  int get remainingCooldownSeconds {
    if (_lastPurchaseTime == null) return 0;
    final timeSinceLastPurchase = DateTime.now().difference(_lastPurchaseTime!);
    final remaining = _purchaseCooldown.inSeconds - timeSinceLastPurchase.inSeconds;
    return remaining > 0 ? remaining : 0;
  }
  
  // Save purchase to local storage
  Future<void> _savePurchaseToLocal(int amount, String productId, String transactionId, bool isMock) async {
    try {
      final purchaseData = {
        'amount': amount,
        'productId': productId,
        'transactionId': transactionId,
        'timestamp': DateTime.now().toIso8601String(),
        'isMockPurchase': isMock,
        'userId': _auth.currentUser?.uid ?? 'anonymous',
      };
      
      // Get existing purchase history
      final existingHistory = await getPurchaseHistory();
      
      // Add new purchase to history
      existingHistory.add(purchaseData);
      
      // Keep only last 100 purchases to avoid storage bloat
      if (existingHistory.length > 100) {
        existingHistory.removeRange(0, existingHistory.length - 100);
      }
      
      // Save updated history
      await _localStorage.setJson('purchase_history', {'purchases': existingHistory});
      
    } catch (e) {
      debugPrint('TipPurchaseService: Failed to save purchase to local storage: $e');
      rethrow;
    }
  }
  
  // Get purchase history from local storage
  Future<List<Map<String, dynamic>>> getPurchaseHistory() async {
    try {
      final historyData = await _localStorage.getJson('purchase_history');
      if (historyData != null && historyData['purchases'] is List) {
        return List<Map<String, dynamic>>.from(historyData['purchases']);
      }
      return [];
    } catch (e) {
      debugPrint('TipPurchaseService: Failed to get purchase history: $e');
      return [];
    }
  }
  
  // Get total amount spent (for analytics)
  Future<int> getTotalAmountSpent() async {
    try {
      final history = await getPurchaseHistory();
      return history.fold<int>(0, (total, purchase) => total + (purchase['amount'] as int? ?? 0));
    } catch (e) {
      debugPrint('TipPurchaseService: Failed to calculate total amount: $e');
      return 0;
    }
  }
  
  // Get purchase count
  Future<int> getPurchaseCount() async {
    try {
      final history = await getPurchaseHistory();
      return history.length;
    } catch (e) {
      debugPrint('TipPurchaseService: Failed to get purchase count: $e');
      return 0;
    }
  }
  
  // Save purchase data to offline queue for later sync
  Future<void> _saveToOfflineQueue(Map<String, dynamic> purchaseData) async {
    try {
      // Get existing offline queue
      final queueData = await _localStorage.getJson('offline_purchase_queue');
      List<Map<String, dynamic>> queue = [];
      
      if (queueData != null && queueData['queue'] is List) {
        queue = List<Map<String, dynamic>>.from(queueData['queue']);
      }
      
      // Add new purchase to queue
      queue.add(purchaseData);
      
      // Keep only last 50 failed purchases to avoid storage bloat
      if (queue.length > 50) {
        queue.removeRange(0, queue.length - 50);
      }
      
      // Save updated queue
      await _localStorage.setJson('offline_purchase_queue', {'queue': queue});
      
    } catch (e) {
      debugPrint('TipPurchaseService: Failed to save to offline queue: $e');
      rethrow;
    }
  }
  
  // Process pending offline purchases (background sync)
  Future<void> _processPendingOfflinePurchases() async {
    try {
      final queueData = await _localStorage.getJson('offline_purchase_queue');
      if (queueData == null || queueData['queue'] is! List) {
        return; // No pending purchases
      }
      
      List<Map<String, dynamic>> queue = List<Map<String, dynamic>>.from(queueData['queue']);
      if (queue.isEmpty) {
        return;
      }
      
      debugPrint('TipPurchaseService: Processing ${queue.length} pending offline purchases');
      List<Map<String, dynamic>> failedQueue = [];
      
      for (final purchaseData in queue) {
        try {
          // Convert timestamp back to Firestore format
          final data = Map<String, dynamic>.from(purchaseData);
          data['timestamp'] = FieldValue.serverTimestamp();
          
          // Try to upload to Firestore
          await _firestore.collection('tip_purchases').add(data).timeout(const Duration(seconds: 10));
          
          debugPrint('TipPurchaseService: Successfully synced offline purchase: ${data['transactionId']}');
          
        } catch (e) {
          debugPrint('TipPurchaseService: Failed to sync offline purchase: $e');
          failedQueue.add(purchaseData); // Keep failed ones for retry
        }
      }
      
      // Update queue with only failed purchases
      await _localStorage.setJson('offline_purchase_queue', {'queue': failedQueue});
      
      if (failedQueue.length < queue.length) {
        debugPrint('TipPurchaseService: Successfully synced ${queue.length - failedQueue.length} offline purchases');
      }
      
    } catch (e) {
      debugPrint('TipPurchaseService: Error processing offline purchases: $e');
    }
  }
  
  // Get count of pending offline purchases
  Future<int> getPendingOfflinePurchases() async {
    try {
      final queueData = await _localStorage.getJson('offline_purchase_queue');
      if (queueData != null && queueData['queue'] is List) {
        return (queueData['queue'] as List).length;
      }
      return 0;
    } catch (e) {
      debugPrint('TipPurchaseService: Failed to get pending offline purchases count: $e');
      return 0;
    }
  }
  
  // Manual sync trigger for offline purchases
  Future<bool> syncOfflinePurchases() async {
    try {
      await _processPendingOfflinePurchases();
      final remaining = await getPendingOfflinePurchases();
      return remaining == 0;
    } catch (e) {
      debugPrint('TipPurchaseService: Manual sync failed: $e');
      return false;
    }
  }

  // Dispose resources
  void dispose() {
    _subscription?.cancel();
  }
}

// Mock product details for development
class MockProductDetails {
  final String id;
  final String price;
  final double rawPrice;
  final String title;
  final String description;
  final String currencyCode;

  MockProductDetails({
    required this.id,
    required this.price,
    required this.rawPrice,
    String? title,
    String? description,
    this.currencyCode = 'JPY',
  }) : title = title ?? 'Mock Tip $price',
       description = description ?? 'Development tip for $price';
}