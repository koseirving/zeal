import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/daily_affirmation_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Mock data for community support
  final int _totalInvestors = 1247;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DailyAffirmationService.showDailyAffirmationDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0A0A), // Deep black
              const Color(0xFF1A1A1A), // Slightly lighter black
              const Color(0xFF0F0F0F), // Back to deep black
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with User Menu
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Add subtle glow effect to title
                    Stack(
                      children: [
                        // Glow layer
                        Text(
                          'ZEAL',
                          style: GoogleFonts.crimsonText(
                            fontSize: 96,
                            color: const Color(0xFFFF6B35).withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 20,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFFF6B35).withOpacity(0.6),
                                blurRadius: 30,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        // Main text
                        Text(
                          'ZEAL',
                          style: GoogleFonts.crimsonText(
                            fontSize: 96,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 20,
                          ),
                        ),
                      ],
                    ),
                    ShaderMask(
                      shaderCallback:
                          (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFFF6B35),
                              Color(0xFFFFFFFF),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ).createShader(bounds),
                      child: Text(
                        'Realize Your Dreams',
                        style: GoogleFonts.crimsonText(
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Feature Cards
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1A1A1A).withOpacity(0.8),
                        const Color(0xFF0A0A0A).withOpacity(0.9),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFFFF6B35).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Transform Your Mindset',
                          style: GoogleFonts.crimsonText(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover powerful tools to achieve your dreams',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Colors.white60,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Community Investment Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFFD93D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B35).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$_totalInvestors winners',
                                      style: GoogleFonts.crimsonText(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'celebrated their success',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/tip'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    'Join them',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // Add some extra content or leave empty for now
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0A0A0A),
            ],
          ),
          border: Border(
            top: BorderSide(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            if (index == 0) {
              // Already on home screen
              return;
            } else if (index == 1) {
              context.go('/content?tab=0');  // Videos
            } else if (index == 2) {
              context.go('/content?tab=1');  // Music
            } else if (index == 3) {
              context.go('/content?tab=2');  // Tracker
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: Colors.white54,
          selectedLabelStyle: GoogleFonts.crimsonText(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.crimsonText(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.3),
                      const Color(0xFF6366F1).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.home,
                  size: 24,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF6366F1).withOpacity(0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.play_circle_fill,
                size: 24,
              ),
              label: 'Videos',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.music_note,
                size: 24,
              ),
              label: 'Music',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.calendar_today,
                size: 24,
              ),
              label: 'Tracker',
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1A1A), const Color(0xFF0F0F0F)],
        ),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.5), width: 1),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                    shadows: [
                      Shadow(color: color.withOpacity(0.6), blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}