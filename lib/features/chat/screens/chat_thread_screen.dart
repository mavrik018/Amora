import 'package:amora/features/profile/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/chat_provider.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  final ProfileModel otherProfile;
  const ChatThreadScreen({super.key, required this.otherProfile});

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeChatIdProvider.notifier).state = widget.otherProfile.id;
      ref.read(chatProvider).markConversationAsRead(widget.otherProfile.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    Future.microtask(() {
      if (mounted) {
        ref.read(activeChatIdProvider.notifier).state = null;
      }
    });
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatProvider).sendMessage(widget.otherProfile.id, text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen(chatStreamProvider(widget.otherProfile.id), (previous, next) {
      if (next.hasValue) {
        final messages = next.value!;
        if (messages.any(
          (m) => m.senderId == widget.otherProfile.id && !m.isRead,
        )) {
          ref.read(chatProvider).markConversationAsRead(widget.otherProfile.id);
        }
      }
    });

    final chatStreamAsync = ref.watch(
      chatStreamProvider(widget.otherProfile.id),
    );
    final myId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundImage: widget.otherProfile.photos.isNotEmpty
                  ? NetworkImage(widget.otherProfile.photos.first)
                  : null,
              child: widget.otherProfile.photos.isNotEmpty
                  ? null
                  : const Icon(Icons.person, size: 16),
            ),
            SizedBox(width: 12.w),
            Text(widget.otherProfile.fullName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatStreamAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('Say hi!'));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == myId;
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? theme.primaryColor
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20.r).copyWith(
                            bottomRight: isMe ? const Radius.circular(0) : null,
                            bottomLeft: !isMe ? const Radius.circular(0) : null,
                          ),
                        ),
                        child: Text(
                          msg.content,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: CircleAvatar(
                      radius: 24.r,
                      backgroundColor: theme.primaryColor,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
