import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/supabase_client.dart';

class AIService {
  final _client = SupabaseClientProvider.client;

  Future<String> generateCaricature(String imageUrl) async {
    final token = dotenv.env['REPLICATE_API_TOKEN'];
    
    final response = await http.post(
      Uri.parse('https://api.replicate.com/v1/predictions'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'version': 'caricature-model-version',
        'input': {'image': imageUrl, 'style': 'caricature'},
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to start generation');
    }

    final prediction = jsonDecode(response.body);
    final getUrl = prediction['urls']['get'];

    String? resultUrl;
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      final statusRes = await http.get(Uri.parse(getUrl), headers: {
        'Authorization': 'Token $token',
      });
      final statusData = jsonDecode(statusRes.body);
      if (statusData['status'] == 'succeeded') {
        resultUrl = statusData['output'];
        break;
      } else if (statusData['status'] == 'failed') {
        throw Exception('Generation failed');
      }
    }

    return resultUrl!;
  }

  Future<String> generateCustomEmoji(String prompt) async {
    final token = dotenv.env['REPLICATE_API_TOKEN'];
    
    final response = await http.post(
      Uri.parse('https://api.replicate.com/v1/predictions'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'version': 'emoji-model-version',
        'input': {'prompt': 'emoji style, $prompt'},
      }),
    );

    final prediction = jsonDecode(response.body);
    final getUrl = prediction['urls']['get'];

    String? resultUrl;
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      final statusRes = await http.get(Uri.parse(getUrl), headers: {
        'Authorization': 'Token $token',
      });
      final statusData = jsonDecode(statusRes.body);
      if (statusData['status'] == 'succeeded') {
        resultUrl = statusData['output'];
        break;
      }
    }

    return resultUrl!;
  }

  Future<bool> moderateContent(String content) async {
    final key = dotenv.env['OPENAI_API_KEY'];
    
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/moderations'),
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'input': content}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return !(data['results'][0]['flagged'] as bool);
    }
    return true;
  }
}