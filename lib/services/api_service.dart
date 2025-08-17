import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store.dart';

class ApiService {
  final String _apiUrl = 'https://mediquery-server.onrender.com';

  Future<Map<String, dynamic>> fetchStores(String location, int radius) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/api/medical-stores'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'location': location, 'radius': radius}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] && data['data'] != null && data['data']['stores'] != null) {
        final stores = (data['data']['stores'] as List)
            .map((storeJson) => Store.fromJson(storeJson))
            .toList();
        return {
          'stores': stores,
          'location_name': data['data']['location']['name'] ?? location,
        };
      } else {
        throw Exception(data['data']['message']?['text'] ?? 'Could not find any stores.');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}