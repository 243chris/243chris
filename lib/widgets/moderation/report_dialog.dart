import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportDialog extends StatefulWidget {
  final String targetType;
  final String targetId;

  const ReportDialog({
    Key? key,
    required this.targetType,
    required this.targetId,
  }) : super(key: key);

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _supabase = Supabase.instance.client;
  String? _selectedReason;
  bool _isLoading = false;

  final List<Map<String, String>> _reasons = [
    {'value': 'harassment', 'label': 'Harcèlement'},
    {'value': 'hate_speech', 'label': 'Discours haineux'},
    {'value': 'violence', 'label': 'Violence'},
    {'value': 'spam', 'label': 'Spam'},
    {'value': 'misinformation', 'label': 'Désinformation'},
    {'value': 'inappropriate', 'label': 'Contenu inapproprié'},
  ];

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase.from('reports').insert({
        'reporter_id': userId,
        'target_type': widget.targetType,
        'target_id': widget.targetId,
        'reason': _selectedReason,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merci, nous allons examiner ce signalement.')),
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
    return AlertDialog(
      title: const Text('Signaler ce contenu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(' Pourquoi signalez-vous ce contenu?'),
          const SizedBox(height: 16),
          ..._reasons.map((reason) => RadioListTile<String>(
                title: Text(reason['label']!),
                value: reason['value']!,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() => _selectedReason = value);
                },
              )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedReason == null
              ? null
              : _submitReport,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Signaler'),
        ),
      ],
    );
  }
}