import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/music_provider.dart';
import '../widgets/music_player_widget.dart';

class MusicPlayerContent extends ConsumerStatefulWidget {
  const MusicPlayerContent({super.key});

  @override
  ConsumerState<MusicPlayerContent> createState() => _MusicPlayerContentState();
}

class _MusicPlayerContentState extends ConsumerState<MusicPlayerContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Focus',
    'Meditation',
    'Nature',
    'Instrumental',
    'Ambient',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicAsync = ref.watch(musicProvider);
    final currentMusic = ref.watch(currentMusicProvider);
    final playerState = ref.watch(musicPlayerProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
          // Category Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFF6366F1),
              labelColor: const Color(0xFF6366F1),
              unselectedLabelColor: Colors.white60,
              tabs: _categories.map((category) => Tab(text: category)).toList(),
              onTap: (index) {
                setState(() {
                  _selectedCategory = _categories[index];
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // Music List
          Expanded(
            child: musicAsync.when(
              data: (musicList) {
                final filteredMusic = _selectedCategory == 'All'
                    ? musicList
                    : musicList
                        .where((music) => music.category == _selectedCategory)
                        .toList();

                if (filteredMusic.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.music_off_outlined,
                          size: 64,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No music in $_selectedCategory',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredMusic.length,
                  itemBuilder: (context, index) {
                    final music = filteredMusic[index];
                    final isCurrentlyPlaying = currentMusic?.id == music.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isCurrentlyPlaying
                            ? const Color(0xFF6366F1).withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: isCurrentlyPlaying
                            ? Border.all(
                                color: const Color(0xFF6366F1),
                                width: 1,
                              )
                            : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: music.imageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(music.imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: music.imageUrl.isEmpty
                                ? const Color(0xFF6366F1)
                                : null,
                          ),
                          child: music.imageUrl.isEmpty
                              ? const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                        title: Text(
                          music.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              music.artist,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1)
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    music.category,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  music.formattedDuration,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: isCurrentlyPlaying
                            ? Icon(
                                playerState.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: const Color(0xFF6366F1),
                                size: 32,
                              )
                            : const Icon(
                                Icons.play_circle_outline,
                                color: Colors.white54,
                                size: 32,
                              ),
                        onTap: () {
                          if (isCurrentlyPlaying) {
                            if (playerState.isPlaying) {
                              ref.read(musicPlayerProvider.notifier).pause();
                            } else {
                              ref.read(musicPlayerProvider.notifier).play();
                            }
                          } else {
                            ref
                                .read(musicPlayerProvider.notifier)
                                .playMusic(music);
                          }
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6366F1),
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading music',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(musicProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Mini Player
          if (currentMusic != null)
            MusicPlayerWidget(music: currentMusic),
          ],
        ),
      ),
    );
  }
}