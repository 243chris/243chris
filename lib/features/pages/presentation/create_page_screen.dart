import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePageScreen extends StatefulWidget {
  const CreatePageScreen({Key? key}) : super(key: key);

  @override
  _CreatePageScreenState createState() => _CreatePageScreenState();
}

class _CreatePageScreenState extends State<CreatePageScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'business';
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'value': 'business', 'label': 'Business'},
    {'value': 'education', 'label': 'Éducation'},
    {'value': 'entertainment', 'label': 'Divertissement'},
    {'value': 'technology', 'label': 'Technologie'},
    {'value': 'community', 'label': 'Communauté'},
  ];

  Future<void> _createPage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      final slug = _nameController.text.trim().toLowerCase().replaceAll(' ', '-');

      await _supabase.from('pages').insert({
        'name': _nameController.text.trim(),
        'slug': slug,
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'owner_id': userId,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Page créée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer une page')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de la page',
                prefixIcon: Icon(Icons.pages),
              ),
              validator: (value) =>
                  value!.isEmpty ? ' required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat['value'],
                        child: Text(cat['label']!),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _createPage,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Créer la page'),
            ),
          ],
        ),
      ),
    );
  }
}