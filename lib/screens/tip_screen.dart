import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/tip_purchase_service.dart';
import '../models/tip_product_model.dart';
import '../widgets/feedback_dialog.dart';
import '../utils/error_messages.dart';
import '../services/usage_stats_service.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  final TipPurchaseService _purchaseService = TipPurchaseService();
  final UsageStatsService _usageStatsService = UsageStatsService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isJapanese = false;
  Map<String, int> _userStats = {'totalFocusMinutes': 0, 'totalDays': 0};

  @override
  void initState() {
    super.initState();
    _loadUserStats();
    _logEnvironmentInfo();
  }
  
  void _logEnvironmentInfo() {
    debugPrint('===== TipScreen Environment Info =====');
    debugPrint('Environment: ${AppConfig.environmentName}');
    debugPrint('isDev: ${AppConfig.isDev}');
    debugPrint('isProd: ${AppConfig.isProd}');
    debugPrint('Expected product ID: ${TipProduct.getTipIdByAmount(100)}');
    debugPrint('======================================');
  }

  Future<void> _loadUserStats() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      final stats = await _usageStatsService.getUserStats(userId);
      if (mounted) {
        setState(() {
          _userStats = stats;
        });
      }
    } catch (e) {
      debugPrint('Failed to load user stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          _isJapanese ? 'ZEALを支援する' : 'Support ZEAL',
          style: GoogleFonts.crimsonText(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          // Language Toggle Button
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isJapanese = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          !_isJapanese
                              ? const Color(0xFFFF6B35)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'EN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            !_isJapanese
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isJapanese = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _isJapanese
                              ? const Color(0xFFFF6B35)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'JP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            _isJapanese
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B35).withValues(alpha: 0.3),
                          const Color(0xFFFFD93D).withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFFF6B35),
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // User Stats
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isJapanese
                              ? 'ZEALと刻んだ、夢への軌跡'
                              : 'Your Path, Forged with ZEAL',
                          style: GoogleFonts.crimsonText(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${_userStats['totalDays']}',
                                  style: GoogleFonts.crimsonText(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFF6B35),
                                  ),
                                ),
                                Text(
                                  _isJapanese ? '日' : 'Day',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            Column(
                              children: [
                                Text(
                                  '${_usageStatsService.minutesToHours(_userStats['totalFocusMinutes'] ?? 0)}',
                                  style: GoogleFonts.crimsonText(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4ECDC4),
                                  ),
                                ),
                                Text(
                                  _isJapanese ? '時間の集中' : 'Time In Focus',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    _isJapanese
                        ? '共に夢を追いかけ続けよう'
                        : "Let's Pursue The Dream, Together.",
                    style: GoogleFonts.crimsonText(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Main Message - Direct and Honest
                  Text(
                    _isJapanese
                        ? 'ZEALは広告を一切表示しません。\nあなたの夢の妨げは全て排除しています。'
                        : 'ZEAL shows no ads. Ever.\nWe eliminate everything that distracts from your dreams.',
                    style: GoogleFonts.crimsonText(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Reality Check
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _isJapanese
                          ? 'あなたの夢を一番近くで応援し続けるために、もしZEALがあなたの夢の実現に貢献できたその時には、支援のご検討をお願いします。'
                          : 'To keep supporting your dreams, if you feel ZEAL has helped you take a step toward them, please consider supporting us.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                      // textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            _isJapanese ? '今はしない' : 'Not Now',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed:
                              (_isLoading ||
                                      _purchaseService.isPurchaseInProgress)
                                  ? null
                                  : () => _processTip(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isLoading ||
                                      _purchaseService.isPurchaseInProgress
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : _getSupportButtonText(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSupportButtonText() {
    final cooldownSeconds = _purchaseService.remainingCooldownSeconds;
    if (cooldownSeconds > 0) {
      return Text(
        _isJapanese ? '${cooldownSeconds}秒待ってください' : 'Wait ${cooldownSeconds}s',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      );
    }
    return Text(
      _isJapanese ? '支援する (100円)' : 'Support (¥100)',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Future<void> _processTip() async {
    if (_isLoading) return;

    debugPrint('TipScreen: _processTip started');
    setState(() {
      _isLoading = true;
    });

    // Show loading dialog
    if (mounted) {
      FeedbackDialog.showLoading(
        context,
        message: ErrorMessages.processingPurchase,
      );
    }

    try {
      // Initialize purchase service if not already done
      debugPrint('===== TipScreen: Starting Purchase Process =====');
      debugPrint('TipScreen: Initializing purchase service...');
      final bool isInitialized = await _purchaseService.initialize();

      if (!isInitialized) {
        if (mounted) FeedbackDialog.hideLoading(context);
        final errorMsg =
            _isJapanese
                ? '購入機能が利用できません。\nApp Storeにサインインしているか、\nインターネット接続を確認してください。\n\n開発者向け：本番ビルドは「make build-prod-ios」を使用してください。'
                : 'Purchase feature unavailable.\nPlease check if you are signed in to App Store\nand have internet connection.\n\nFor developers: Use "make build-prod-ios" for production builds.';
        _resetLoadingAndShowError(errorMsg);
        return;
      }

      // Check if the service is available
      if (!_purchaseService.isAvailable) {
        if (mounted) FeedbackDialog.hideLoading(context);
        final errorMsg =
            _isJapanese
                ? 'アプリ内購入が無効です。\n設定 > スクリーンタイム > コンテンツとプライバシーの制限\nでアプリ内課金が許可されているか確認してください。'
                : 'In-app purchase is disabled.\nPlease check Settings > Screen Time > Content & Privacy Restrictions\nto ensure in-app purchases are allowed.';
        _resetLoadingAndShowError(errorMsg);
        return;
      }

      // Process purchase (always 100 yen)
      debugPrint('TipScreen: Service mode: ${_purchaseService.serviceMode}');
      debugPrint('TipScreen: Is available: ${_purchaseService.isAvailable}');
      debugPrint('TipScreen: Products count: ${_purchaseService.products.length}');
      debugPrint('TipScreen: Starting purchase for ¥100...');
      
      final TipPurchaseResponse response = await _purchaseService.purchaseTip(
        100,
      );
      debugPrint('TipScreen: Purchase response: ${response.result}');
      if (response.error != null) {
        debugPrint('TipScreen: Purchase error: ${response.error}');
      }

      // Hide loading dialog
      if (mounted) {
        FeedbackDialog.hideLoading(context);
      }

      // Reset loading state
      debugPrint('TipScreen: Resetting loading state (mounted: $mounted)');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('TipScreen: Loading state reset to false');
      }

      // Handle response
      switch (response.result) {
        case TipPurchaseResult.success:
          debugPrint('TipScreen: Showing thank you dialog...');
          if (mounted) {
            await FeedbackDialog.showSuccess(
              context,
              title: ErrorMessages.purchaseSuccess,
              message: ErrorMessages.tipThanks,
              duration: const Duration(milliseconds: 3500),
            );
            _navigateBack();
            debugPrint('TipScreen: Thank you dialog shown');
          }
          break;

        case TipPurchaseResult.canceled:
          debugPrint('TipScreen: Purchase canceled');
          break;

        case TipPurchaseResult.error:
          final errorMessage = response.error ?? ErrorMessages.purchaseFailed;
          String userFriendlyError;

          // Provide more specific error messages
          if (errorMessage.contains('not signed in') ||
              errorMessage.contains('App Store')) {
            userFriendlyError =
                _isJapanese
                    ? 'App Storeにサインインしてください'
                    : 'Please sign in to App Store';
          } else if (errorMessage.contains('Product not found')) {
            userFriendlyError =
                _isJapanese
                    ? '商品が見つかりません。\nApp Store Connectで「tip_100」が設定されているか確認してください。\n\n開発者向け：本番ビルドは「make build-prod-ios」を使用してください。'
                    : 'Product not found.\nPlease ensure "tip_100" is configured in App Store Connect.\n\nFor developers: Use "make build-prod-ios" for production builds.';
          } else if (errorMessage.contains('already in progress')) {
            userFriendlyError =
                _isJapanese
                    ? '購入処理中です。しばらくお待ちください。'
                    : 'Purchase in progress. Please wait.';
          } else {
            userFriendlyError = ErrorMessages.getUserFriendlyError(
              errorMessage,
            );
          }

          if (mounted) {
            final shouldRetry = await FeedbackDialog.showError(
              context,
              title: _isJapanese ? 'エラー' : 'Error',
              message: userFriendlyError,
              showRetry: !errorMessage.contains('already in progress'),
            );
            if (shouldRetry) {
              _processTip(); // Retry
            }
          }
          break;

        case TipPurchaseResult.pending:
          if (!_purchaseService.isMockMode) {
            _showPendingDialog();
          }
          break;
      }
    } catch (e) {
      debugPrint('TipScreen: Exception in _processTip: $e');
      if (mounted) FeedbackDialog.hideLoading(context);
      _resetLoadingAndShowError(ErrorMessages.getUserFriendlyError(e));
    }
  }

  void _resetLoadingAndShowError(String message) async {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      await FeedbackDialog.showError(
        context,
        title: 'エラー',
        message: message,
        showRetry: false,
      );
    }
  }

  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF4ECDC4)),
                const SizedBox(height: 16),
                Text(
                  '購入処理中...',
                  style: GoogleFonts.crimsonText(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'しばらくお待ちください',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}
