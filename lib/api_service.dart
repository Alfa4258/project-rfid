import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Replace with your API base URL

  Future<Map<String, dynamic>?> fetchBibDetails(String bibNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/bib/$bibNumber')); // Adjust the endpoint as necessary

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load BIB details');
    }
  }
}
