// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final Dio _dio = Dio();

  static const String baseUrl = 'http://192.168.0.9:5000/api';

  static void init() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..headers = {
        'Content-Type': 'application/json',
      };

    // ✅ Interceptor correcto
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // ✅ Añadir token
          _getToken().then((token) {
            if (token != null) {
              options.headers['x-auth-token'] = token;
            }
          });
          handler.next(options); // ✅ Continuar
        },
        onResponse: (response, handler) {
          handler.next(response); // ✅ Continuar
        },
        onError: (error, handler) {
          handler.next(error); // ✅ Continuar
        },
      ),
    );
  }

  static Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
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
      throw Exception(e.response?.data['msg'] ?? 'Datos inválidos');
    } else if (e.response?.statusCode == 401) {
      throw Exception('No autorizado. Verifica tus credenciales.');
    } else if (e.response?.statusCode == 404) {
      throw Exception('Recurso no encontrado. Verifica la URL.');
    } else if (e.response?.statusCode == 500) {
      throw Exception('Error interno del servidor. Inténtalo más tarde.');
    } else {
      throw Exception('Error desconocido: ${e.message}');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}