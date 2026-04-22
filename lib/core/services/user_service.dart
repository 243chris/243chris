import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';
import '../models/user_model.dart';

class UserService {
  final _client = SupabaseClientProvider.client;

  Future<UserModel?> getProfile(String userId) async {
    final response = await _client.from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response != null) {
      return UserModel.fromJson(response);
    }
    return null;
  }

  Future<UserModel?> getProfileByUsername(String username) async {
    final response = await _client.from('profiles')
        .select()
        .eq('username', username)
        .maybeSingle();
    if (response != null) {
      return UserModel.fromJson(response);
    }
    return null;
  }

  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? region,
    String? countryCode,
    String? language,
    String? avatarUrl,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('profiles').update({
      if (username != null) 'username': username,
      if (fullName != null) 'full_name': fullName,
      if (bio != null) 'bio': bio,
      if (region != null) 'region': region,
      if (countryCode != null) 'country_code': countryCode,
      if (language != null) 'language': language,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  Future<void> uploadAvatar(List<int> bytes) async {
    final userId = _client.auth.currentUser!.id;
    final fileName = 'avatar_$userId.jpg';
    await _client.storage.from('avatars').uploadBinary(fileName, bytes);
    final url = _client.storage.from('avatars').getPublicUrl(fileName);
    await updateProfile(avatarUrl: url);
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final response = await _client.from('profiles')
        .select()
        .ilike('username', '%$query%')
        .limit(20);
    return (response as List).map((j) => UserModel.fromJson(j)).toList();
  }

  Future<List<UserModel>> getSuggestedUsers() async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) return [];

    final following = await _client.from('followers')
        .select('following_id')
        .eq('follower_id', myId);
    final followingIds = following.map((f) => f['following_id']).toList();
    followingIds.add(myId);

    final response = await _client.from('profiles')
        .select()
        .not('id', 'in', followingIds)
        .limit(10);
    return (response as List).map((j) => UserModel.fromJson(j)).toList();
  }
}