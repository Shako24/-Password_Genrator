import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../middleware/rsa.dart';

class Backend {
  static const String apiUrl = 'http://192.168.0.169:8080';

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt') ?? '';
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwt',
    };
  }

  /// POST /login — saves jwt + server_public_key to SharedPreferences.
  static Future<http.Response> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      if (body['token'] != null) {
        await prefs.setString('jwt', body['token'] as String);
      }
      if (body['server_public_key'] != null) {
        await prefs.setString(
            'server_public_key', body['server_public_key'] as String);
      } else if (body['publicKey'] != null) {
        await prefs.setString('server_public_key', body['publicKey'] as String);
      }
    }
    return res;
  }

  /// POST /generate-password — password is RSA-OAEP-SHA256 encrypted in transit.
  static Future<http.Response> generatePassword(
      String site, String username, String password) async {
    final encrypted = await rsaOaepEncrypt(password);
    return http.post(
      Uri.parse('$apiUrl/generate-password'),
      headers: await _authHeaders(),
      body: jsonEncode(
          {'site': site, 'username': username, 'password': encrypted}),
    );
  }

  /// POST /save-password — new entry.
  static Future<http.Response> savePassword(
      String site, String username, String password) async {
    return http.post(
      Uri.parse('$apiUrl/save-password'),
      headers: await _authHeaders(),
      body: jsonEncode(
          {'site': site, 'username': username, 'password': password}),
    );
  }

  /// PUT /save-password — update existing entry.
  static Future<http.Response> updatePassword(
      String site, String username, String password) async {
    return http.put(
      Uri.parse('$apiUrl/save-password'),
      headers: await _authHeaders(),
      body: jsonEncode(
          {'site': site, 'username': username, 'password': password}),
    );
  }

  /// POST /show-password → List<{userName, password}>
  static Future<List<dynamic>> getPassword(String site) async {
    final res = await http.post(
      Uri.parse('$apiUrl/show-password'),
      headers: await _authHeaders(),
      body: jsonEncode({'site': site}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('getPassword failed: ${res.statusCode}');
  }

  /// GET /show-sites → List<String>
  static Future<List<dynamic>> getSites() async {
    final res = await http.get(
      Uri.parse('$apiUrl/show-sites'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('getSites failed: ${res.statusCode}');
  }

  /// POST /show-selected-sites → List<String>
  static Future<List<dynamic>> getSelectedSites(String query) async {
    final res = await http.post(
      Uri.parse('$apiUrl/show-selected-sites'),
      headers: await _authHeaders(),
      body: jsonEncode({'site': query}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('getSelectedSites failed: ${res.statusCode}');
  }
}
