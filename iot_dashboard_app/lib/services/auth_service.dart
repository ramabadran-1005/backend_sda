import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.150.216.165:4000';
  static const _keyToken = 'auth_token';
  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
  }

  /// Login with backend, store token locally
  Future<bool> login(String username, String password) async {
    await _initPrefs();
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      if (token != null) {
        await _prefs!.setString(_keyToken, token);
        return true;
      }
    }
    return false;
  }

  /// Logout
  Future<void> logout() async {
    await _initPrefs();
    await _prefs!.remove(_keyToken);
  }

  /// Get stored token (null if not logged in)
  Future<String?> getToken() async {
    await _initPrefs();
    return _prefs!.getString(_keyToken);
  }

  /// Check if logged in
  Future<bool> isLoggedIn() async => (await getToken()) != null;
}
