import 'dart:async';
import 'package:amora/features/profile/models/profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../chat/providers/chat_provider.dart';
import '../models/notification_model.dart';

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
      return NotificationNotifier(ref);
    });

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  final Ref _ref;
  RealtimeChannel? _messageChannel;
  RealtimeChannel? _connectionChannel;
  ProviderSubscription? _authSubscription;

  NotificationNotifier(this._ref) : super([]) {
    _init();
  }

  void _init() {
    _authSubscription = _ref.listen(authStateProvider, (previous, next) {
      final state = next;
      if (state is AsyncData) {
        final data = state.value;
        if (data.session != null) {
          _subscribeToNotifications(data.session!.user.id);
        } else {
          _unsubscribeAll();
        }
      } else if (state is AsyncError) {
        _unsubscribeAll();
      }
    }, fireImmediately: true);
  }

  void _subscribeToNotifications(String userId) {
    final supabase = _ref.read(supabaseClientProvider);

    // Subscribe to messages
    _messageChannel = supabase
        .channel('public:messages_notif')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) async {
            final senderId = payload.newRecord['sender_id'];
            final content = payload.newRecord['content'];

            // Don't show notification if we are already in this chat
            if (_ref.read(activeChatIdProvider) == senderId) return;

            final senderProfile = await _getSenderProfile(senderId);

            _addNotification(
              AppNotification(
                id: payload.newRecord['id'],
                type: NotificationType.message,
                title: senderProfile?.fullName ?? 'New Message',
                body: content,
                createdAt: DateTime.now(),
                sender: senderProfile,
                data: payload.newRecord,
              ),
            );
          },
        )
        .subscribe();

    // Subscribe to connection requests
    _connectionChannel = supabase
        .channel('public:connections_notif')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'connections',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) async {
            if (payload.newRecord['status'] != 'pending') return;

            final senderId = payload.newRecord['sender_id'];
            final senderProfile = await _getSenderProfile(senderId);

            _addNotification(
              AppNotification(
                id: payload.newRecord['id'],
                type: NotificationType.connectionRequest,
                title: 'New Connection Request',
                body:
                    '${senderProfile?.fullName ?? "Someone"} wants to connect with you!',
                createdAt: DateTime.now(),
                sender: senderProfile,
                data: payload.newRecord,
              ),
            );
          },
        )
        .subscribe();
  }

  Future<ProfileModel?> _getSenderProfile(String senderId) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', senderId)
          .single();
      return ProfileModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  void _addNotification(AppNotification notification) {
    state = [...state, notification];
  }

  void removeNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void _unsubscribeAll() {
    _messageChannel?.unsubscribe();
    _connectionChannel?.unsubscribe();
    state = [];
  }

  @override
  void dispose() {
    _authSubscription?.close();
    _unsubscribeAll();
    super.dispose();
  }
}
