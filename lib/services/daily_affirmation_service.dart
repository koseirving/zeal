import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../services/affirmation_service.dart';
import '../models/affirmation_model.dart';

class DailyAffirmationService {
  static const String _lastShownDateKey = 'last_affirmation_shown_date';

  static Future<bool> shouldShowDailyAffirmation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShownDate = prefs.getString(_lastShownDateKey);
      final today = DateTime.now().toIso8601String().split('T')[0];

      return lastShownDate != today;
    } catch (e) {
      // If SharedPreferences fails, show the dialog (fail-safe)
      return true;
    }
  }

  static Future<void> markAffirmationShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString(_lastShownDateKey, today);
    } catch (e) {
      // If SharedPreferences fails, ignore silently
      debugPrint('Failed to save affirmation shown date: $e');
    }
  }

  static Future<void> showDailyAffirmationDialog(BuildContext context) async {
    if (!await shouldShowDailyAffirmation()) return;

    final affirmationService = AffirmationService();
    final dailyAffirmation = await affirmationService.getDailyAffirmation();

    if (context.mounted && dailyAffirmation != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _DailyAffirmationDialog(affirmation: dailyAffirmation);
        },
      );

      await markAffirmationShown();
    }
  }
}

class _DailyAffirmationDialog extends StatelessWidget {
  final AffirmationModel affirmation;

  const _DailyAffirmationDialog({required this.affirmation});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F), Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6BCF7F).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6BCF7F).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            // Title
            Text(
              'Daily Affirmation',
              style: GoogleFonts.crimsonText(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6BCF7F).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6BCF7F).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                affirmation.category.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF6BCF7F),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Affirmation text
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6BCF7F).withOpacity(0.1),
                    const Color(0xFF6BCF7F).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6BCF7F).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                affirmation.text,
                style: GoogleFonts.crimsonText(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF6BCF7F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Let\'s Go',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
