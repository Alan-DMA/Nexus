import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_interceptor.dart';

// Proveedor global para la instancia de Dio
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // URL base del backend. 
      // NOTA: Para emuladores Android, usar 'http://10.0.2.2:8000'.
      // Para desarrollo web o local de escritorio/iOS, usar 'http://127.0.0.1:8000'.
      baseUrl: 'http://127.0.0.1:8000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Agregar interceptor de autenticación
  dio.interceptors.add(AuthInterceptor(ref));
  
  // Agregar logs en consola durante el desarrollo
  dio.interceptors.add(LogInterceptor(
    requestHeader: true,
    requestBody: true,
    responseHeader: false,
    responseBody: true,
    error: true,
  ));

  return dio;
});
