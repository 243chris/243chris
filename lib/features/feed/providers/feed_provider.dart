import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:africonnect/core/models/post_model.dart';

class FeedProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isAlgorithmic = true;
  bool _hasError = false;
  String? _error;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isAlgorithmic => _isAlgorithmic;
  bool get hasError => _hasError;
  String? get error => _error;

  FeedProvider() {
    _subscribeToRealtime();
  }

  void _subscribeToRealtime() {
    _supabase.channel('public:posts').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'posts',
      callback: (_) => fetchFeed(),
    ).subscribe();
  }

  Future<void> fetchFeed() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      final response = await _supabase.from('posts')
          .select('*, profiles(*)')
          .order('created_at', ascending: false)
          .limit(20);
      _posts = (response as List).map((json) => PostModel.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleFeedMode() {
    _isAlgorithmic = !_isAlgorithmic;
    fetchFeed();
  }

  Future<void> createPost({
    String? content,
    List<String>? mediaUrls,
    String? mediaType,
  }) async {
    try {
      await _supabase.from('posts').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'content': content,
        'media_urls': mediaUrls,
        'media_type': mediaType ?? 'none',
      });
      await fetchFeed();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _supabase.from('posts').delete().eq('id', postId);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final likeIndex = post.likesCount;

    final existing = await _supabase.from('likes')
        .select()
        .eq('user_id', userId)
        .eq('target_type', 'post')
        .eq('target_id', postId)
        .maybeSingle();

    if (existing != null) {
      await _supabase.from('likes')
          .delete()
          .eq('user_id', userId)
          .eq('target_type', 'post')
          .eq('target_id', postId);
      _posts[index] = PostModel(
        id: post.id,
        userId: post.userId,
        content: post.content,
        mediaUrls: post.mediaUrls,
        mediaType: post.mediaType,
        likesCount: likeIndex - 1,
        commentsCount: post.commentsCount,
        sharesCount: post.sharesCount,
        viewsCount: post.viewsCount,
        isRepost: post.isRepost,
        originalPostId: post.originalPostId,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        profile: post.profile,
      );
    } else {
      await _supabase.from('likes').insert({
        'user_id': userId,
        'target_type': 'post',
        'target_id': postId,
      });
      _posts[index] = PostModel(
        id: post.id,
        userId: post.userId,
        content: post.content,
        mediaUrls: post.mediaUrls,
        mediaType: post.mediaType,
        likesCount: likeIndex + 1,
        commentsCount: post.commentsCount,
        sharesCount: post.sharesCount,
        viewsCount: post.viewsCount,
        isRepost: post.isRepost,
        originalPostId: post.originalPostId,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        profile: post.profile,
      );
    }
    notifyListeners();
  }
}