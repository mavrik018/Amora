import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../models/verification_request_model.dart';
import 'dart:io';

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

  Future<void> submitVerificationRequest(String userId, String idImageUrl) async {
    await _client.from('verification_requests').insert({
      'user_id': userId,
      'id_image_url': idImageUrl,
      'status': 'pending',
    });
  }

  Future<VerificationRequestModel?> getVerificationRequest(String userId) async {
    final response = await _client
        .from('verification_requests')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return VerificationRequestModel.fromJson(response);
  }

  Future<String> uploadVerificationId(String userId, File imageFile) async {
    final fileName = 'id_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$fileName';

    await _client.storage.from('identity_verification').upload(
          path,
          imageFile,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return _client.storage.from('identity_verification').getPublicUrl(path);
  }
}
