// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final Dio _dio = Dio();

  // ✅ Usa la IP correcta del servidor
  static const String baseUrl = 'http://192.168.0.5:5000/api';

  static void init() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers = {
        'Content-Type': 'application/json',
      };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          print('🔐 Enviando token: $token');

          if (token != null) {
            options.headers['x-auth-token'] = token;
          }

          handler.next(options);
        },
        onError: (DioError e, handler) {
          print('❌ Error en API: ${e.message}');
          if (e.response?.statusCode == 401) {
            // Opcional: redirigir a login
          }
          handler.next(e);
        },
      ),
    );
  }

  static Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      print('✅ GET exitoso: $endpoint -> ${response.data}');
      return response;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      print('✅ POST exitoso: $endpoint');
      return response;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static Future<Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      print('✅ PUT exitoso: $endpoint');
      return response;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static void _handleError(DioError e) {
    if (e.type == DioErrorType.connectionError || e.type == DioErrorType.connectionTimeout) {
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } else if (e.type == DioErrorType.receiveTimeout) {
      throw Exception('Error: El servidor tardó demasiado en responder.');
    } else if (e.response?.statusCode == 400) {
      final msg = e.response?.data['msg'] ?? 'Datos inválidos';
      throw Exception('Error 400: $msg');
    } else if (e.response?.statusCode == 401) {
      final msg = e.response?.data['msg'] ?? 'No autorizado';
      throw Exception('No autorizado: $msg');
    } else if (e.response?.statusCode == 404) {
      throw Exception('Recurso no encontrado. Verifica la URL.');
    } else if (e.response?.statusCode == 500) {
      throw Exception('Error interno del servidor. Inténtalo más tarde.');
    } else {
      throw Exception('Error desconocido: ${e.message}');
    }
  }
}