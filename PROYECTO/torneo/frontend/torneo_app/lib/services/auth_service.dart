// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _token;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  // Constructor: carga el estado desde SharedPreferences
  AuthService() {
    _loadAuthData();
  }

  // Cargar datos de sesión al iniciar la app
  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userData = prefs.getString('user_data');

    print('🔐 Token en SharedPreferences: $token');
    print('👥 User data en SharedPreferences: $userData');

    if (token != null && userData != null) {
      _token = token;
      try {
        _user = Map<String, dynamic>.from((jsonDecode(userData) as Map).cast<String, dynamic>());
        _isAuthenticated = true;
        print('✅ Usuario autenticado automáticamente');
      } on FormatException catch (e) {
        print('❌ Error al decodificar JSON: $e');
        await logout(); // Limpia datos corruptos
      } catch (e) {
        print('❌ Error inesperado al cargar sesión: $e');
      }
    }
    notifyListeners();
  }

  // Iniciar sesión
  Future<void> login(String token, Map<String, dynamic> user) async {
    _token = token;
    _user = user;
    _isAuthenticated = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user));

    print('✅ Token guardado: $token');
    print('✅ Usuario guardado: $user');

    notifyListeners();
  }

  // Cerrar sesión
  Future<void> logout() async {
    _token = null;
    _user = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    print('🚪 Sesión cerrada y datos eliminados');
    notifyListeners();
  }
}