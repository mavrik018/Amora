import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import '../../../core/providers/supabase_provider.dart';

final chatProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatStreamProvider = StreamProvider.family<List<Message>, String>((
  ref,
  receiverId,
) {
  ref.watch(authStateProvider);

  final chatRepo = ref.watch(chatProvider);
  return chatRepo.getChatStream(receiverId);
});

final activeChatIdProvider = StateProvider<String?>((ref) => null);

final unreadCountProvider = StreamProvider.family<int, String>((ref, senderId) {
  final myId = Supabase.instance.client.auth.currentUser?.id;
  if (myId == null) return Stream.value(0);

  return Supabase.instance.client
      .from('messages')
      .stream(primaryKey: ['id'])
      .map(
        (data) => data
            .where(
              (msg) =>
                  msg['receiver_id'] == myId &&
                  msg['sender_id'] == senderId &&
                  msg['is_read'] == false,
            )
            .length,
      );
});

final latestMessageProvider = StreamProvider.family<Message?, String>((
  ref,
  otherId,
) {
  final myId = Supabase.instance.client.auth.currentUser?.id;
  if (myId == null) return Stream.value(null);

  return Supabase.instance.client
      .from('messages')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((data) {
        final messages = data
            .map((json) => Message.fromJson(json))
            .where(
              (msg) =>
                  (msg.senderId == myId && msg.receiverId == otherId) ||
                  (msg.senderId == otherId && msg.receiverId == myId),
            )
            .toList();
        return messages.isNotEmpty ? messages.first : null;
      });
});

class ChatRepository {
  final _supabase = Supabase.instance.client;

  Stream<List<Message>> getChatStream(String receiverId) {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return Stream.value([]);

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) => data
              .map((json) => Message.fromJson(json))
              .where(
                (msg) =>
                    (msg.senderId == myId && msg.receiverId == receiverId) ||
                    (msg.senderId == receiverId && msg.receiverId == myId),
              )
              .toList(),
        );
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

  Future<void> markConversationAsRead(String senderId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('receiver_id', myId)
        .eq('sender_id', senderId)
        .eq('is_read', false);
  }
}
