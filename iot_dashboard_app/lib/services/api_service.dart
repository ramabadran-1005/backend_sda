import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/master_data_model.dart';
import 'auth_service.dart';

class ApiService {
  // Make sure this matches your backend IP + port
  static const String baseUrl = 'http://10.150.216.165:4000';
  static final AuthService _auth = AuthService();

  static Future<List<MasterData>> fetchMasterData() async {
    final token = await _auth.getToken();
    if (token == null) throw Exception('User not logged in');

    // ✅ FIX: route must be /api/masterdata (no hyphen)
    final response = await http.get(
      Uri.parse('$baseUrl/api/masterdata'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => MasterData.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch master data: ${response.statusCode}');
    }
  }
}
