import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/connection_request.dart';
import 'package:amora/features/profile/models/profile_model.dart';
import 'package:amora/core/providers/supabase_provider.dart';

final connectionProvider = Provider<ConnectionRepository>((ref) {
  return ConnectionRepository();
});

final connectionRequestsStreamProvider =
    StreamProvider<List<ConnectionRequest>>((ref) {
      ref.watch(authStateProvider);

      final repo = ref.watch(connectionProvider);
      return repo.getConnectionRequestsStream();
    });

final checkConnectionStatusProvider = FutureProvider.family<String?, String>((
  ref,
  otherId,
) async {
  final repo = ref.watch(connectionProvider);
  return repo.getConnectionStatus(otherId);
});

final acceptedConnectionsStreamProvider =
    StreamProvider<List<ConnectionRequest>>((ref) {
      ref.watch(authStateProvider);

      final repo = ref.watch(connectionProvider);
      return repo.getAcceptedConnectionsStream();
    });

final connectedUserIdsProvider = StreamProvider<Set<String>>((ref) {
  final myId = Supabase.instance.client.auth.currentUser?.id;
  if (myId == null) return Stream.value({});

  return Supabase.instance.client
      .from('connections')
      .stream(primaryKey: ['id'])
      .map((data) {
        final Set<String> ids = {};
        for (var row in data) {
          if (row['sender_id'] == myId) {
            ids.add(row['receiver_id'] as String);
          } else if (row['receiver_id'] == myId) {
            ids.add(row['sender_id'] as String);
          }
        }
        return ids;
      });
});

class ConnectionRepository {
  final _supabase = Supabase.instance.client;

  Stream<List<ConnectionRequest>> getConnectionRequestsStream() {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return Stream.value([]);

    return _supabase
        .from('connections')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) => data
              .where(
                (item) =>
                    item['receiver_id'] == myId && item['status'] == 'pending',
              )
              .toList(),
        )
        .asyncMap((data) async {
          List<ConnectionRequest> requests = [];
          for (var item in data) {
            final senderId = item['sender_id'];
            try {
              final profileRes = await _supabase
                  .from('profiles')
                  .select()
                  .eq('id', senderId)
                  .single();
              var request = ConnectionRequest.fromJson(item);
              requests.add(
                ConnectionRequest(
                  id: request.id,
                  senderId: request.senderId,
                  receiverId: request.receiverId,
                  status: request.status,
                  createdAt: request.createdAt,
                  sender: ProfileModel.fromJson(profileRes),
                ),
              );
            } catch (e) {}
          }
          return requests;
        });
  }

  Stream<List<ConnectionRequest>> getAcceptedConnectionsStream() {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return Stream.value([]);

    return _supabase
        .from('connections')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) => data
              .where((item) => item['status'] == 'accepted')
              .map((item) => ConnectionRequest.fromJson(item))
              .where((req) => req.senderId == myId || req.receiverId == myId)
              .toList(),
        )
        .asyncMap((requests) async {
          List<ConnectionRequest> populated = [];
          for (var req in requests) {
            final otherId = req.senderId == myId
                ? req.receiverId
                : req.senderId;
            try {
              final profileRes = await _supabase
                  .from('profiles')
                  .select()
                  .eq('id', otherId)
                  .single();
              populated.add(
                ConnectionRequest(
                  id: req.id,
                  senderId: req.senderId,
                  receiverId: req.receiverId,
                  status: req.status,
                  createdAt: req.createdAt,
                  sender: req.senderId == otherId
                      ? ProfileModel.fromJson(profileRes)
                      : null,
                  receiver: req.receiverId == otherId
                      ? ProfileModel.fromJson(profileRes)
                      : null,
                ),
              );
            } catch (e) {}
          }
          return populated;
        });
  }

  Future<void> sendConnectionRequest(String receiverId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    final existing = await _supabase
        .from('connections')
        .select()
        .or(
          'and(sender_id.eq.$myId,receiver_id.eq.$receiverId),and(sender_id.eq.$receiverId,receiver_id.eq.$myId)',
        );
    if (existing.isNotEmpty) {
      return;
    }

    await _supabase.from('connections').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'status': 'pending',
    });
  }

  Future<String?> getConnectionStatus(String otherId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return null;

    final response = await _supabase
        .from('connections')
        .select('status')
        .or(
          'and(sender_id.eq.$myId,receiver_id.eq.$otherId),and(sender_id.eq.$otherId,receiver_id.eq.$myId)',
        )
        .maybeSingle();

    if (response == null) return null;
    return response['status'] as String;
  }

  Future<void> acceptRequest(String requestId) async {
    await _supabase
        .from('connections')
        .update({'status': 'accepted'})
        .eq('id', requestId);
  }

  Future<void> rejectRequest(String requestId) async {
    await _supabase
        .from('connections')
        .update({'status': 'rejected'})
        .eq('id', requestId);
  }

  Future<List<String>> getConnectedUserIds() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return [];

    final response = await _supabase
        .from('connections')
        .select('sender_id, receiver_id')
        .or('sender_id.eq.$myId,receiver_id.eq.$myId');

    final Set<String> ids = {};
    for (var row in response as List) {
      if (row['sender_id'] != myId) ids.add(row['sender_id']);
      if (row['receiver_id'] != myId) ids.add(row['receiver_id']);
    }
    return ids.toList();
  }
}
