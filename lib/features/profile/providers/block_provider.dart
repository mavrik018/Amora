import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:amora/core/providers/supabase_provider.dart';

final blockRepositoryProvider = Provider<BlockRepository>((ref) {
  return BlockRepository();
});

final blockedUserIdsProvider = StreamProvider<Set<String>>((ref) {
  final myId = Supabase.instance.client.auth.currentUser?.id;
  if (myId == null) return Stream.value({});

  return Supabase.instance.client
      .from('user_blocks')
      .stream(primaryKey: ['id'])
      .eq('user_id', myId)
      .map((data) {
        return data.map((row) => row['blocked_id'] as String).toSet();
      });
});

class BlockRepository {
  final _supabase = Supabase.instance.client;

  Future<void> blockUser(String blockedId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    await _supabase.from('user_blocks').upsert({
      'user_id': myId,
      'blocked_id': blockedId,
    });
  }

  Future<void> reportUser({
    required String reportedId,
    required String reason,
    String? description,
    File? evidenceImage,
  }) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    String? evidenceUrl;

    if (evidenceImage != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'report_evidence/$myId/$fileName';

      await _supabase.storage.from('reports').upload(
            path,
            evidenceImage,
          );

      evidenceUrl = _supabase.storage.from('reports').getPublicUrl(path);
    }

    await _supabase.from('user_reports').insert({
      'reporter_id': myId,
      'reported_id': reportedId,
      'reason': reason,
      'description': description,
      'evidence_url': evidenceUrl,
    });

    await blockUser(reportedId);
  }

  Future<void> unblockUser(String blockedId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    await _supabase
        .from('user_blocks')
        .delete()
        .eq('user_id', myId)
        .eq('blocked_id', blockedId);
  }
}
