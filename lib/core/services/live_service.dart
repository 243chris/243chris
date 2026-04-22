import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';
import '../config/env.dart';

class LiveService {
  final _client = SupabaseClientProvider.client;

  Future<Map<String, dynamic>> createLiveStream(String title) async {
    final user = _client.auth.currentUser!;
    final roomName = 'live_${DateTime.now().millisecondsSinceEpoch}';
    
    final response = await _client.from('live_streams').insert({
      'user_id': user.id,
      'title': title,
      'room_name': roomName,
      'status': 'scheduled',
    }).select().single();

    return {
      ...response,
      'livekit_url': 'wss://$roomName.livekit.cloud',
      'api_key': EnvConfig.livekitApiKey,
      'api_secret': EnvConfig.livekitApiSecret,
    };
  }

  Future<void> startLiveStream(String streamId) async {
    await _client.from('live_streams').update({
      'status': 'live',
      'started_at': DateTime.now().toIso8601String(),
    }).eq('id', streamId);
  }

  Future<void> endLiveStream(String streamId) async {
    await _client.from('live_streams').update({
      'status': 'ended',
      'ended_at': DateTime.now().toIso8601String(),
    }).eq('id', streamId);
  }

  Future<List<Map<String, dynamic>>> getLiveStreams() async {
    final response = await _client.from('live_streams')
        .select('*, profiles(*)')
        .eq('status', 'live')
        .order('viewer_count', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}