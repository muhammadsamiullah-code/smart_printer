
import 'package:shared_preferences/shared_preferences.dart';

class RatingManager {
  static const String launchCountKey = "launch_count";
  static const String fiveStarRatedKey = "five_star_rated";

  static Future<bool> shouldShowRatingDialog() async {
    final prefs = await SharedPreferences.getInstance();

    bool hasRatedFiveStar =
        prefs.getBool(fiveStarRatedKey) ?? false;

    if (hasRatedFiveStar) {
      return false;
    }

    int launchCount = prefs.getInt(launchCountKey) ?? 0;
    launchCount++;

    await prefs.setInt(launchCountKey, launchCount);

    return launchCount % 4 == 0;
  }

  static Future<void> saveFiveStarRating() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(fiveStarRatedKey, true);
  }
}