import 'package:amora/features/profile/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  GoTrueClient get auth => client.auth;

  Future<void> signOut() async {
    await auth.signOut();
  }

  User? get user => auth.currentUser;
  Session? get session => auth.currentSession;

  Future<List<ProfileModel>> getProfiles() async {
    final userID = user?.id;
    if (userID == null) return [];

    final response = await client.from('profiles').select().neq('id', userID);
    return List<ProfileModel>.from(
      (response as List).map((x) => ProfileModel.fromJson(x)),
    );
  }

  Future<List<ProfileModel>> getRecommendedProfiles({
    required String? gender,
    required int minAge,
    required int maxAge,
    required double lat,
    required double lng,
    required double radiusKm,
    required bool verifiedOnly,
  }) async {
    final userID = user?.id;
    if (userID == null) return [];

    final response = await client.rpc(
      'get_recommended_profiles',
      params: {
        'p_user_id': userID,
        'p_gender': gender,
        'p_min_age': minAge,
        'p_max_age': maxAge,
        'p_lat': lat,
        'p_lng': lng,
        'p_radius_km': radiusKm,
        'p_verified_only': verifiedOnly,
      },
    );

    return List<ProfileModel>.from(
      (response as List).map((x) => ProfileModel.fromJson(x)),
    );
  }

  Future<List<String>> getConnectedUserIds() async {
    final userID = user?.id;
    if (userID == null) return [];

    final response = await client
        .from('connections')
        .select('sender_id, receiver_id')
        .or('sender_id.eq.$userID,receiver_id.eq.$userID');

    final Set<String> ids = {};
    for (var row in response as List) {
      if (row['sender_id'] != userID) ids.add(row['sender_id']);
      if (row['receiver_id'] != userID) ids.add(row['receiver_id']);
    }
    return ids.toList();
  }
}
