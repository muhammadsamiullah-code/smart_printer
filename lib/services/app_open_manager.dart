
import 'package:shared_preferences/shared_preferences.dart';

class AppOpenManager {
  static const String _key = "app_open_count";

  /// increment count
  static Future<int> incrementAndGetCount() async {
    final prefs = await SharedPreferences.getInstance();

    int count = prefs.getInt(_key) ?? 0;
    count++;

    await prefs.setInt(_key, count);

    return count;
  }
}