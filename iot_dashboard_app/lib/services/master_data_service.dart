import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/master_data_model.dart';

class MasterDataService {
  final String apiUrl = 'http://10.150.216.165:4000/api/masterdata';

  Future<List<MasterData>> fetchMasterData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => MasterData.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load master data');
    }
  }
}
