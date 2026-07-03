import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';

class SalesRepository {
  final Dio _dio;

  SalesRepository(this._dio);

  // Crear venta en DRAFT
  Future<Map<String, dynamic>> createSale({
    required List<Map<String, dynamic>> items,
    String? sellerId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/sales',
        data: {
          if (sellerId != null) 'seller_id': sellerId,
          'items': items,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Registrar pagos mixtos
  Future<Map<String, dynamic>> addPayments({
    required String saleId,
    required List<Map<String, dynamic>> payments,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/sales/$saleId/payments',
        data: payments,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Transicionar estado de venta
  Future<Map<String, dynamic>> transitionSale({
    required String saleId,
    required String newStatus,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/sales/$saleId/transition',
        data: {'new_status': newStatus},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Obtener productos activos para el buscador del checkout
  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await _dio.get('/api/v1/inventory/products');
      return response.data as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Crear producto al vuelo (Rápido)
  Future<Map<String, dynamic>> quickCreateProduct({
    required String name,
    required String barcode,
    required double costUsd,
    required double priceUsd,
    required double stockInicial,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/inventory/products',
        data: {
          'name': name,
          'barcode': barcode,
          'cost_usd': costUsd,
          'price_usd': priceUsd,
          'stock_inicial': stockInicial,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}

// Provider del Repositorio de Ventas
final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SalesRepository(dio);
});
