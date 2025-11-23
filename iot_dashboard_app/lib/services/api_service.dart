// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  /// Change ONLY this if your backend moves.
  /// For mobile testing ensure this is your laptop IP, not 127.0.0.1.
  static String base = 'http://10.100.75.165:4000';

  static Uri _uri(String path) => Uri.parse('$base$path');

  /// ----------------------- GET REQUEST -----------------------
  static Future<List<dynamic>> getList(String path) async {
    try {
      final res = await http
          .get(_uri(path))
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is List) return decoded;
      }

      debugPrint('GET $path failed → ${res.statusCode} ${res.body}');
    } catch (e) {
      debugPrint('GET $path error → $e');
    }
    return [];
  }

  /// ----------------------- GET SINGLE MAP -----------------------
  static Future<Map<String, dynamic>?> getMap(String path) async {
    try {
      final res = await http
          .get(_uri(path))
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
      }

      debugPrint('GET MAP $path failed → ${res.statusCode}');
    } catch (e) {
      debugPrint('GET MAP $path error → $e');
    }
    return null;
  }

  /// ----------------------- POST -----------------------
  static Future<Map<String, dynamic>?> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(
            _uri(path),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return json.decode(res.body) as Map<String, dynamic>;
      }

      debugPrint('POST $path failed → ${res.statusCode} ${res.body}');
    } catch (e) {
      debugPrint('POST $path error → $e');
    }
    return null;
  }

  /// ----------------------- DEBUG LOG -----------------------
  static void showErrorSnack(context, String msg) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (_) {
      debugPrint('SnackBar error: $msg');
    }
  }
}
