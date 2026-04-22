import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:africonnect/core/services/ai_service.dart';

class CaricatureGeneratorScreen extends StatefulWidget {
  const CaricatureGeneratorScreen({Key? key}) : super(key: key);

  @override
  _CaricatureGeneratorScreenState createState() =>
      _CaricatureGeneratorScreenState();
}

class _CaricatureGeneratorScreenState extends State<CaricatureGeneratorScreen> {
  final _aiService = AIService();
  File? _selectedImage;
  bool _isGenerating = false;
  String? _generatedImageUrl;
  String? _errorMessage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _generatedImageUrl = null;
        _errorMessage = null;
      });
    }
  }

  Future<void> _generateCaricature() async {
    if (_selectedImage == null) return;

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final bytes = await _selectedImage!.readAsBytes();
      final fileName = 'input_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('ai_inputs').uploadBinary(fileName, bytes);
      final imageUrl = supabase.storage.from('ai_inputs').getPublicUrl(fileName);

      final result = await _aiService.generateCaricature(imageUrl);
      setState(() {
        _generatedImageUrl = result;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isGenerating = false;
      });
    }
  }

  Future<void> _shareCaricature() async {
    if (_generatedImageUrl == null) return;
    final supabase = Supabase.instance.client;
    await supabase.from('posts').insert({
      'user_id': supabase.auth.currentUser!.id,
      'media_urls': [_generatedImageUrl],
      'media_type': 'image',
      'content': 'Une caricature générée par IA #AfriConnect',
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caricature publiée!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générateur de Caricature'),
        actions: [
          if (_generatedImageUrl != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareCaricature,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Transformez une photo en caricature',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 50),
                      Text('Sélectionnez une photo'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Choisir une image'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedImage != null)
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateCaricature,
                icon: _isGenerating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating
                    ? 'Génération en cours...'
                    : 'Générer la caricature'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.purple,
                ),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            if (_generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    const Text('Résultat:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(_generatedImageUrl!, height: 300),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}