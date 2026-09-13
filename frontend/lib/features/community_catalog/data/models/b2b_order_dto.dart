// DTOs fuertemente tipados para Pedidos Mayoristas B2B entre Comercios (RF-27 / Const. Art. 7.5)
// Cumplimiento estricto de .agents/AGENTS.md:
// 1. Moneda base en Pesos Mexicanos ($ MXN).
// 2. Prohibición de mapas crudos (Map<String, dynamic>) en capas de UI/Negocio.
// 3. Serialización y deserialización a prueba de nulos.
// 4. Comentarios exhaustivos línea por línea.

/// Estados del ciclo de vida del pedido mayorista B2B.
enum B2BOrderStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  rejected('REJECTED'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  final String value;
  const B2BOrderStatus(this.value);

  static B2BOrderStatus fromString(String val) {
    return B2BOrderStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => B2BOrderStatus.pending,
    );
  }
}

/// Modalidad de entrega del pedido B2B.
enum B2BDeliveryType {
  pickup('PICKUP'),
  delivery('DELIVERY');

  final String value;
  const B2BDeliveryType(this.value);

  static B2BDeliveryType fromString(String val) {
    return B2BDeliveryType.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => B2BDeliveryType.pickup,
    );
  }
}

/// Partida individual al emitir un pedido B2B.
class B2BOrderItemCreateRequestDto {
  /// Identificador de la publicación mayorista de origen.
  final String b2bListingId;
  /// Cantidad de piezas solicitadas (debe cumplir lote mínimo).
  final double quantity;

  /// Constructor inmutable de la partida.
  const B2BOrderItemCreateRequestDto({
    required this.b2bListingId,
    required this.quantity,
  });

  /// Serialización a JSON.
  Map<String, dynamic> toJson() {
    return {
      'b2b_listing_id': b2bListingId,
      'quantity': quantity,
    };
  }
}

/// Solicitud para emitir un pedido B2B de un comercio comprador a un vendedor.
class B2BOrderCreateRequestDto {
  /// Identificador del comercio vendedor.
  final String sellerTenantId;
  /// Modalidad de entrega: 'PICKUP' o 'DELIVERY'.
  final String deliveryType;
  /// Dirección pactada si aplica entrega a domicilio.
  final String? deliveryAddress;
  /// Notas comerciales o instrucciones especiales.
  final String? notes;
  /// Lista de partidas solicitadas en el pedido.
  final List<B2BOrderItemCreateRequestDto> items;

  /// Constructor inmutable del pedido.
  const B2BOrderCreateRequestDto({
    required this.sellerTenantId,
    this.deliveryType = 'PICKUP',
    this.deliveryAddress,
    this.notes,
    required this.items,
  });

  /// Serialización a JSON.
  Map<String, dynamic> toJson() {
    return {
      'seller_tenant_id': sellerTenantId,
      'delivery_type': deliveryType,
      'delivery_address': deliveryAddress,
      'notes': notes,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

/// DTO de partida individual en la respuesta de pedido B2B.
class B2BOrderItemDto {
  /// Identificador único del renglón.
  final String id;
  /// Identificador de la publicación B2B asociada.
  final String b2bListingId;
  /// Identificador del producto físico.
  final String productId;
  /// Nombre comercial del producto congelado al momento del pedido.
  final String productName;
  /// Cantidad solicitada en piezas o unidades.
  final double quantity;
  /// Precio unitario mayorista acordado en Pesos Mexicanos ($ MXN).
  final double unitPriceMxn;
  /// Subtotal de la partida en $ MXN (cantidad * unitPriceMxn).
  final double subtotalMxn;

  /// Constructor inmutable del renglón.
  const B2BOrderItemDto({
    required this.id,
    required this.b2bListingId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPriceMxn,
    required this.subtotalMxn,
  });

  /// Deserialización segura desde JSON.
  factory B2BOrderItemDto.fromJson(Map<String, dynamic> json) {
    return B2BOrderItemDto(
      id: json['id'] as String? ?? '',
      b2bListingId: json['b2b_listing_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? 'Producto B2B',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPriceMxn: (json['unit_price_mxn'] as num?)?.toDouble() ?? 0.0,
      subtotalMxn: (json['subtotal_mxn'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Serialización a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'b2b_listing_id': b2bListingId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price_mxn': unitPriceMxn,
      'subtotal_mxn': subtotalMxn,
    };
  }
}

/// DTO de respuesta para un pedido mayorista B2B completo.
class B2BOrderDto {
  /// Identificador único universal del pedido.
  final String id;
  /// Folio legible del pedido (ej: B2B-2026-0001).
  final String orderNumber;
  /// Identificador del comercio comprador.
  final String buyerTenantId;
  /// Nombre comercial del comprador.
  final String buyerStoreName;
  /// Identificador del comercio vendedor.
  final String sellerTenantId;
  /// Nombre comercial del vendedor.
  final String sellerStoreName;
  /// Estado operativo del pedido.
  final B2BOrderStatus status;
  /// Importe total del pedido en Pesos Mexicanos ($ MXN).
  final double totalMxn;
  /// Modalidad de entrega: 'PICKUP' o 'DELIVERY'.
  final B2BDeliveryType deliveryType;
  /// Dirección de entrega a domicilio si aplica.
  final String? deliveryAddress;
  /// Historial de notas y acuerdos.
  final String? notes;
  /// Partidas y productos incluidos en el pedido.
  final List<B2BOrderItemDto> items;
  /// Fecha de emisión del pedido.
  final DateTime createdAt;
  /// Fecha de última actualización de estado.
  final DateTime updatedAt;

  /// Constructor inmutable de pedido mayorista B2B.
  const B2BOrderDto({
    required this.id,
    required this.orderNumber,
    required this.buyerTenantId,
    required this.buyerStoreName,
    required this.sellerTenantId,
    required this.sellerStoreName,
    required this.status,
    required this.totalMxn,
    required this.deliveryType,
    this.deliveryAddress,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deserialización segura desde JSON.
  factory B2BOrderDto.fromJson(Map<String, dynamic> json) {
    return B2BOrderDto(
      id: json['id'] as String? ?? '',
      orderNumber: json['order_number'] as String? ?? '',
      buyerTenantId: json['buyer_tenant_id'] as String? ?? '',
      buyerStoreName: json['buyer_store_name'] as String? ?? 'Comercio Comprador',
      sellerTenantId: json['seller_tenant_id'] as String? ?? '',
      sellerStoreName: json['seller_store_name'] as String? ?? 'Comercio Vendedor',
      status: B2BOrderStatus.fromString(json['status'] as String? ?? 'PENDING'),
      totalMxn: (json['total_mxn'] as num?)?.toDouble() ?? 0.0,
      deliveryType: B2BDeliveryType.fromString(json['delivery_type'] as String? ?? 'PICKUP'),
      deliveryAddress: json['delivery_address'] as String?,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => B2BOrderItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'buyer_tenant_id': buyerTenantId,
      'buyer_store_name': buyerStoreName,
      'seller_tenant_id': sellerTenantId,
      'seller_store_name': sellerStoreName,
      'status': status.value,
      'total_mxn': totalMxn,
      'delivery_type': deliveryType.value,
      'delivery_address': deliveryAddress,
      'notes': notes,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Solicitud para cambiar el estado operativo de un pedido B2B.
class B2BOrderStatusUpdateRequestDto {
  /// Nuevo estado solicitado: 'ACCEPTED', 'REJECTED', 'COMPLETED', 'CANCELLED'.
  final String status;
  /// Nota explicativa o comentario sobre la actualización.
  final String? notes;

  /// Constructor inmutable de actualización de estado.
  const B2BOrderStatusUpdateRequestDto({
    required this.status,
    this.notes,
  });

  /// Serialización a JSON.
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'notes': notes,
    };
  }
}
