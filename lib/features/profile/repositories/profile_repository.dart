import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<void> createProfile(ProfileModel profile) async {
    await _client.from('profiles').upsert(profile.toJson());
  }

  Future<ProfileModel?> getProfile(String id) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .single();

    return ProfileModel.fromJson(response);
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }

  Future<void> updateStatus(String id, String status) async {
    await _client
        .from('profiles')
        .update({'status_today': status})
        .eq('id', id);
  }
}
