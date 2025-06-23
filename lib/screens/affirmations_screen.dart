import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/affirmation_model.dart';
import '../providers/affirmation_provider.dart';
import '../services/notification_service.dart';

class AffirmationsScreen extends ConsumerStatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  ConsumerState<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends ConsumerState<AffirmationsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final affirmationsAsync = ref.watch(affirmationsProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E8FF),
              Color(0xFFE879F9),
              Color(0xFFA855F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Daily Affirmations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) async {
                        if (value == 'notifications') {
                          await _toggleNotifications(ref);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'notifications',
                          child: Row(
                            children: [
                              Icon(
                                notificationsEnabled
                                    ? Icons.notifications_off
                                    : Icons.notifications,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                notificationsEnabled
                                    ? 'Disable Notifications'
                                    : 'Enable Notifications',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Notification Status
              if (notificationsEnabled)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Daily notifications enabled at 9:00 AM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Affirmations
              Expanded(
                child: affirmationsAsync.when(
                  data: (affirmations) {
                    if (affirmations.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_outline,
                              size: 64,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No affirmations available',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Page Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            affirmations.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentIndex == index ? 12 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Affirmation Cards
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: affirmations.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final affirmation = affirmations[index];
                              return _AffirmationCard(
                                affirmation: affirmation,
                                onFavorite: () {
                                  // TODO: Implement favorite functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to favorites!'),
                                    ),
                                  );
                                },
                                onShare: () {
                                  // TODO: Implement share functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sharing functionality coming soon!'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        // Navigation Buttons
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FloatingActionButton(
                                heroTag: 'previous',
                                onPressed: _currentIndex > 0
                                    ? () {
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    : null,
                                backgroundColor: _currentIndex > 0
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: _currentIndex > 0
                                      ? const Color(0xFFA855F7)
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                              
                              FloatingActionButton(
                                heroTag: 'next',
                                onPressed: _currentIndex < affirmations.length - 1
                                    ? () {
                                        _pageController.nextPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    : null,
                                backgroundColor: _currentIndex < affirmations.length - 1
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: _currentIndex < affirmations.length - 1
                                      ? const Color(0xFFA855F7)
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading affirmations',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(affirmationsProvider);
                          },
                          child: const Text('Retry'),
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

  Future<void> _toggleNotifications(WidgetRef ref) async {
    final currentState = ref.read(notificationsEnabledProvider);
    
    if (currentState) {
      // Disable notifications
      await NotificationService.cancelAllNotifications();
      ref.read(notificationsEnabledProvider.notifier).state = false;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications disabled')),
        );
      }
    } else {
      // Enable notifications
      final affirmationsAsync = ref.read(affirmationsProvider);
      final affirmations = affirmationsAsync.value ?? [];
      
      if (affirmations.isNotEmpty) {
        await NotificationService.scheduleDailyAffirmations(affirmations);
        ref.read(notificationsEnabledProvider.notifier).state = true;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daily notifications enabled at 9:00 AM'),
            ),
          );
        }
      }
    }
  }
}

class _AffirmationCard extends StatelessWidget {
  final AffirmationModel affirmation;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  const _AffirmationCard({
    required this.affirmation,
    required this.onFavorite,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFA855F7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              affirmation.category,
              style: const TextStyle(
                color: Color(0xFFA855F7),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Affirmation Text
          Text(
            affirmation.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: Icons.favorite_outline,
                label: 'Favorite',
                onTap: onFavorite,
              ),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: onShare,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFA855F7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFA855F7),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}