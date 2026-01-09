// lib/services/master_data_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/master_data_model.dart';

class MasterDataService {
  final String apiUrl = 'http://10.150.216.165:4000/api/masterdata';

  Future<List<MasterData>> fetchMasterData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) {
          try {
            return MasterData.fromJson(e);
          } catch (_) {
            return null;
          }
        }).whereType<MasterData>().toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API fetch error: $e');
    }
  }
}
