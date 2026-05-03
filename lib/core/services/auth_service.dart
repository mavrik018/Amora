import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static const String _userKey = 'logged_in_user_id';
  static const String _loginFlagKey = 'is_logged_in';

  static Future<void> persistLogin(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginFlagKey, true);
    await prefs.setString(_userKey, userId);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await Supabase.instance.client.auth.signOut();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasFlag = prefs.getBool(_loginFlagKey) ?? false;
    
    final session = Supabase.instance.client.auth.currentSession;
    
    return hasFlag && session != null;
  }
}
