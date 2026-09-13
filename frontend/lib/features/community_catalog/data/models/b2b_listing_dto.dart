// DTOs fuertemente tipados para el Catálogo Comunitario B2B y Ofertas Mayoristas (RF-27 / Const. Art. 4.3)
// Cumplimiento estricto de .agents/AGENTS.md:
// 1. Moneda base en Pesos Mexicanos ($ MXN).
// 2. Prohibición de mapas crudos (Map<String, dynamic>) en capas de UI/Negocio.
// 3. Serialización y deserialización a prueba de nulos.
// 4. Comentarios exhaustivos línea por línea.

/// Solicitud de publicación de oferta mayorista en el catálogo comunitario B2B.
class B2BListingCreateRequestDto {
  /// Identificador único del producto en el inventario del comercio vendedor.
  final String productId;
  /// Precio de mayoreo por unidad en Pesos Mexicanos ($ MXN).
  final double wholesalePriceMxn;
  /// Lote mínimo de compra requerido para aplicar precio mayorista.
  final double minWholesaleQuantity;
  /// Existencias físicas destinadas a la red de comercio mayorista.
  final double availableB2bStock;
  /// Código postal de la tienda para filtrado por cercanía geográfica.
  final String? locationPostalCode;
  /// Ciudad o delegación donde se ubica el negocio.
  final String? locationCity;
  /// Términos comerciales o notas sobre logística de entrega.
  final String? notes;

  /// Constructor inmutable de la solicitud de oferta.
  const B2BListingCreateRequestDto({
    required this.productId,
    required this.wholesalePriceMxn,
    this.minWholesaleQuantity = 1.0,
    required this.availableB2bStock,
    this.locationPostalCode,
    this.locationCity,
    this.notes,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'wholesale_price_mxn': wholesalePriceMxn,
      'min_wholesale_quantity': minWholesaleQuantity,
      'available_b2b_stock': availableB2bStock,
      'location_postal_code': locationPostalCode,
      'location_city': locationCity,
      'notes': notes,
    };
  }
}

/// Solicitud de modificación de oferta mayorista existente.
class B2BListingUpdateRequestDto {
  /// Nuevo precio mayorista en $ MXN.
  final double? wholesalePriceMxn;
  /// Nuevo lote mínimo de compra.
  final double? minWholesaleQuantity;
  /// Existencias actualizadas disponibles para venta mayorista.
  final double? availableB2bStock;
  /// Código postal actualizado.
  final String? locationPostalCode;
  /// Ciudad o delegación actualizada.
  final String? locationCity;
  /// Estado activo o pausado de la oferta.
  final bool? isActive;
  /// Notas comerciales actualizadas.
  final String? notes;

  /// Constructor inmutable de actualización de oferta mayorista.
  const B2BListingUpdateRequestDto({
    this.wholesalePriceMxn,
    this.minWholesaleQuantity,
    this.availableB2bStock,
    this.locationPostalCode,
    this.locationCity,
    this.isActive,
    this.notes,
  });

  /// Serialización a JSON omitiendo valores no definidos.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (wholesalePriceMxn != null) data['wholesale_price_mxn'] = wholesalePriceMxn;
    if (minWholesaleQuantity != null) data['min_wholesale_quantity'] = minWholesaleQuantity;
    if (availableB2bStock != null) data['available_b2b_stock'] = availableB2bStock;
    if (locationPostalCode != null) data['location_postal_code'] = locationPostalCode;
    if (locationCity != null) data['location_city'] = locationCity;
    if (isActive != null) data['is_active'] = isActive;
    if (notes != null) data['notes'] = notes;
    return data;
  }
}

/// DTO de respuesta para una oferta mayorista en el catálogo comunitario B2B.
class B2BListingDto {
  /// Identificador único universal de la oferta mayorista.
  final String id;
  /// Identificador del inquilino / comercio vendedor.
  final String tenantId;
  /// Nombre comercial de la tienda o distribuidora que vende.
  final String sellerStoreName;
  /// Identificador del producto físico publicado.
  final String productId;
  /// Nombre comercial del producto mayorista.
  final String productName;
  /// Código SKU o código de barras del producto.
  final String productSku;
  /// URL de imagen representativa del producto.
  final String? productImageUrl;
  /// Precio de mayoreo por unidad en Pesos Mexicanos ($ MXN).
  final double wholesalePriceMxn;
  /// Precio regular de venta al público como referencia de ahorro en $ MXN.
  final double? regularPriceMxn;
  /// Lote mínimo de compra para acceder al precio de mayoreo.
  final double minWholesaleQuantity;
  /// Existencias físicas disponibles para surtir pedidos B2B.
  final double availableB2bStock;
  /// Código postal de ubicación del comercio.
  final String? locationPostalCode;
  /// Ciudad o municipio del comercio.
  final String? locationCity;
  /// Bandera que indica si la oferta está activa y visible.
  final bool isActive;
  /// Condiciones especiales o notas comerciales.
  final String? notes;
  /// Fecha de publicación de la oferta.
  final DateTime createdAt;

  /// Constructor inmutable de la oferta mayorista.
  const B2BListingDto({
    required this.id,
    required this.tenantId,
    required this.sellerStoreName,
    required this.productId,
    required this.productName,
    required this.productSku,
    this.productImageUrl,
    required this.wholesalePriceMxn,
    this.regularPriceMxn,
    required this.minWholesaleQuantity,
    required this.availableB2bStock,
    this.locationPostalCode,
    this.locationCity,
    required this.isActive,
    this.notes,
    required this.createdAt,
  });

  /// Deserialización segura desde JSON.
  factory B2BListingDto.fromJson(Map<String, dynamic> json) {
    return B2BListingDto(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      sellerStoreName: json['seller_store_name'] as String? ?? 'Comercio Asociado',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? 'Producto B2B',
      productSku: json['product_sku'] as String? ?? '',
      productImageUrl: json['product_image_url'] as String?,
      wholesalePriceMxn: (json['wholesale_price_mxn'] as num?)?.toDouble() ?? 0.0,
      regularPriceMxn: (json['regular_price_mxn'] as num?)?.toDouble(),
      minWholesaleQuantity: (json['min_wholesale_quantity'] as num?)?.toDouble() ?? 1.0,
      availableB2bStock: (json['available_b2b_stock'] as num?)?.toDouble() ?? 0.0,
      locationPostalCode: json['location_postal_code'] as String?,
      locationCity: json['location_city'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'seller_store_name': sellerStoreName,
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'product_image_url': productImageUrl,
      'wholesale_price_mxn': wholesalePriceMxn,
      'regular_price_mxn': regularPriceMxn,
      'min_wholesale_quantity': minWholesaleQuantity,
      'available_b2b_stock': availableB2bStock,
      'location_postal_code': locationPostalCode,
      'location_city': locationCity,
      'is_active': isActive,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
