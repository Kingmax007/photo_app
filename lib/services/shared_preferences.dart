import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<bool> setSharedPreferencesString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  Future<String> getSharedPreferencesString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getString(key) ?? '');
  }

  deleteSharedPreferencesItem(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
