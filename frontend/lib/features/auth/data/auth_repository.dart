import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Repositorio de Autenticación
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  // Iniciar sesión
  Future<bool> login({
    required String tenantId,
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: {
          'tenant_id': tenantId,
          'username_or_email': usernameOrEmail,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final authBox = Hive.box('auth');
        
        // Guardar Tokens
        await authBox.put('access_token', data['tokens']['access_token']);
        await authBox.put('refresh_token', data['tokens']['refresh_token']);
        
        // Guardar Info de Usuario e Inquilino
        await authBox.put('user_name', data['user']['username']);
        await authBox.put('user_email', data['user']['email']);
        await authBox.put('tenant_id', data['tenant']['id']);
        await authBox.put('tenant_name', data['tenant']['name']);
        
        return true;
      }
      return false;
    } catch (e) {
      // Manejar excepciones de Dio o red
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    final authBox = Hive.box('auth');
    await authBox.clear();
  }

  // Verificar si hay sesión activa
  bool get isAuthenticated {
    final authBox = Hive.box('auth');
    return authBox.get('access_token') != null;
  }
}

// Provider del Repositorio de Autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});
