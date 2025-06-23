import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
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
                        const SizedBox(height: 40),

                        // Feature Cards Grid
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                            children: [
                              _FeatureCard(
                                title: 'Motivation Videos',
                                subtitle: 'Inspiring content',
                                icon: Icons.play_circle_fill,
                                color: const Color(
                                  0xFFFF6B35,
                                ), // Warm orange - passion
                                onTap: () => context.go('/videos'),
                              ),
                              _FeatureCard(
                                title: 'Focus Music',
                                subtitle: 'Concentration sounds',
                                icon: Icons.music_note,
                                color: const Color(
                                  0xFFFFD93D,
                                ), // Gold - excellence
                                onTap: () => context.go('/music'),
                              ),
                              _FeatureCard(
                                title: 'Daily Affirmations',
                                subtitle: 'Positive mindset',
                                icon: Icons.favorite,
                                color: const Color(
                                  0xFF6BCF7F,
                                ), // Green - growth
                                onTap: () => context.go('/affirmations'),
                              ),
                              _FeatureCard(
                                title: 'Goal Tracker',
                                subtitle: 'Track progress',
                                icon: Icons.track_changes,
                                color: const Color(
                                  0xFF4ECDC4,
                                ), // Teal - clarity
                                onTap: () {
                                  // TODO: Implement goal tracker
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Coming soon!'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
