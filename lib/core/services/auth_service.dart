import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static const String _userKey = 'logged_in_user_id';
  static const String _loginFlagKey = 'is_logged_in';

  /// Saves the user session to local storage
  static Future<void> persistLogin(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginFlagKey, true);
    await prefs.setString(_userKey, userId);
  }

  /// Clears all local and remote session data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Safely clear all local data
    await Supabase.instance.client.auth.signOut();
  }

  /// Determines if the user is truly logged in by checking both 
  /// local storage and the Supabase session.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasFlag = prefs.getBool(_loginFlagKey) ?? false;
    
    // Check if Supabase has a valid session
    final session = Supabase.instance.client.auth.currentSession;
    
    // It's only "Safe" if the local flag and Supabase session both exist
    return hasFlag && session != null;
  }
}
