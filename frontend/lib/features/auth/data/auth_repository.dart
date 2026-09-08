// Importación del cliente HTTP Dio
import 'package:dio/dio.dart';
// Importación de Riverpod para inyección de dependencias
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importación del proveedor del cliente HTTP
import 'package:frontend/core/network/api_client.dart';
// Importación de Hive para almacenamiento local persistente
import 'package:hive_flutter/hive_flutter.dart';
// Importación del DTO de autenticación
import 'models/auth_dto.dart';

///
/// Repositorio de Autenticación y Gestión de Sesiones
/// Consume los endpoints oficiales /api/v1/auth/login y /api/v1/auth/refresh.
///
class AuthRepository {
  // Instancia inyectada de Dio
  final Dio _dio;

  // Constructor
  AuthRepository(this._dio);

  ///
  /// Inicia sesión validando credenciales contra el backend FastAPI.
  /// Guarda de forma persistente los tokens JWT y datos de sesión en Hive.
  ///
  Future<bool> login({
    required String tenantId,
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      // Petición HTTP POST al endpoint oficial de autenticación
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: {
          'tenant_id': tenantId.trim(),
          'username_or_email': usernameOrEmail.trim(),
          'password': password,
        },
      );

      // Verificación de código de estado exitoso
      if (response.statusCode == 200 && response.data != null) {
        // Deserialización mediante el DTO fuertemente tipado
        final authData = AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
        // Apertura de la caja de persistencia Hive
        final authBox = Hive.box('auth');
        
        // Guardar Tokens de acceso y refresco en Hive
        await authBox.put('access_token', authData.accessToken);
        await authBox.put('refresh_token', authData.refreshToken);
        
        // Guardar información del usuario autenticado
        await authBox.put('user_id', authData.user.id);
        await authBox.put('user_name', authData.user.username);
        await authBox.put('user_email', authData.user.email);
        await authBox.put('user_full_name', authData.user.fullName);
        
        // Guardar información del inquilino (Tenant)
        await authBox.put('tenant_id', authData.tenant.id);
        await authBox.put('tenant_name', authData.tenant.name);
        await authBox.put('tenant_slug', authData.tenant.slug);
        await authBox.put('subscription_plan', authData.tenant.subscriptionPlan);
        await authBox.put('subscription_status', authData.tenant.subscriptionStatus);
        
        // Retorno de éxito
        return true;
      }
      return false;
    } on DioException catch (_) {
      // Manejo controlado de excepciones de red o credenciales inválidas
      return false;
    } catch (_) {
      // Captura de cualquier otra excepción
      return false;
    }
  }

  ///
  /// Cierra la sesión activa borrando los tokens y datos de Hive.
  ///
  Future<void> logout() async {
    final authBox = Hive.box('auth');
    await authBox.clear();
  }

  ///
  /// Verifica si existe un token de acceso guardado en el almacenamiento local.
  ///
  bool get isAuthenticated {
    final authBox = Hive.box('auth');
    final token = authBox.get('access_token');
    return token != null && token.toString().isNotEmpty;
  }
}

/// Proveedor de Riverpod para el Repositorio de Autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});
