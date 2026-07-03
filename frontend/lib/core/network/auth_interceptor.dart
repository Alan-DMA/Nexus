import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. Obtener el token de acceso guardado en Hive de forma síncrona
    final authBox = Hive.box('auth');
    final String? accessToken = authBox.get('access_token');

    // 2. Si existe, inyectarlo en las cabeceras
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 3. Si el error es 401 (No autorizado) e indica token expirado
    if (err.response?.statusCode == 401) {
      final authBox = Hive.box('auth');
      final String? refreshToken = authBox.get('refresh_token');

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // 4. Intentar refrescar el token de acceso
          // Creamos una nueva instancia limpia de Dio para evitar loops infinitos
          final dioClean = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
          
          final response = await dioClean.post(
            '/api/v1/auth/refresh',
            queryParameters: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200) {
            final data = response.data;
            final String newAccessToken = data['access_token'];
            final String newRefreshToken = data['refresh_token'];

            // 5. Guardar nuevos tokens en Hive
            await authBox.put('access_token', newAccessToken);
            await authBox.put('refresh_token', newRefreshToken);

            // 6. Re-intentar la petición original con el nuevo token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final cloneReq = await Dio().fetch(requestOptions);
            return handler.resolve(cloneReq);
          }
        } catch (e) {
          // Si falla la renovación del token (ej. refresh token expiró), desloguear
          await authBox.delete('access_token');
          await authBox.delete('refresh_token');
          // Aquí se podría notificar a un provider de estado de sesión para redirigir a Login
        }
      }
    }

    return handler.next(err);
  }
}
