import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:africonnect/core/models/message_model.dart';

class MessagingProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMessages(String otherUserId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabase.from('messages')
          .select()
          .or('and(sender_id.eq.$userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$userId)')
          .order('created_at', ascending: true);
      _messages = (response as List).map((j) => MessageModel.fromJson(j)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String receiverId, String content) async {
    try {
      await _supabase.from('messages').insert({
        'sender_id': _supabase.auth.currentUser!.id,
        'receiver_id': receiverId,
        'content': content,
      });
      await fetchMessages(receiverId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String senderId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('messages')
        .update({'is_read': true})
        .eq('receiver_id', userId)
        .eq('sender_id', senderId);
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final sent = await _supabase.from('messages')
        .select('receiver_id, messages(*)')
        .eq('sender_id', userId);
    final received = await _supabase.from('messages')
        .select('sender_id, messages(*)')
        .eq('receiver_id', userId);

    final Map<String, Map<String, dynamic>> unique = {};
    for (final msg in sent) {
      unique[msg['receiver_id'] as String] = {'user_id': msg['receiver_id'], 'last_message': msg};
    }
    for (final msg in received) {
      unique[msg['sender_id'] as String] = {'user_id': msg['sender_id'], 'last_message': msg};
    }
    return unique.values.toList();
  }
}