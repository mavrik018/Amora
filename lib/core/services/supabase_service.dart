import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  GoTrueClient get auth => client.auth;

  Future<void> signOut() async {
    await auth.signOut();
  }

  User? get user => auth.currentUser;
  Session? get session => auth.currentSession;

  Future<List<Map<String, dynamic>>> getProfiles() async {
    final userID = user?.id;
    print('Current userID: $userID');
    if (userID == null) {
      print('User not logged in, returning empty list');
      return [];
    }
    print('Fetching profiles excluding userID: $userID');
    final response = await client.from('profiles').select().neq('id', userID);
    print('Raw response from Supabase: $response');
    final profiles = List<Map<String, dynamic>>.from(response);
    print('Parsed profiles: $profiles');
    return profiles;
  }
}
