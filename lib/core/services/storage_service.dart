import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';

class StorageService {
  final _client = SupabaseClientProvider.client;

  Future<String> uploadImage(String bucket, String path, List<int> bytes) async {
    final response = await _client.storage.from(bucket).uploadBinary(path, bytes);
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteImage(String bucket, String path) async {
    await _client.storage.from(bucket).remove([path]);
  }

  Future<String> uploadPostImage(List<int> bytes, String fileName) async {
    return uploadImage('posts', fileName, bytes);
  }

  Future<String> uploadProfileImage(List<int> bytes, String fileName) async {
    return uploadImage('avatars', fileName, bytes);
  }
}