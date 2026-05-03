import 'package:amora/core/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../models/verification_request_model.dart';

final adminProvider = Provider((ref) => AdminRepository());

/// Streams only non-dismissed reports, ordered newest first.
/// Supabase .stream() doesn't support .eq() filters, so we filter client-side.
final reportsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return Supabase.instance.client
      .from('user_reports')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((rows) => rows.where((r) => r['is_dismissed'] != true).toList());
});

final pendingVerificationsProvider =
    StreamProvider<List<VerificationRequestModel>>((ref) {
  return Supabase.instance.client
      .from('verification_requests')
      .stream(primaryKey: ['id'])
      .eq('status', 'pending')
      .order('created_at', ascending: false)
      .asyncMap((rows) async {
    // Since .stream() doesn't support joins easily, we might need to fetch profile names separately 
    // or just rely on the model to handle it if we can join in a future.
    // For now, let's fetch the data including profiles using a regular query if needed, 
    // but stream is better for real-time.
    final List<VerificationRequestModel> requests = [];
    for (var row in rows) {
      // Get profile name for each request
      final profileRes = await Supabase.instance.client
          .from('profiles')
          .select('full_name')
          .eq('id', row['user_id'])
          .single();
      
      final data = Map<String, dynamic>.from(row);
      data['profiles'] = profileRes;
      requests.add(VerificationRequestModel.fromJson(data));
    }
    return requests;
  });
});

class AdminRepository {
  final _supabase = Supabase.instance.client;

  Future<void> toggleBanStatus(String userId, bool isBanned) async {
    await _supabase
        .from('profiles')
        .update({'is_banned': isBanned}).eq('id', userId);
  }

  Future<ProfileModel?> getProfile(String id) async {
    final res =
        await _supabase.from('profiles').select().eq('id', id).single();
    return ProfileModel.fromJson(res);
  }

  /// Sets is_dismissed = true on the given report row.
  Future<void> dismissReport(String reportId) async {
    await _supabase
        .from('user_reports')
        .update({'is_dismissed': true}).eq('id', reportId);
  }

  Future<void> approveVerification(String requestId, String userId) async {
    await _supabase.rpc('approve_verification', params: {
      'p_request_id': requestId,
      'p_user_id': userId,
    });
  }

  Future<void> rejectVerification(
      String requestId, String reason) async {
    await _supabase.from('verification_requests').update({
      'status': 'rejected',
      'rejection_reason': reason,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }
}
