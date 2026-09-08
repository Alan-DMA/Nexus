// DTOs fuertemente tipados para el Módulo de Inventario en Pesos Mexicanos ($ MXN)
class ProductStockDto {
  // Identificador del stock
  final String id;
  // Identificador del almacén
  final String warehouseId;
  // Existencias disponibles
  final double currentStock;
  // Existencias apartadas
  final double reservedStock;

  ProductStockDto({
    required this.id,
    required this.warehouseId,
    required this.currentStock,
    required this.reservedStock,
  });

  factory ProductStockDto.fromJson(Map<String, dynamic> json) {
    return ProductStockDto(
      id: json['id']?.toString() ?? '',
      warehouseId: json['warehouse_id']?.toString() ?? '',
      currentStock: double.tryParse(json['current_stock']?.toString() ?? '0') ?? 0.0,
      reservedStock: double.tryParse(json['reserved_stock']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class ProductDto {
  // Identificador único UUID
  final String id;
  // Nombre comercial
  final String name;
  // Código SKU único (ej. NEX-10001)
  final String sku;
  // Código de barras físico EAN-13 / UPC
  final String? barcode;
  // Precio de venta unitario en Pesos Mexicanos ($ MXN)
  final double priceMxn;
  // Costo de compra unitario en Pesos Mexicanos ($ MXN)
  final double costMxn;
  // Existencias totales sumadas de todos los almacenes
  final double totalStock;
  // Bandera de alerta de stock bajo
  final bool isLowStock;
  // Estado activo en catálogo
  final bool isActive;
  // Nombre de categoría
  final String? categoryName;
  // Desglose de existencias por almacén
  final List<ProductStockDto> stocks;

  ProductDto({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    required this.priceMxn,
    required this.costMxn,
    required this.totalStock,
    required this.isLowStock,
    required this.isActive,
    this.categoryName,
    this.stocks = const [],
  });

  // Fábrica para deserialización tolerante a campos MXN y legacy USD
  factory ProductDto.fromJson(Map<String, dynamic> json) {
    // Extracción de precio en MXN con fallback
    final double price = double.tryParse(
            json['price_mxn']?.toString() ?? json['price_usd']?.toString() ?? '0') ??
        0.0;
    // Extracción de costo en MXN con fallback
    final double cost = double.tryParse(
            json['cost_mxn']?.toString() ?? json['cost_usd']?.toString() ?? '0') ??
        0.0;
    // Extracción de existencias totales
    final double stock = double.tryParse(
            json['total_stock']?.toString() ?? json['stock_actual']?.toString() ?? '0') ??
        0.0;

    return ProductDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Producto sin nombre',
      sku: json['sku']?.toString() ?? 'NEX-00000',
      barcode: json['barcode']?.toString(),
      priceMxn: price,
      costMxn: cost,
      totalStock: stock,
      isLowStock: json['is_low_stock'] == true,
      isActive: json['is_active'] != false,
      categoryName: json['category_name']?.toString(),
      stocks: (json['stocks'] as List<dynamic>?)
              ?.map((s) => ProductStockDto.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Serialización a JSON para peticiones
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'barcode': barcode,
        'price_mxn': priceMxn,
        'cost_mxn': costMxn,
        'total_stock': totalStock,
        'is_low_stock': isLowStock,
        'is_active': isActive,
        'category_name': categoryName,
      };
}
