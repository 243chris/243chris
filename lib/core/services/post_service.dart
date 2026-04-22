import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class PostService {
  final _client = SupabaseClientProvider.client;

  Future<List<PostModel>> getFeed({bool algorithmic = true, int limit = 20}) async {
    var query = _client.from('posts')
        .select('*, profiles(*)')
        .order('created_at', ascending: false)
        .limit(limit);

    if (algorithmic) {
      try {
        final response = await _client.rpc('get_algorithmic_feed', params: {
          'user_id': _client.auth.currentUser?.id,
          'limit': limit,
        });
        return _parsePosts(response);
      } catch (_) {
        // Fallback to chronological
      }
    }

    final response = await query;
    return _parsePosts(response);
  }

  Future<List<PostModel>> getUserPosts(String userId) async {
    final response = await _client.from('posts')
        .select('*, profiles(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return _parsePosts(response);
  }

  Future<PostModel> createPost({
    String? content,
    List<String>? mediaUrls,
    String mediaType = 'none',
  }) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client.from('posts').insert({
      'user_id': userId,
      'content': content,
      'media_urls': mediaUrls,
      'media_type': mediaType,
    }).select().single();
    return PostModel.fromJson(response);
  }

  Future<void> deletePost(String postId) async {
    await _client.from('posts').delete().eq('id', postId);
  }

  Future<void> repost(String postId) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('posts').insert({
      'user_id': userId,
      'is_repost': true,
      'original_post_id': postId,
    });
  }

  List<PostModel> _parsePosts(dynamic response) {
    if (response == null) return [];
    return (response as List).map((json) => PostModel.fromJson(json)).toList();
  }
}