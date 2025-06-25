class ErrorMessages {
  // Network errors
  static const String networkError = 'ネットワークエラーが発生しました。インターネット接続を確認してください。';
  static const String connectionTimeout = '接続がタイムアウトしました。もう一度お試しください。';
  static const String serverError = 'サーバーエラーが発生しました。しばらくしてからもう一度お試しください。';
  
  // Purchase errors
  static const String purchaseUnavailable = '購入機能は現在利用できません。';
  static const String purchaseInProgress = '別の購入処理が進行中です。しばらくお待ちください。';
  static const String purchaseCancelled = '購入がキャンセルされました。';
  static const String purchaseFailed = '購入処理に失敗しました。もう一度お試しください。';
  static const String productNotFound = '商品が見つかりません。';
  static const String purchaseCooldown = '連続購入はできません。しばらくお待ちください。';
  
  // Authentication errors
  static const String authenticationError = '認証エラーが発生しました。';
  static const String sessionExpired = 'セッションの有効期限が切れました。再度ログインしてください。';
  
  // Content loading errors
  static const String videoLoadError = '動画の読み込みに失敗しました。';
  static const String musicLoadError = '音楽の読み込みに失敗しました。';
  static const String contentNotFound = 'コンテンツが見つかりません。';
  static const String noMoreContent = 'これ以上のコンテンツはありません。';
  
  // Generic errors
  static const String unknownError = '予期しないエラーが発生しました。';
  static const String tryAgainLater = 'しばらくしてからもう一度お試しください。';
  static const String contactSupport = 'エラーが続く場合は、サポートまでお問い合わせください。';
  
  // Success messages
  static const String purchaseSuccess = 'Congratulations for Your Achievement!';
  static const String tipThanks = 'Thanks for Your Support! 🔥';
  static const String savedOffline = 'オフラインで保存されました。';
  static const String syncSuccess = '同期が完了しました。';
  
  // Loading messages
  static const String loading = 'Loading...';
  static const String processingPurchase = 'Processing Your Support...';
  static const String connectingStore = 'Connecting to Store...';
  static const String verifyingPurchase = 'Verifying Purchase...';
  
  // Helper method to get user-friendly error message
  static String getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Network related errors
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return networkError;
    }
    
    // Timeout errors
    if (errorString.contains('timeout')) {
      return connectionTimeout;
    }
    
    // Server errors
    if (errorString.contains('server') || 
        errorString.contains('500') ||
        errorString.contains('503')) {
      return serverError;
    }
    
    // Purchase related errors
    if (errorString.contains('purchase')) {
      if (errorString.contains('cancel')) {
        return purchaseCancelled;
      }
      return purchaseFailed;
    }
    
    // Authentication errors
    if (errorString.contains('auth') || 
        errorString.contains('permission') ||
        errorString.contains('forbidden')) {
      return authenticationError;
    }
    
    // Default error message
    return '$unknownError\n$tryAgainLater';
  }
  
  // Get error message with retry suggestion
  static String getErrorWithRetry(String baseError) {
    return '$baseError\n$tryAgainLater';
  }
  
  // Get error message with support contact
  static String getErrorWithSupport(String baseError) {
    return '$baseError\n$contactSupport';
  }
}