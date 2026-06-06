import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/analisis_model.dart';

/// Servicio principal — se comunica con el backend Django
class AuthService {
  static const String baseUrl =
      'https://cafedetect-grupo05-production.up.railway.app/api/auth';

  static const String _tokenKey = 'auth_token';
  static const String _userKey  = 'auth_user';

  // ─── AUTH ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username':   username,
          'password':   password,
          'email':      email,
          'first_name': firstName,
          'last_name':  lastName,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        await _saveSession(data['token'], data['user']);
        return {'success': true, 'user': UserModel.fromJson(data['user'])};
      }
      return {'success': false, 'error': data['error'] ?? 'Error al registrar'};
    } catch (_) {
      return {'success': false, 'error': 'No se pudo conectar al servidor.'};
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await _saveSession(data['token'], data['user']);
        return {'success': true, 'user': UserModel.fromJson(data['user'])};
      }
      return {'success': false, 'error': data['error'] ?? 'Error desconocido'};
    } catch (_) {
      return {'success': false, 'error': 'No se pudo conectar al servidor.'};
    }
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout/'),
          headers: {'Authorization': 'Token $token'},
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
    await _clearSession();
  }

  // ─── PERFIL ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'error': 'No autenticado'};

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/update_profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Actualizar usuario guardado localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(data));
        return {'success': true, 'user': UserModel.fromJson(data)};
      }
      return {'success': false, 'error': data['error'] ?? 'Error al actualizar'};
    } catch (_) {
      return {'success': false, 'error': 'No se pudo conectar al servidor.'};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'error': 'No autenticado'};

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change_password/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Actualizar token si el backend lo regeneró
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, data['token']);
        }
        return {'success': true};
      }
      return {'success': false, 'error': data['error'] ?? 'Error al cambiar contraseña'};
    } catch (_) {
      return {'success': false, 'error': 'No se pudo conectar al servidor.'};
    }
  }

  // ─── HISTORIAL Y STATS ─────────────────────────────────────────────────────

  Future<List<AnalisisModel>> getHistorial() async {
    final token = await getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/historial/'),
        headers: {'Authorization': 'Token $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => AnalisisModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, int>> getStats() async {
    final token = await getToken();
    if (token == null) return {'total': 0, 'sanos': 0, 'enfermos': 0};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/'),
        headers: {'Authorization': 'Token $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'total':    data['total']    as int,
          'sanos':    data['sanos']    as int,
          'enfermos': data['enfermos'] as int,
        };
      }
    } catch (_) {}
    return {'total': 0, 'sanos': 0, 'enfermos': 0};
  }

  // ─── SESIÓN LOCAL ──────────────────────────────────────────────────────────

  Future<void> _saveSession(String token, Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(userJson));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    return UserModel.fromJson(jsonDecode(userStr));
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
