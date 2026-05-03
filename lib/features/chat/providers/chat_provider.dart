import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';

final chatProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatStreamProvider = StreamProvider.family<List<Message>, String>((ref, receiverId) {
  final chatRepo = ref.watch(chatProvider);
  return chatRepo.getChatStream(receiverId);
});

class ChatRepository {
  final _supabase = Supabase.instance.client;

  Stream<List<Message>> getChatStream(String receiverId) {
    final myId = _supabase.auth.currentUser!.id;

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) => data
            .map((json) => Message.fromJson(json))
            .where((msg) =>
                (msg.senderId == myId && msg.receiverId == receiverId) ||
                (msg.senderId == receiverId && msg.receiverId == myId))
            .toList());
  }

  Future<void> sendMessage(String receiverId, String content) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;
    
    await _supabase.from('messages').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'content': content,
    });
  }

  Future<void> markAsRead(String messageId) async {
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('id', messageId);
  }
}
