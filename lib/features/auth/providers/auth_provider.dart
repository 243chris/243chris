import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:africonnect/core/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _supabase.auth.currentSession != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      _fetchProfile(userId);
    }
    _supabase.auth.onAuthStateChange().listen((event) {
      if (event.session?.user != null) {
        _fetchProfile(event.session!.user.id);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchProfile(String userId) async {
    final response = await _supabase.from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response != null) {
      _user = UserModel.fromJson(response);
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      if (response.user != null) {
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'username': username,
        });
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }
}