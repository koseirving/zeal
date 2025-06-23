import '../models/video_model.dart';

class VideoService {
  // Mock data for demonstration
  // In a real app, this would fetch from Firebase/API
  Future<List<VideoModel>> getVideos() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    return _mockVideos;
  }

  static final List<VideoModel> _mockVideos = [
    VideoModel(
      id: '1',
      title: 'Never Give Up - Motivational Speech',
      description: 'A powerful speech about perseverance and achieving your dreams. Learn how to push through challenges and never give up on your goals.',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      thumbnailUrl: 'https://via.placeholder.com/300x400/6366F1/FFFFFF?text=Never+Give+Up',
      category: 'Motivation',
      likes: 1240,
      views: 15670,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    VideoModel(
      id: '2',
      title: 'Success Mindset - Daily Habits',
      description: 'Discover the daily habits that successful people practice every day. Transform your mindset and achieve extraordinary results.',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
      thumbnailUrl: 'https://via.placeholder.com/300x400/8B5CF6/FFFFFF?text=Success+Mindset',
      category: 'Success',
      likes: 890,
      views: 12450,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    VideoModel(
      id: '3',
      title: 'Overcome Fear - Face Your Challenges',
      description: 'Learn how to overcome fear and step out of your comfort zone. Build confidence and tackle any challenge that comes your way.',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
      thumbnailUrl: 'https://via.placeholder.com/300x400/A855F7/FFFFFF?text=Overcome+Fear',
      category: 'Personal Growth',
      likes: 567,
      views: 8920,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    VideoModel(
      id: '4',
      title: 'Dream Big - Visualization Techniques',
      description: 'Master the art of visualization to manifest your dreams. Learn powerful techniques used by top performers worldwide.',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      thumbnailUrl: 'https://via.placeholder.com/300x400/06B6D4/FFFFFF?text=Dream+Big',
      category: 'Visualization',
      likes: 2100,
      views: 25300,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    VideoModel(
      id: '5',
      title: 'Morning Motivation - Start Strong',
      description: 'Energize your mornings with this powerful motivational message. Set the tone for a productive and successful day.',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
      thumbnailUrl: 'https://via.placeholder.com/300x400/F59E0B/FFFFFF?text=Morning+Power',
      category: 'Morning Motivation',
      likes: 1780,
      views: 19650,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<VideoModel?> getVideoById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _mockVideos.firstWhere((video) => video.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<VideoModel>> getVideosByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _mockVideos.where((video) => 
      video.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  Future<void> incrementViews(String videoId) async {
    // In a real app, this would update the view count in the database
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> likeVideo(String videoId) async {
    // In a real app, this would update the like count in the database
    await Future.delayed(const Duration(milliseconds: 100));
  }
}