import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  GoTrueClient get auth => client.auth;

  Future<void> signOut() async {
    await auth.signOut();
  }

  User? get user => auth.currentUser;
  Session? get session => auth.currentSession;
}
