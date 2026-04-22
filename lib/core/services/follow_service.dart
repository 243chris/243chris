import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';

class FollowService {
  final _client = SupabaseClientProvider.client;

  Future<void> followUser(String userId) async {
    final currentUserId = _client.auth.currentUser!.id;
    await _client.from('followers').insert({
      'follower_id': currentUserId,
      'following_id': userId,
    });
  }

  Future<void> unfollowUser(String userId) async {
    final currentUserId = _client.auth.currentUser!.id;
    await _client.from('followers')
        .delete()
        .eq('follower_id', currentUserId)
        .eq('following_id', userId);
  }

  Future<bool> isFollowing(String userId) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return false;

    final result = await _client.from('followers')
        .select()
        .eq('follower_id', currentUserId)
        .eq('following_id', userId)
        .maybeSingle();
    return result != null;
  }

  Future<int> getFollowersCount(String userId) async {
    final result = await _client.from('followers')
        .select('id', count: CountOption.exact)
        .eq('following_id', userId);
    return result.count ?? 0;
  }

  Future<int> getFollowingCount(String userId) async {
    final result = await _client.from('followers')
        .select('id', count: CountOption.exact)
        .eq('follower_id', userId);
    return result.count ?? 0;
  }

  Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    final response = await _client.from('followers')
        .select('profiles(*)')
        .eq('following_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    final response = await _client.from('followers')
        .select('profiles(*)')
        .eq('follower_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }
}