import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/connection_request.dart';
import 'package:amora/features/profile/models/profile_model.dart';

final connectionProvider = Provider<ConnectionRepository>((ref) {
  return ConnectionRepository();
});

final connectionRequestsStreamProvider =
    StreamProvider<List<ConnectionRequest>>((ref) {
      final repo = ref.watch(connectionProvider);
      return repo.getConnectionRequestsStream();
    });

final acceptedConnectionsStreamProvider =
    StreamProvider<List<ConnectionRequest>>((ref) {
      final repo = ref.watch(connectionProvider);
      return repo.getAcceptedConnectionsStream();
    });

class ConnectionRepository {
  final _supabase = Supabase.instance.client;

  Stream<List<ConnectionRequest>> getConnectionRequestsStream() {
    final myId = _supabase.auth.currentUser!.id;

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
          // Fetch sender profiles manually for each request
          List<ConnectionRequest> requests = [];
          for (var item in data) {
            final senderId = item['sender_id'];
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
          }
          return requests;
        });
  }

  Stream<List<ConnectionRequest>> getAcceptedConnectionsStream() {
    final myId = _supabase.auth.currentUser!.id;

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
          }
          return populated;
        });
  }

  Future<void> sendConnectionRequest(String receiverId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    // check if it already exists to avoid duplicates
    final existing = await _supabase
        .from('connections')
        .select()
        .or(
          'and(sender_id.eq.$myId,receiver_id.eq.$receiverId),and(sender_id.eq.$receiverId,receiver_id.eq.$myId)',
        );
    if (existing.isNotEmpty) {
      return; // Already exists
    }

    await _supabase.from('connections').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'status': 'pending',
    });
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
}
