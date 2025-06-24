import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _lastActivityKey = 'last_activity';
  static const int _sessionTimeoutDays = 30;

  // Update last activity timestamp
  static Future<void> updateLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Check if session is expired
  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivityMillis = prefs.getInt(_lastActivityKey);
    
    if (lastActivityMillis == null) return true; // No previous session
    
    final lastActivity = DateTime.fromMillisecondsSinceEpoch(lastActivityMillis);
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    
    return difference.inDays > _sessionTimeoutDays;
  }

  // Clear session data
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActivityKey);
  }
}
