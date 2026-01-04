import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../middleware/rsa.dart';

class Backend {
  static const String apiUrl = 'http://192.168.0.169:8080';

  /// /////////////////////////////////////////////////
  /// Password Generator and Encryptor Functionality
  /// /////////////////////////////////////////////////

  /// ignore: non_constant_identifier_names
  static Future<http.Response> generate_password(
      site, username, password) async {
    final url = Uri.parse('$apiUrl/generate-password');

    final String encryptedPassword = await rsaOaepEncrypt(password);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'site': site,
        'username': username,
        'password': encryptedPassword ?? '',
      }),
    );

    return response;
  }

  static Future<http.Response> save_password(
      site, username, password, decPass, option) async {
    final url = Uri.parse('$apiUrl/save-password');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'site': site,
        'username': username,
        'password': password,
        'dec_pass': decPass,
        'option': option,
      }),
    );

    return response;
  }

  static Future<http.Response> getPassword(site, decPass) async {
    final url = Uri.parse('$apiUrl/show-password');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{'site': site, 'dec_pass': decPass},
      ),
    );

    return response;
  }

  static Future<List<dynamic>> getSites() async {
    final url = Uri.parse('$apiUrl/show-sites');

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final List<dynamic> sitesData = data;
      // if (kDebugMode) {
      //   print(sitesData);
      // }
      return sitesData;
    } else {
      throw Exception('Failed to fetch Sites Data');
    }
  }

  static Future<List<dynamic>> getSelectedSites(siteName) async {
    final url = Uri.parse('$apiUrl/show-selected-sites');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'site': siteName
      }
      )
    );

    print("The status code is ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final List<dynamic> sitesData = data;
      
      print(sitesData);

      return sitesData;
    } else {
      throw Exception('Failed to fetch Sites Data');
    }
  }

  /// ///////////////////////////////////
  /// User Credentials Feature
  /// ///////////////////////////////////

  Future<void> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', token);
      print("Registered successfully. Token saved.");
    } else {
      print("Error: ${response.body}");
    }
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', token);
      print("Logged in successfully. Token saved.");
    } else {
      print("Error: ${response.body}");
    }
  }
}


