import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/debug_service.dart';
import '../services/simple_debug_service.dart';
import '../services/video_service.dart';
import '../services/music_service.dart';
import '../services/affirmation_service.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  Map<String, dynamic>? _connectionTest;
  Map<String, dynamic>? _simpleTest;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runSimpleTest();
  }

  Future<void> _runSimpleTest() async {
    print('DebugScreen: Starting simple test...');
    setState(() {
      _isLoading = true;
      _error = null;
      _simpleTest = null;
    });

    try {
      print('DebugScreen: Calling SimpleDebugService.runBasicTests()');
      final result = await SimpleDebugService.runBasicTests()
          .timeout(const Duration(seconds: 45));
      
      print('DebugScreen: Simple test completed: $result');
      if (mounted) {
        setState(() {
          _simpleTest = result;
        });
      }
    } catch (e) {
      print('DebugScreen: Simple test failed: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _runConnectionTest() async {
    print('DebugScreen: Starting connection test...');
    setState(() {
      _isLoading = true;
      _error = null;
      _connectionTest = null;
    });

    try {
      print('DebugScreen: Calling DebugService.testFirestoreConnection()');
      final result = await DebugService.testFirestoreConnection()
          .timeout(const Duration(seconds: 30));
      
      print('DebugScreen: Connection test completed: $result');
      if (mounted) {
        setState(() {
          _connectionTest = result;
        });
      }
    } catch (e) {
      print('DebugScreen: Connection test failed: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createSampleData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await DebugService.createSampleData();
      
      // Refresh services to pick up new data
      await VideoService().refreshVideos();
      await MusicService().refreshMusic();
      await AffirmationService().refreshAffirmations();
      
      // Re-run connection test to see updated counts
      await _runConnectionTest();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample data created successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug - Firestore Connection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: $_error',
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            
            if (_simpleTest != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simple Firebase Test',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _buildTestResults(_simpleTest!),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _runConnectionTest,
                  child: const Text('Run Detailed Firestore Test'),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
            
            if (_connectionTest != null) ...[
              if (_connectionTest!['steps'] != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debug Steps',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...(_connectionTest!['steps'] as List<dynamic>).map((step) => 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text('• $step'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Firestore Connection Test',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow('Connection', _connectionTest!['connectionTest']),
                      _buildStatusRow('Authentication', _connectionTest!['authStatus']),
                      if (_connectionTest!['userId'] != null)
                        _buildInfoRow('User ID', _connectionTest!['userId']),
                      if (_connectionTest!['isAnonymous'] != null)
                        _buildStatusRow('Anonymous User', _connectionTest!['isAnonymous']),
                      const Divider(),
                      _buildInfoRow('Videos in Firestore', _connectionTest!['videoCount'].toString()),
                      _buildInfoRow('Music in Firestore', _connectionTest!['musicCount'].toString()),
                      _buildInfoRow('Affirmations in Firestore', _connectionTest!['affirmationCount'].toString()),
                      if (_connectionTest!['writeTest'] != null)
                        _buildStatusRow('Write Test', _connectionTest!['writeTest']),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createSampleData,
                  child: const Text('Create Sample Data'),
                ),
              ),
              
              const SizedBox(height: 8),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _runSimpleTest,
                  child: const Text('Refresh Simple Test'),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            Text(
              'Service Cache Info',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCacheInfo('Video Service', VideoService().getCacheInfo()),
                    const Divider(),
                    _buildCacheInfo('Music Service', MusicService().getCacheInfo()),
                    const Divider(),
                    _buildCacheInfo('Affirmation Service', AffirmationService().getCacheInfo()),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: '),
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(status ? 'OK' : 'Failed'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: '),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTestResults(Map<String, dynamic> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (results['firebaseApp'] != null) ...[
          const Text('🔥 Firebase App', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Project: ${() {
            try {
              final app = results['firebaseApp'] as Map<String, dynamic>?;
              final options = app?['options'];
              if (options is Map<String, dynamic>) {
                return options['projectId'] ?? 'Unknown';
              }
              return 'Unknown';
            } catch (e) {
              return 'Unknown';
            }
          }()}'),
          const SizedBox(height: 8),
        ],
        
        if (results['auth'] != null) ...[
          const Text('🔐 Authentication', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Status: ${(results['auth'] as Map<String, dynamic>?)?['hasCurrentUser'] == true ? "✅ Authenticated" : "❌ Not authenticated"}'),
          if ((results['auth'] as Map<String, dynamic>?)?['signInError'] != null)
            Text('Error: ${(results['auth'] as Map<String, dynamic>?)?['signInError']}', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
        ],
        
        if (results['firestore'] != null) ...[
          const Text('📊 Firestore', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Status: ${(results['firestore'] as Map<String, dynamic>?)?['connectionTest'] == 'success' ? "✅ Connected" : "❌ Failed"}'),
          if ((results['firestore'] as Map<String, dynamic>?)?['error'] != null)
            Text('Error: ${(results['firestore'] as Map<String, dynamic>?)?['error']}', style: const TextStyle(color: Colors.red)),
          if ((results['firestore'] as Map<String, dynamic>?)?['writeTest'] != null)
            Text('Write Test: ${(results['firestore'] as Map<String, dynamic>?)?['writeTest'] == 'success' ? "✅" : "❌"}'),
        ],
        
        if (results['fatalError'] != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Fatal Error: ${results['fatalError']}',
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCacheInfo(String serviceName, Map<String, dynamic> cacheInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Has Cache: ${cacheInfo['hasCachedVideos'] ?? cacheInfo['hasCachedMusic'] ?? cacheInfo['hasCachedAffirmations'] ?? false}'),
        Text('Cached Items: ${cacheInfo['cachedVideoCount'] ?? cacheInfo['cachedMusicCount'] ?? cacheInfo['cachedAffirmationCount'] ?? 0}'),
        if (cacheInfo['lastCacheUpdate'] != null)
          Text('Last Update: ${cacheInfo['lastCacheUpdate']}'),
        if (cacheInfo['cacheAge'] != null)
          Text('Cache Age: ${cacheInfo['cacheAge']} minutes'),
      ],
    );
  }
}