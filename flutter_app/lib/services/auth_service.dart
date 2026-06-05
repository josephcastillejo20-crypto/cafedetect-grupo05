import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Servicio de autenticación — se comunica con el backend Django
class AuthService {

  static const String baseUrl = 'https://cafedetect-grupo05-production.up.railway.app/api/auth';

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  // ─── LOGIN ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Guardar token y usuario localmente
        await _saveSession(data['token'], data['user']);
        return {'success': true, 'user': UserModel.fromJson(data['user'])};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Error desconocido'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'No se pudo conectar al servidor.\n'
            'Verifica que el backend esté corriendo.',
      };
    }
  }

  // ─── LOGOUT ──────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        ).timeout(const Duration(seconds: 5));
      } catch (_) {
        // Si falla el servidor igual limpiamos local
      }
    }
    await _clearSession();
  }

  // ─── SESIÓN LOCAL ────────────────────────────────────────────────────────
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
