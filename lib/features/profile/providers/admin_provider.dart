import 'package:amora/core/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

final adminProvider = Provider((ref) => AdminRepository());

/// Streams only non-dismissed reports, ordered newest first.
/// Supabase .stream() doesn't support .eq() filters, so we filter client-side.
final reportsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return Supabase.instance.client
      .from('user_reports')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((rows) =>
          rows.where((r) => r['is_dismissed'] != true).toList());
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
}
