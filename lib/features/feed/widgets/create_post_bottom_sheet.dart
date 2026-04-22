import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:africonnect/core/config/app_config.dart';

class CreatePostBottomSheet extends StatefulWidget {
  final VoidCallback onPostCreated;

  const CreatePostBottomSheet({Key? key, required this.onPostCreated})
      : super(key: key);

  @override
  _CreatePostBottomSheetState createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final _contentController = TextEditingController();
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();
  List<String> _mediaUrls = [];
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    for (final image in images) {
      final bytes = await image.readAsBytes();
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from('posts').uploadBinary(fileName, bytes);
      final url = _supabase.storage.from('posts').getPublicUrl(fileName);
      _mediaUrls.add(url);
    }
    setState(() {});
  }

  Future<void> _createPost() async {
    if (_contentController.text.isEmpty && _mediaUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter du contenu ou une image')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final mediaType = _mediaUrls.isNotEmpty ? 'image' : 'none';
      await _supabase.from('posts').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'content': _contentController.text,
        'media_urls': _mediaUrls.isNotEmpty ? _mediaUrls : null,
        'media_type': mediaType,
      });
      widget.onPostCreated();
      if (mounted) Navigator.pop(context);
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nouveau post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLength: AppConfig.maxPostLength,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Qu\'avez-vous en tête?',
                border: OutlineInputBorder(),
              ),
            ),
            if (_mediaUrls.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mediaUrls.length,
                  itemBuilder: (context, index) => Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.network(
                          _mediaUrls[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() => _mediaUrls.removeAt(index));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImages,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createPost,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Publier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}