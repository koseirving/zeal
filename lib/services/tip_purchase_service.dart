import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tip_product_model.dart';
import '../config/app_config.dart';

class TipPurchaseService {
  static final TipPurchaseService _instance = TipPurchaseService._internal();
  factory TipPurchaseService() => _instance;
  TipPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _useMockMode = false;
  
  // Mock products for development
  final List<MockProductDetails> _mockProducts = [
    MockProductDetails(id: 'tip_100', price: '¥100', rawPrice: 100.0),
    MockProductDetails(id: 'tip_300', price: '¥300', rawPrice: 300.0),
    MockProductDetails(id: 'tip_500', price: '¥500', rawPrice: 500.0),
    MockProductDetails(id: 'tip_1000', price: '¥1000', rawPrice: 1000.0),
  ];

  // Initialize the purchase service
  Future<bool> initialize() async {
    try {
      // Always use mock mode in development for now (until StoreKit is properly configured)
      if (AppConfig.isDev || kDebugMode) {
        debugPrint('TipPurchaseService: Development environment - using mock mode');
        _useMockMode = true;
        _isAvailable = true;
        return true;
      }
      
      // In production, try real purchase
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
      
      debugPrint('TipPurchaseService: Initialized successfully (mode: ${_useMockMode ? "Mock" : "Real"})');
      return true;
    } catch (e) {
      debugPrint('TipPurchaseService: Failed to initialize: $e');
      
      // Fallback to mock mode in development
      if (AppConfig.isDev && kDebugMode) {
        debugPrint('TipPurchaseService: Using mock mode as fallback');
        _useMockMode = true;
        _isAvailable = true;
        return true;
      }
      
      return false;
    }
  }

  Future<bool> _tryInitializeRealPurchase() async {
    try {
      return await _inAppPurchase.isAvailable();
    } catch (e) {
      debugPrint('TipPurchaseService: Real purchase initialization failed: $e');
      return false;
    }
  }

  // Load available products from the store
  Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = TipProduct.availableTips
          .map((tip) => tip.id)
          .toSet();

      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint('Error loading products: ${response.error}');
        return;
      }

      _products = response.productDetails;
      debugPrint('Loaded ${_products.length} tip products');
      
      for (final product in _products) {
        debugPrint('Product: ${product.id} - ${product.price}');
      }
      
    } catch (e) {
      debugPrint('Failed to load products: $e');
    }
  }

  // Get product details by amount
  dynamic getProductByAmount(int amount) {
    final productId = TipProduct.getTipIdByAmount(amount);
    
    if (_useMockMode) {
      try {
        return _mockProducts.firstWhere((product) => product.id == productId);
      } catch (e) {
        debugPrint('TipPurchaseService: Mock product not found for amount: $amount');
        return null;
      }
    }
    
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      debugPrint('TipPurchaseService: Product not found for amount: $amount');
      return null;
    }
  }

  // Purchase a tip
  Future<TipPurchaseResponse> purchaseTip(int amount) async {
    try {
      if (!_isAvailable) {
        return TipPurchaseResponse.error('In-app purchase not available');
      }

      final product = getProductByAmount(amount);
      if (product == null) {
        return TipPurchaseResponse.error('Product not found for amount: ¥$amount');
      }

      // Handle mock mode
      if (_useMockMode) {
        return await _handleMockPurchase(amount, product as MockProductDetails);
      }

      // Real purchase flow
      try {
        // Create purchase param
        final PurchaseParam purchaseParam = PurchaseParam(
          productDetails: product as ProductDetails,
        );

        // Start the purchase
        final bool success = await _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam,
        );

        if (!success) {
          return TipPurchaseResponse.error('Failed to initiate purchase');
        }

        // Return pending status - actual result will come via purchase stream
        return TipPurchaseResponse.pending();
      } catch (e) {
        debugPrint('TipPurchaseService: Real purchase failed: $e');
        return TipPurchaseResponse.error('Purchase failed: ${e.toString()}');
      }
      
    } catch (e) {
      debugPrint('TipPurchaseService: Purchase error: $e');
      return TipPurchaseResponse.error('Purchase failed: ${e.toString()}');
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
      
      // Log mock purchase to Firestore
      debugPrint('TipPurchaseService: Attempting to log mock purchase');
      try {
        await _logMockPurchase(amount, product);
        debugPrint('TipPurchaseService: Mock purchase logged successfully');
      } catch (e) {
        debugPrint('TipPurchaseService: Failed to log mock purchase: $e');
        // Continue even if logging fails
      }
      
      // Return success
      debugPrint('TipPurchaseService: Returning success response');
      return TipPurchaseResponse.success(
        productId: product.id,
        transactionId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      debugPrint('TipPurchaseService: Error in mock purchase: $e');
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
      }).timeout(const Duration(seconds: 5));
      
      debugPrint('TipPurchaseService: Mock purchase logged successfully');
    } catch (e) {
      debugPrint('TipPurchaseService: Failed to log to Firestore: $e');
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
          break;
          
        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchaseDetails.error}');
          break;
          
        case PurchaseStatus.canceled:
          debugPrint('Purchase canceled: ${purchaseDetails.productID}');
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
      
      // Log purchase to Firestore for analytics
      await _firestore.collection('tip_purchases').add({
        'userId': user?.uid ?? 'anonymous',
        'productId': purchaseDetails.productID,
        'amount': tipInfo?.amount ?? 0,
        'transactionId': purchaseDetails.purchaseID,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': Platform.isIOS ? 'ios' : 'android',
        'verificationData': {
          'localVerificationData': purchaseDetails.verificationData.localVerificationData,
          'serverVerificationData': purchaseDetails.verificationData.serverVerificationData,
        },
      });

      debugPrint('Tip purchase logged successfully');
      
    } catch (e) {
      debugPrint('Failed to log purchase: $e');
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