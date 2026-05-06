import 'package:amora/features/chat/screens/chat_list_screen.dart';
import 'package:amora/features/chat/screens/chat_thread_screen.dart';
import 'package:amora/features/notifications/models/notification_model.dart';
import 'package:amora/features/notifications/providers/notification_provider.dart';
import 'package:amora/features/notifications/widgets/notification_overlay.dart';
import 'package:amora/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationLayer extends ConsumerWidget {
  const NotificationLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    if (notifications.isEmpty) return const SizedBox.shrink();

    final latest = notifications.last;

    return NotificationOverlay(
      key: ValueKey(latest.id),
      notification: latest,
      onDismiss: () {
        ref.read(notificationProvider.notifier).removeNotification(latest.id);
      },
      onTap: () {
        ref.read(notificationProvider.notifier).removeNotification(latest.id);

        final context = navigatorKey.currentContext;
        if (context == null) return;

        if (latest.type == NotificationType.message && latest.sender != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatThreadScreen(otherProfile: latest.sender!),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatListScreen()),
          );
        }
      },
    );
  }
}
