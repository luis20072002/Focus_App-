import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/utils/token_storage.dart';
import '../models/users.dart';

class AuthService {
  // Devuelve el token si el login fue exitoso, lanza excepcion si falla
  static Future<String> login(String identifier, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': identifier,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Error al iniciar sesion');
    }
  }

  static Future<User> getMe(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.me),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Token invalido o expirado');
    }
  }

  static Future<User> register({
    required String name,
    required String lastname,
    required String username,
    required String password,
    String? email,
    String? phone,
    required String birthDate,
  }) async {
    final body = {
      'name':       name,
      'lastname':   lastname,
      'username':   username,
      'password':   password,
      'birth_date': birthDate,
      'private_profile': false,
    };
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;

    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Error al registrarse');
    }
  }

  static Future<void> logout() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      await http.post(
        Uri.parse(ApiConstants.logout),
        headers: {'Authorization': 'Bearer $token'},
      );
    }
    await TokenStorage.deleteToken();
  }
}