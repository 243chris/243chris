import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';

class AuthService {
  final _client = SupabaseClientProvider.client;

  Future<User?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    return response.user;
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  bool get isAuthenticated => _client.auth.currentSession != null;

  Stream<User?> get authStateChanges => _client.auth.onAuthStateChange()
      .map((event) => event.session?.user);

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}