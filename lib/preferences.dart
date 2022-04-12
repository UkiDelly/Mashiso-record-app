import 'package:shared_preferences/shared_preferences.dart';

class LoginPreferences {
  static SharedPreferences _preferences = _preferences;

  //key for the user id
  static const _keyUserId = "";

  //create an instance
  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  //set to user id
  static Future saveUserId(String userId) async =>
      await _preferences.setString(_keyUserId, userId);

  //get the user id
  static String getUserId() => _preferences.getString(_keyUserId)!;
}
