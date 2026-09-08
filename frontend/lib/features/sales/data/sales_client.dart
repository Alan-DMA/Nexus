// Importación de Dio para peticiones HTTP
import 'package:dio/dio.dart';
// Importación de Riverpod para inyección de dependencias
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importación del cliente HTTP global
import 'package:frontend/core/network/api_client.dart';
// Importación de DTOs de inventario y ventas
import 'package:frontend/features/inventory/data/models/product_dto.dart';
import 'package:frontend/features/sales/data/models/sale_dto.dart';

///
/// Repositorio de Ventas, Checkout POS e Inventario para el Frontend
/// Conecta con los endpoints oficiales de Nexus v3.0-MX:
/// - POST /api/v1/sales/checkout
/// - GET /api/v1/inventory/products
/// - POST /api/v1/inventory/products
///
class SalesRepository {
  // Instancia inyectada de Dio
  final Dio _dio;

  // Constructor
  SalesRepository(this._dio);

  ///
  /// Ejecuta el Checkout Transaccional Atómico en Punto de Venta (RF-09, RF-12).
  /// Soporta bloqueo ACID, congelamiento de costos y creación de productos al vuelo.
  ///
  Future<SaleResponseDto> processCheckout({
    required String warehouseId,
    required List<SaleItemRequestDto> items,
    List<SalePaymentRequestDto>? payments,
    double discountMxn = 0.0,
    String? clientId,
    String? notes,
  }) async {
    try {
      // Construcción de la solicitud DTO
      final requestDto = SaleCheckoutRequestDto(
        warehouseId: warehouseId,
        clientId: clientId,
        items: items,
        payments: payments,
        discountMxn: discountMxn,
        notes: notes,
      );

      // Petición POST al endpoint atómico de checkout
      final response = await _dio.post(
        '/api/v1/sales/checkout',
        data: requestDto.toJson(),
      );

      // Deserialización y retorno de la nota de venta generada
      return SaleResponseDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  ///
  /// Método de compatibilidad para prototipos existentes que crean ventas
  ///
  Future<Map<String, dynamic>> createSale({
    required List<Map<String, dynamic>> items,
    String? sellerId,
  }) async {
    try {
      // Mapear ítems genéricos a SaleItemRequestDto
      final saleItems = items.map((i) {
        return SaleItemRequestDto(
          productId: i['product_id']?.toString(),
          quantity: double.tryParse(i['quantity']?.toString() ?? '1') ?? 1.0,
          unitPriceMxn: double.tryParse(i['unit_price_mxn']?.toString() ?? i['price_usd']?.toString() ?? '0'),
        );
      }).toList();

      // Enviar con almacén o intentar checkout
      final response = await _dio.post(
        '/api/v1/sales/checkout',
        data: {
          'warehouse_id': '00000000-0000-0000-0000-000000000000',
          'items': saleItems.map((s) => s.toJson()).toList(),
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  ///
  /// Obtiene el catálogo de productos activos desde /api/v1/inventory/products
  ///
  Future<List<ProductDto>> fetchProductsList({String? query}) async {
    try {
      final response = await _dio.get(
        '/api/v1/inventory/products',
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
          'limit': 100,
        },
      );
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((item) => ProductDto.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  ///
  /// Método compatible con el buscador que retorna List<dynamic>
  ///
  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await _dio.get('/api/v1/inventory/products');
      return response.data as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  ///
  /// Alta rápida de producto (3 Campos Vitales) en Pesos Mexicanos ($ MXN)
  ///
  Future<Map<String, dynamic>> quickCreateProduct({
    required String name,
    required String barcode,
    required double costUsd,
    required double priceUsd,
    required double stockInicial,
  }) async {
    try {
      // El backend opera nativamente en MXN
      final response = await _dio.post(
        '/api/v1/inventory/products',
        data: {
          'name': name.trim(),
          'barcode': barcode.isNotEmpty ? barcode.trim() : null,
          'price_mxn': priceUsd,
          'cost_mxn': costUsd,
          'initial_stock': stockInicial,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}

/// Proveedor del Repositorio de Ventas
final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SalesRepository(dio);
});
