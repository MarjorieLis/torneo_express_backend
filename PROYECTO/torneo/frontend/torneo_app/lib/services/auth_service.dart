// lib/services/auth_service.dart
import 'package:flutter/material.dart';
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

    if (token != null && userData != null) {
      _token = token;
      _user = Map<String, dynamic>.from((userData as Map).cast<String, dynamic>());
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  // Iniciar sesión
  Future<void> login(String token, Map<String, dynamic> user) async {
    _token = token;
    _user = user;
    _isAuthenticated = true;

    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', user.toString());

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

    notifyListeners();
  }

  // Eliminar cuenta (opcional)
  Future<void> deleteAccount() async {
    await logout();
    // Aquí podrías llamar a un endpoint para eliminar la cuenta del backend
  }
}