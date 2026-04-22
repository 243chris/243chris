import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:africonnect/core/models/user_model.dart';
import 'package:africonnect/features/messaging/presentation/chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final sent = await _supabase.from('messages')
        .select('receiver_id, messages(*)')
        .eq('sender_id', userId);
    final received = await _supabase.from('messages')
        .select('sender_id, messages(*)')
        .eq('receiver_id', userId);

    final Map<String, Map<String, dynamic>> uniqueConvos = {};
    
    for (final msg in sent) {
      final otherId = msg['receiver_id'] as String;
      if (!uniqueConvos.containsKey(otherId)) {
        uniqueConvos[otherId] = {'user_id': otherId, 'last_message': msg, 'other_user_id': otherId};
      }
    }
    for (final msg in received) {
      final otherId = msg['sender_id'] as String;
      if (!uniqueConvos.containsKey(otherId)) {
        uniqueConvos[otherId] = {'user_id': otherId, 'last_message': msg, 'other_user_id': otherId};
      }
    }

    final convos = uniqueConvos.values.toList();
    
    for (var i = 0; i < convos.length; i++) {
      final otherId = convos[i]['other_user_id'] as String;
      final profile = await _supabase.from('profiles')
          .select()
          .eq('id', otherId)
          .single();
      convos[i]['profile'] = profile;
    }

    setState(() {
      _conversations = convos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? const Center(child: Text('Aucune conversation'))
              : ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final convo = _conversations[index];
                    final profile = convo['profile'] as Map<String, dynamic>?;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profile?['avatar_url'] != null
                            ? NetworkImage(profile!['avatar_url'])
                            : null,
                        child: profile?['avatar_url'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(profile?['username'] ?? 'Utilisateur'),
                      subtitle: Text(convo['last_message']?['content'] ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              userId: convo['other_user_id'] as String,
                              username: profile?['username'] ?? 'Utilisateur',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}