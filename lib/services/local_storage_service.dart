import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

/// ローカルストレージサービス
/// SharedPreferencesの代替として、メモリベースのフォールバックを提供
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // メモリベースのフォールバックストレージ
  final Map<String, String> _memoryStorage = {};
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool _useMemoryFallback = false;

  /// 初期化
  Future<bool> initialize() async {
    if (_isInitialized) return !_useMemoryFallback;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      _useMemoryFallback = false;
      debugPrint('LocalStorageService: SharedPreferences initialized successfully');
      return true;
    } catch (e) {
      debugPrint('LocalStorageService: SharedPreferences failed, using memory fallback: $e');
      _isInitialized = true;
      _useMemoryFallback = true;
      return false;
    }
  }

  /// 文字列値を取得
  Future<String?> getString(String key) async {
    await _ensureInitialized();

    if (_useMemoryFallback) {
      return _memoryStorage[key];
    }

    try {
      return _prefs?.getString(key);
    } catch (e) {
      debugPrint('LocalStorageService: getString failed, falling back to memory: $e');
      return _memoryStorage[key];
    }
  }

  /// 文字列値を保存
  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();

    // メモリストレージには常に保存（フォールバック用）
    _memoryStorage[key] = value;

    if (_useMemoryFallback) {
      debugPrint('LocalStorageService: Using memory storage for key: $key');
      return true;
    }

    try {
      final success = await _prefs?.setString(key, value) ?? false;
      if (success) {
        debugPrint('LocalStorageService: Successfully saved to SharedPreferences: $key');
      }
      return success;
    } catch (e) {
      debugPrint('LocalStorageService: setString failed, value saved to memory: $e');
      return true; // メモリには保存されているのでtrueを返す
    }
  }

  /// Bool値を取得
  Future<bool?> getBool(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Bool値を保存
  Future<bool> setBool(String key, bool value) async {
    return await setString(key, value.toString());
  }

  /// Int値を取得
  Future<int?> getInt(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Int値を保存
  Future<bool> setInt(String key, int value) async {
    return await setString(key, value.toString());
  }

  /// Double値を取得
  Future<double?> getDouble(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return double.tryParse(value);
  }

  /// Double値を保存
  Future<bool> setDouble(String key, double value) async {
    return await setString(key, value.toString());
  }

  /// JSON オブジェクトを取得
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    try {
      return json.decode(value) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('LocalStorageService: Failed to decode JSON for key $key: $e');
      return null;
    }
  }

  /// JSON オブジェクトを保存
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = json.encode(value);
      return await setString(key, jsonString);
    } catch (e) {
      debugPrint('LocalStorageService: Failed to encode JSON for key $key: $e');
      return false;
    }
  }

  /// キーを削除
  Future<bool> remove(String key) async {
    await _ensureInitialized();

    // メモリストレージからも削除
    _memoryStorage.remove(key);

    if (_useMemoryFallback) {
      return true;
    }

    try {
      return await _prefs?.remove(key) ?? false;
    } catch (e) {
      debugPrint('LocalStorageService: remove failed: $e');
      return true; // メモリからは削除されているのでtrueを返す
    }
  }

  /// すべてのキーをクリア
  Future<bool> clear() async {
    await _ensureInitialized();

    // メモリストレージをクリア
    _memoryStorage.clear();

    if (_useMemoryFallback) {
      return true;
    }

    try {
      return await _prefs?.clear() ?? false;
    } catch (e) {
      debugPrint('LocalStorageService: clear failed: $e');
      return true; // メモリはクリアされているのでtrueを返す
    }
  }

  /// すべてのキーを取得
  Future<Set<String>> getKeys() async {
    await _ensureInitialized();

    if (_useMemoryFallback) {
      return _memoryStorage.keys.toSet();
    }

    try {
      return _prefs?.getKeys() ?? <String>{};
    } catch (e) {
      debugPrint('LocalStorageService: getKeys failed, returning memory keys: $e');
      return _memoryStorage.keys.toSet();
    }
  }

  /// キーが存在するかチェック
  Future<bool> containsKey(String key) async {
    final keys = await getKeys();
    return keys.contains(key);
  }

  /// 初期化済みかチェック
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// 現在使用中のストレージタイプを取得
  String get storageType => _useMemoryFallback ? 'Memory' : 'SharedPreferences';

  /// ストレージの統計情報を取得
  Future<Map<String, dynamic>> getStorageStats() async {
    await _ensureInitialized();

    final keys = await getKeys();
    return {
      'storageType': storageType,
      'keyCount': keys.length,
      'keys': keys.toList(),
      'isUsingFallback': _useMemoryFallback,
    };
  }
}