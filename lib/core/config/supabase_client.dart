import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseClientProvider {
  static Future<void> init() async {
    await dotenv.load();
    
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? 'https://votre-projet.supabase.co',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'votre-cle-anon',
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
      ),
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static String? get currentUserId => client.auth.currentUser?.id;
  
  static bool get isAuthenticated => client.auth.currentSession != null;
  
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}