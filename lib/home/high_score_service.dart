import 'package:shared_preferences/shared_preferences.dart';

class HighScoreService {
  static const String _scoreKey = 'aetherius_high_score';
  static const String _levelKey = 'aetherius_highest_level';

  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_scoreKey) ?? 0;
  }

  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_scoreKey) ?? 0;
    if (score > current) {
      await prefs.setInt(_scoreKey, score);
    }
  }

  static Future<int> getHighestLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? 1;
  }

  static Future<void> saveHighestLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_levelKey) ?? 1;
    if (level > current) {
      await prefs.setInt(_levelKey, level);
    }
  }
}
