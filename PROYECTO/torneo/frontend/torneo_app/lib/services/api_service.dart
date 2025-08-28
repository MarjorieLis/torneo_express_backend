// lib/services/api_service.dart
import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio();

  // Usa tu IP local (asegúrate de que el backend esté en 0.0.0.0)
  static const String baseUrl = 'http://192.168.0.8:5000/api';

  // Inicializa el cliente HTTP
  static void init() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..headers = {
        'Content-Type': 'application/json',
      };
  }

  // GET
  static Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // POST
  static Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // PUT
  static Future<Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // PATCH
  static Future<Response> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Manejo centralizado de errores
  static void _handleError(DioError e) {
    if (e.type == DioErrorType.connectionError || e.type == DioErrorType.connectionTimeout) {
      throw Exception('Error de red: No se pudo conectar al servidor. Verifica tu conexión y que el backend esté corriendo.');
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
}