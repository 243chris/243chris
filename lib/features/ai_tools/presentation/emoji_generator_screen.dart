import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:africonnect/core/services/ai_service.dart';

class EmojiGeneratorScreen extends StatefulWidget {
  const EmojiGeneratorScreen({Key? key}) : super(key: key);

  @override
  _EmojiGeneratorScreenState createState() => _EmojiGeneratorScreenState();
}

class _EmojiGeneratorScreenState extends State<EmojiGeneratorScreen> {
  final _aiService = AIService();
  final _promptController = TextEditingController();
  bool _isLoading = false;
  String? _generatedUrl;
  String? _error;

  Future<void> _generate() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _aiService.generateCustomEmoji(_promptController.text);
      setState(() {
        _generatedUrl = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEmoji() async {
    if (_generatedUrl == null) return;

    final supabase = Supabase.instance.client;
    await supabase.from('custom_emojis').insert({
      'user_id': supabase.auth.currentUser!.id,
      'image_url': _generatedUrl,
      'name': _promptController.text,
      'is_public': true,
    });

    await supabase.from('posts').insert({
      'user_id': supabase.auth.currentUser!.id,
      'media_urls': [_generatedUrl],
      'media_type': 'image',
      'content': 'Nouvel emoji: ${_promptController.text}',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emoji enregistré!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générateur d\'emoji'),
        actions: [
          if (_generatedUrl != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveEmoji,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Décrivez votre emoji',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                hintText: 'Ex: panda Kung Fu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _generate,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Générer'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_generatedUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(_generatedUrl!, height: 200),
                ),
              ),
          ],
        ),
      ),
    );
  }
}