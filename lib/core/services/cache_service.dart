import 'package:hive_flutter/hive_flutter.dart';
import '../models/post_model.dart';

class CacheService {
  static const String feedBoxName = 'feedCache';
  static const String messagesBoxName = 'messagesCache';
  static const String profileBoxName = 'profileCache';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(feedBoxName);
    await Hive.openBox(messagesBoxName);
    await Hive.openBox(profileBoxName);
  }

  // Feed Cache
  Future<void> cacheFeed(List<PostModel> posts) async {
    final box = Hive.box(feedBoxName);
    await box.put('feed', posts.map((p) => p.toJson()).toList());
    await box.put('feedTimestamp', DateTime.now().toIso8601String());
  }

  List<PostModel>? getCachedFeed() {
    final box = Hive.box(feedBoxName);
    final timestamp = box.get('feedTimestamp');
    if (timestamp == null) return null;

    // Check if cache is less than 5 minutes old
    final cacheTime = DateTime.parse(timestamp);
    if (DateTime.now().difference(cacheTime).inMinutes > 5) return null;

    final data = box.get('feed');
    if (data != null) {
      return (data as List).map((j) => PostModel.fromJson(j)).toList();
    }
    return null;
  }

  Future<void> clearFeedCache() async {
    final box = Hive.box(feedBoxName);
    await box.clear();
  }

  // Messages Cache
  Future<void> cacheMessages(String conversationId, List<dynamic> messages) async {
    final box = Hive.box(messagesBoxName);
    await box.put(conversationId, messages);
  }

  List<dynamic>? getCachedMessages(String conversationId) {
    final box = Hive.box(messagesBoxName);
    return box.get(conversationId);
  }

  // Profile Cache
  Future<void> cacheProfile(String userId, Map<String, dynamic> profile) async {
    final box = Hive.box(profileBoxName);
    await box.put(userId, profile);
  }

  Map<String, dynamic>? getCachedProfile(String userId) {
    final box = Hive.box(profileBoxName);
    return box.get(userId);
  }

  // Low Data Mode
  static Future<void> setLowDataMode(bool enabled) async {
    final box = Hive.box(profileBoxName);
    await box.put('lowDataMode', enabled);
  }

  static bool getLowDataMode() {
    final box = Hive.box(profileBoxName);
    return box.get('lowDataMode') ?? false;
  }
}