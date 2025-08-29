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

    print('🔐 Token en SharedPreferences: $token'); // ✅ Depuración
    print('👥 User data en SharedPreferences: $userData');

    if (token != null && userData != null) {
      _token = token;
      try {
        _user = Map<String, dynamic>.from((jsonDecode(userData) as Map).cast<String, dynamic>());
        _isAuthenticated = true;
        print('✅ Usuario autenticado automáticamente');
      } catch (e) {
        print('❌ Error al decodificar user_data: $e');
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

  // ✅ Verifica que se guardó
  final savedToken = prefs.getString('auth_token');
  print('✅ Token guardado y leído: $savedToken');

  notifyListeners();
}

  // Cerrar sesión
  Future<void> logout() async {
    _token = null;
    _user = null;
    _isAuthenticated = false;

    // Eliminar datos de sesión
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    print('🚪 Sesión cerrada'); // ✅ Depuración
    notifyListeners();
  }

  // Eliminar cuenta (opcional)
  Future<void> deleteAccount() async {
    await logout();
  }
}