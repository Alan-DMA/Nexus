// DTOs fuertemente tipados para Ensamblado de Pedidos y Enlaces wa.me (RF-24)
// Cumplimiento estricto de .agents/AGENTS.md: Moneda MXN ($), serialización segura, comentarios exhaustivos.

/// Método de entrega seleccionado.
enum DeliveryMethodDto {
  /// Recoger en tienda física.
  pickup('PICKUP'),
  /// Entrega a domicilio.
  delivery('DELIVERY');

  /// Valor serializado en la API.
  final String value;
  const DeliveryMethodDto(this.value);

  /// Conversión segura desde cadena.
  static DeliveryMethodDto fromString(String val) {
    return DeliveryMethodDto.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => DeliveryMethodDto.pickup,
    );
  }
}

/// Forma de pago prevista por el cliente.
enum PaymentMethodPreviewDto {
  /// Efectivo contra entrega.
  cash('CASH'),
  /// Transferencia bancaria / SPEI.
  transfer('TRANSFER'),
  /// Tarjeta contra entrega (Terminal TPV móvil).
  cardOnDelivery('CARD_ON_DELIVERY');

  /// Valor serializado en la API.
  final String value;
  const PaymentMethodPreviewDto(this.value);

  /// Conversión segura desde cadena.
  static PaymentMethodPreviewDto fromString(String val) {
    return PaymentMethodPreviewDto.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => PaymentMethodPreviewDto.cash,
    );
  }
}

/// Artículo agregado al carrito para el pedido de WhatsApp.
class WhatsAppOrderItemRequestDto {
  /// Identificador único del producto solicitado.
  final String productId;
  /// Cantidad de piezas o unidades.
  final double quantity;
  /// Instrucción especial opcional.
  final String? notes;

  /// Constructor de renglón del carrito.
  const WhatsAppOrderItemRequestDto({
    required this.productId,
    required this.quantity,
    this.notes,
  });

  /// Deserialización segura desde JSON.
  factory WhatsAppOrderItemRequestDto.fromJson(Map<String, dynamic> json) {
    return WhatsAppOrderItemRequestDto(
      productId: json['product_id'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      notes: json['notes'] as String?,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'product_id': productId,
      'quantity': quantity,
    };
    if (notes != null) map['notes'] = notes;
    return map;
  }
}

/// Solicitud de generación de pedido y enlace de WhatsApp.
class WhatsAppOrderBuildRequestDto {
  /// Nombre del cliente solicitante.
  final String customerName;
  /// Teléfono celular de contacto.
  final String? customerPhone;
  /// Modalidad de entrega (PICKUP o DELIVERY).
  final DeliveryMethodDto deliveryMethod;
  /// Dirección de envío (obligatoria si es DELIVERY).
  final String? deliveryAddress;
  /// Forma de pago seleccionada.
  final PaymentMethodPreviewDto paymentMethod;
  /// Efectivo con el que pagará para cálculo de cambio.
  final double? cashTenderedMxn;
  /// Lista de productos del carrito.
  final List<WhatsAppOrderItemRequestDto> items;
  /// Observaciones generales del pedido.
  final String? orderNotes;

  /// Constructor de la solicitud de pedido.
  const WhatsAppOrderBuildRequestDto({
    required this.customerName,
    this.customerPhone,
    this.deliveryMethod = DeliveryMethodDto.pickup,
    this.deliveryAddress,
    this.paymentMethod = PaymentMethodPreviewDto.cash,
    this.cashTenderedMxn,
    required this.items,
    this.orderNotes,
  });

  /// Deserialización segura desde JSON.
  factory WhatsAppOrderBuildRequestDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return WhatsAppOrderBuildRequestDto(
      customerName: json['customer_name'] as String? ?? '',
      customerPhone: json['customer_phone'] as String?,
      deliveryMethod: DeliveryMethodDto.fromString(json['delivery_method'] as String? ?? 'PICKUP'),
      deliveryAddress: json['delivery_address'] as String?,
      paymentMethod: PaymentMethodPreviewDto.fromString(json['payment_method'] as String? ?? 'CASH'),
      cashTenderedMxn: (json['cash_tendered_mxn'] as num?)?.toDouble(),
      items: rawItems
          .map((e) => WhatsAppOrderItemRequestDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      orderNotes: json['order_notes'] as String?,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'customer_name': customerName,
      'delivery_method': deliveryMethod.value,
      'payment_method': paymentMethod.value,
      'items': items.map((e) => e.toJson()).toList(),
    };
    if (customerPhone != null) map['customer_phone'] = customerPhone;
    if (deliveryAddress != null) map['delivery_address'] = deliveryAddress;
    if (cashTenderedMxn != null) map['cash_tendered_mxn'] = cashTenderedMxn;
    if (orderNotes != null) map['order_notes'] = orderNotes;
    return map;
  }
}

/// Respuesta con el enlace wa.me y texto formateado para WhatsApp.
class WhatsAppOrderBuildResponseDto {
  /// Enlace directo universal a WhatsApp (https://wa.me/...).
  final String waLink;
  /// Mensaje estructurado con emojis y desglose en Pesos Mexicanos.
  final String formattedText;
  /// Subtotal de artículos en $ MXN.
  final double subtotalMxn;
  /// Costo de entrega a domicilio en $ MXN.
  final double deliveryFeeMxn;
  /// Total general a pagar en $ MXN.
  final double totalMxn;
  /// Cambio en efectivo a devolver si aplica.
  final double? changeMxn;
  /// Cantidad de partidas solicitadas.
  final int itemCount;

  /// Constructor de respuesta de pedido de WhatsApp.
  const WhatsAppOrderBuildResponseDto({
    required this.waLink,
    required this.formattedText,
    required this.subtotalMxn,
    required this.deliveryFeeMxn,
    required this.totalMxn,
    this.changeMxn,
    required this.itemCount,
  });

  /// Deserialización segura desde JSON.
  factory WhatsAppOrderBuildResponseDto.fromJson(Map<String, dynamic> json) {
    return WhatsAppOrderBuildResponseDto(
      waLink: json['wa_link'] as String? ?? '',
      formattedText: json['formatted_text'] as String? ?? '',
      subtotalMxn: (json['subtotal_mxn'] as num?)?.toDouble() ?? 0.0,
      deliveryFeeMxn: (json['delivery_fee_mxn'] as num?)?.toDouble() ?? 0.0,
      totalMxn: (json['total_mxn'] as num?)?.toDouble() ?? 0.0,
      changeMxn: (json['change_mxn'] as num?)?.toDouble(),
      itemCount: json['item_count'] as int? ?? 0,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'wa_link': waLink,
      'formatted_text': formattedText,
      'subtotal_mxn': subtotalMxn,
      'delivery_fee_mxn': deliveryFeeMxn,
      'total_mxn': totalMxn,
      'item_count': itemCount,
    };
    if (changeMxn != null) map['change_mxn'] = changeMxn;
    return map;
  }
}
