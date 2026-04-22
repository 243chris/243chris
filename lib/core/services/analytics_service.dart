import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';

class AnalyticsService {
  final _client = SupabaseClientProvider.client;

  Future<void> trackPostView(String postId, String region) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Check if already viewed today
    final existing = await _client.from('post_analytics')
        .select()
        .eq('post_id', postId)
        .eq('region', region)
        .eq('date', today)
        .maybeSingle();

    if (existing != null) {
      await _client.from('post_analytics').update({
        'views': (existing['views'] ?? 0) + 1,
      })
          .eq('post_id', postId)
          .eq('region', region)
          .eq('date', today);
    } else {
      await _client.from('post_analytics').insert({
        'post_id': postId,
        'region': region,
        'views': 1,
        'date': today,
      });
    }
  }

  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    final postsCount = await _client.from('posts')
        .select('id', count: CountOption.exact)
        .eq('user_id', userId);

    final totalLikes = await _client.rpc('get_user_total_likes', params: {
      'p_user_id': userId,
    });
    final totalComments = await _client.rpc('get_user_total_comments', params: {
      'p_user_id': userId,
    });

    return {
      'posts': postsCount.count ?? 0,
      'likes': totalLikes ?? 0,
      'comments': totalComments ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> getRegionStats(String postId) async {
    final response = await _client.rpc('get_post_region_stats', params: {
      'post_id': postId,
    });
    return List<Map<String, dynamic>>.from(response ?? []);
  }
}