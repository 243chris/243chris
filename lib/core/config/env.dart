import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get replicateApiToken => dotenv.env['REPLICATE_API_TOKEN'] ?? '';
  static String get livekitApiKey => dotenv.env['LIVEKIT_API_KEY'] ?? '';
  static String get livekitApiSecret => dotenv.env['LIVEKIT_API_SECRET'] ?? '';
  static String get openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
}