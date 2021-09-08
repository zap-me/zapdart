import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<bool> getBool(String key, bool defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setString(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null)
      prefs.remove(key);
    else
      prefs.setString(key, value);
  }

  Future<String?> getString(String key, String? defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }

  Future<bool> nukeAll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
