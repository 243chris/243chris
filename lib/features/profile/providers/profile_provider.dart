import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:africonnect/core/models/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  UserModel? _profile;
  bool _isLoading = false;
  String? _error;

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase.from('profiles')
          .select()
          .eq('id', userId)
          .single();
      _profile = UserModel.fromJson(response);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? region,
    String? avatarUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _supabase.from('profiles').update({
        'username': username ?? _profile?.username,
        'full_name': fullName ?? _profile?.fullName,
        'bio': bio ?? _profile?.bio,
        'region': region ?? _profile?.region,
        'avatar_url': avatarUrl ?? _profile?.avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      await fetchProfile(userId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> followUser(String userId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    await _supabase.from('followers').insert({
      'follower_id': currentUserId,
      'following_id': userId,
    });
    notifyListeners();
  }

  Future<void> unfollowUser(String userId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    await _supabase.from('followers')
        .delete()
        .eq('follower_id', currentUserId)
        .eq('following_id', userId);
    notifyListeners();
  }

  Future<bool> isFollowing(String userId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return false;

    final result = await _supabase.from('followers')
        .select()
        .eq('follower_id', currentUserId)
        .eq('following_id', userId)
        .maybeSingle();
    return result != null;
  }
}