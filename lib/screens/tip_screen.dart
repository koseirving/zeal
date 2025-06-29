import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/tip_purchase_service.dart';
import '../models/tip_product_model.dart';
import '../widgets/feedback_dialog.dart';
import '../utils/error_messages.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  int selectedAmount = 100;
  final TipPurchaseService _purchaseService = TipPurchaseService();
  bool _isLoading = false;

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
          'Support for ZEAL',
          style: GoogleFonts.crimsonText(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Header Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B35).withOpacity(0.3),
                          const Color(0xFFFFD93D).withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFFF6B35),
                      size: 48,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    'Celebrate Your Wins',
                    style: GoogleFonts.crimsonText(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    'When your dreams start coming true,\nshare your success with us',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Amount Selection
                  Text(
                    'Celebrate with us',
                    style: GoogleFonts.crimsonText(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Amount Buttons Grid
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _TipAmountCard(
                              amount: 100,
                              isSelected: selectedAmount == 100,
                              onTap: () => setState(() => selectedAmount = 100),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _TipAmountCard(
                              amount: 300,
                              isSelected: selectedAmount == 300,
                              onTap: () => setState(() => selectedAmount = 300),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _TipAmountCard(
                              amount: 500,
                              isSelected: selectedAmount == 500,
                              onTap: () => setState(() => selectedAmount = 500),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _TipAmountCard(
                              amount: 1000,
                              isSelected: selectedAmount == 1000,
                              onTap: () => setState(() => selectedAmount = 1000),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4ECDC4).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Every step forward, every breakthrough, every dream realized - we want to celebrate with you. Your success story inspires the next dreamer.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
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
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Not Now',
                            style: TextStyle(
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
                          onPressed: (_isLoading || _purchaseService.isPurchaseInProgress) ? null : () => _processTip(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading || _purchaseService.isPurchaseInProgress
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : _getCelebrationButtonText(),
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

  Widget _getCelebrationButtonText() {
    final cooldownSeconds = _purchaseService.remainingCooldownSeconds;
    if (cooldownSeconds > 0) {
      return Text(
        'Wait ${cooldownSeconds}s',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Text(
      'Celebrate ¥$selectedAmount',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
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
      FeedbackDialog.showLoading(context, message: ErrorMessages.processingPurchase);
    }

    try {
      // Initialize purchase service if not already done
      final bool isInitialized = await _purchaseService.initialize();
      
      if (!isInitialized) {
        if (mounted) FeedbackDialog.hideLoading(context);
        _resetLoadingAndShowError(ErrorMessages.purchaseUnavailable);
        return;
      }

      // Check if the service is available
      if (!_purchaseService.isAvailable) {
        if (mounted) FeedbackDialog.hideLoading(context);
        _resetLoadingAndShowError(ErrorMessages.purchaseUnavailable);
        return;
      }

      // Process purchase
      debugPrint('TipScreen: Starting purchase (mode: ${_purchaseService.serviceMode})');
      final TipPurchaseResponse response = await _purchaseService.purchaseTip(selectedAmount);
      debugPrint('TipScreen: Purchase response: ${response.result}');
      
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
          final userFriendlyError = ErrorMessages.getUserFriendlyError(errorMessage);
          if (mounted) {
            final shouldRetry = await FeedbackDialog.showError(
              context,
              title: 'エラー',
              message: userFriendlyError,
              showRetry: true,
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
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF4ECDC4),
            ),
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
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
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

class _TipAmountCard extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _TipAmountCard({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF6BCF7F)],
                )
              : LinearGradient(
                  colors: [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF0F0F0F),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFF4ECDC4).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¥$amount',
              style: GoogleFonts.crimsonText(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}