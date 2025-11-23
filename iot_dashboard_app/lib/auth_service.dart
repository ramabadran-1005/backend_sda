import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyUser = 'iot_user';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> login(String username, String password) async {
    if (_prefs == null) await init();
    final stored = _prefs!.getString('user_$username');
    if (stored == null || stored != password) return false;
    await _prefs!.setString(_keyUser, username);
    return true;
  }

  Future<void> logout() async {
    if (_prefs == null) await init();
    await _prefs!.remove(_keyUser);
  }

  Future<String?> getToken() async {
    if (_prefs == null) await init();
    return _prefs!.getString(_keyUser);
  }
}
