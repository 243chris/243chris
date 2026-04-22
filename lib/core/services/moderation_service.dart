import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';

class ModerationService {
  final _client = SupabaseClientProvider.client;

  Future<void> reportContent({
    required String targetType,
    required String targetId,
    required String reason,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('reports').insert({
      'reporter_id': userId,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
    });
  }

  Future<void> blockUser(String userId) async {
    final currentUserId = _client.auth.currentUser!.id;
    await _client.from('blocks').insert({
      'blocker_id': currentUserId,
      'blocked_id': userId,
    });
  }

  Future<void> unblockUser(String userId) async {
    final currentUserId = _client.auth.currentUser!.id;
    await _client.from('blocks')
        .delete()
        .eq('blocker_id', currentUserId)
        .eq('blocked_id', userId);
  }
}