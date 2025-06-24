class TipProduct {
  final String id;
  final String title;
  final String description;
  final String price;
  final double priceValue;
  final String currencyCode;

  const TipProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.priceValue,
    required this.currencyCode,
  });

  factory TipProduct.fromProductDetails(dynamic productDetails) {
    return TipProduct(
      id: productDetails.id,
      title: productDetails.title,
      description: productDetails.description,
      price: productDetails.price,
      priceValue: productDetails.rawPrice,
      currencyCode: productDetails.currencyCode,
    );
  }

  // Predefined tip products for the app
  static List<TipProductInfo> get availableTips => _getEnvironmentTips();
  
  static List<TipProductInfo> _getEnvironmentTips() {
    // Use different product IDs for development and production
    final isDev = const bool.fromEnvironment('dart.vm.product') == false;
    final prefix = isDev ? 'dev_tip_' : 'tip_';
    
    return [
      TipProductInfo(
        id: '${prefix}100',
        amount: 100,
        description: 'Small celebration tip',
      ),
      TipProductInfo(
        id: '${prefix}300',
        amount: 300,
        description: 'Medium celebration tip',
      ),
      TipProductInfo(
        id: '${prefix}500',
        amount: 500,
        description: 'Large celebration tip',
      ),
      TipProductInfo(
        id: '${prefix}1000',
        amount: 1000,
        description: 'Premium celebration tip',
      ),
    ];
  }

  static TipProductInfo? getTipInfoById(String id) {
    try {
      return availableTips.firstWhere((tip) => tip.id == id);
    } catch (e) {
      return null;
    }
  }

  static String getTipIdByAmount(int amount) {
    final isDev = const bool.fromEnvironment('dart.vm.product') == false;
    final prefix = isDev ? 'dev_tip_' : 'tip_';
    return '$prefix$amount';
  }
}

class TipProductInfo {
  final String id;
  final int amount;
  final String description;

  const TipProductInfo({
    required this.id,
    required this.amount,
    required this.description,
  });
}

// Purchase result states
enum TipPurchaseResult {
  success,
  canceled,
  error,
  pending,
}

class TipPurchaseResponse {
  final TipPurchaseResult result;
  final String? error;
  final String? productId;
  final String? transactionId;

  const TipPurchaseResponse({
    required this.result,
    this.error,
    this.productId,
    this.transactionId,
  });

  factory TipPurchaseResponse.success({
    String? productId,
    String? transactionId,
  }) {
    return TipPurchaseResponse(
      result: TipPurchaseResult.success,
      productId: productId,
      transactionId: transactionId,
    );
  }

  factory TipPurchaseResponse.canceled() {
    return const TipPurchaseResponse(
      result: TipPurchaseResult.canceled,
    );
  }

  factory TipPurchaseResponse.error(String error) {
    return TipPurchaseResponse(
      result: TipPurchaseResult.error,
      error: error,
    );
  }

  factory TipPurchaseResponse.pending() {
    return const TipPurchaseResponse(
      result: TipPurchaseResult.pending,
    );
  }
}