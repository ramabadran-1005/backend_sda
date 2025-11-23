// lib/core/api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Change backend IP here only.
const String API_BASE = 'http://10.100.75.165:4000';

/// Generic GET returning a List<dynamic>
Future<List<dynamic>> apiGetList(String path) async {
  try {
    final res = await http.get(Uri.parse('$API_BASE$path'));
    if (res.statusCode == 200) {
      return json.decode(res.body) as List<dynamic>;
    }
  } catch (e) {
    debugPrint('GET $path error: $e');
  }
  return [];
}

/// Generic GET returning Map<String, dynamic>
Future<Map<String, dynamic>?> apiGetJson(String path) async {
  try {
    final res = await http.get(Uri.parse('$API_BASE$path'));
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
  } catch (e) {
    debugPrint('GET $path error: $e');
  }
  return null;
}

/// POST JSON -> returns response map or null
Future<Map<String, dynamic>?> apiPostJson(String path, Map<String, dynamic> body) async {
  try {
    final res = await http.post(
      Uri.parse('$API_BASE$path'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
  } catch (e) {
    debugPrint('POST $path error: $e');
  }
  return null;
}
