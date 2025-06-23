import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/video_model.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoModel video;
  final bool isActive;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive && !oldWidget.isActive) {
      _initializeVideo();
    } else if (!widget.isActive && oldWidget.isActive) {
      _disposeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _hasError = false;
      });

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.videoUrl),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 9 / 16, // Vertical video ratio like TikTok
        autoPlay: true,
        looping: true,
        showControls: true,
        showControlsOnInitialize: false,
        controlsSafeAreaMinimum: const EdgeInsets.all(12),
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF6366F1),
          handleColor: const Color(0xFF6366F1),
          backgroundColor: Colors.white30,
          bufferedColor: Colors.white60,
        ),
      );

    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _disposeVideo() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video Player
        if (_chewieController != null && !_hasError)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoPlayerController!.value.size.width,
                height: _videoPlayerController!.value.size.height,
                child: Chewie(controller: _chewieController!),
              ),
            ),
          )
        else if (_hasError)
          Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.white54,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load video',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            ),
          ),

        // Video Info Overlay
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              // Like Button
              _ActionButton(
                icon: Icons.favorite,
                label: _formatCount(widget.video.likes),
                onTap: () {
                  // TODO: Implement like functionality
                },
              ),
              const SizedBox(height: 24),
              
              // Share Button
              _ActionButton(
                icon: Icons.share,
                label: 'Share',
                onTap: () {
                  // TODO: Implement share functionality
                },
              ),
              const SizedBox(height: 24),
              
              // Comment Button
              _ActionButton(
                icon: Icons.comment,
                label: 'Comment',
                onTap: () {
                  // TODO: Implement comment functionality
                },
              ),
            ],
          ),
        ),

        // Video Details
        Positioned(
          left: 12,
          right: 80,
          bottom: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                widget.video.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.video.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_formatCount(widget.video.views)} views',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
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
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}