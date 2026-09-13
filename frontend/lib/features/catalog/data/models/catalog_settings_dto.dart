// DTOs fuertemente tipados para Configuración del Catálogo Digital (RF-26)
// Cumplimiento estricto de .agents/AGENTS.md: Moneda MXN ($), serialización segura, comentarios exhaustivos.

/// Configuración operativa del catálogo digital del comercio.
class CatalogSettingsDto {
  /// Identificador único del registro de configuración.
  final String id;
  /// Identificador del comercio (Tenant).
  final String tenantId;
  /// Bandera maestra que indica si el catálogo está activo.
  final bool isCatalogEnabled;
  /// Número de WhatsApp para recepción de pedidos.
  final String? whatsappNumber;
  /// Mensaje de bienvenida para los clientes.
  final String? welcomeMessage;
  /// Monto mínimo de compra en Pesos Mexicanos ($ MXN).
  final double minOrderAmountMxn;
  /// Costo de entrega a domicilio en $ MXN.
  final double deliveryFeeMxn;
  /// Bandera para permitir entrega a domicilio.
  final bool deliveryEnabled;
  /// Bandera para permitir recoger en sucursal.
  final bool pickupEnabled;
  /// Horario de servicio al cliente.
  final String? businessHours;

  /// Constructor inmutable de configuración de catálogo.
  const CatalogSettingsDto({
    required this.id,
    required this.tenantId,
    required this.isCatalogEnabled,
    this.whatsappNumber,
    this.welcomeMessage,
    required this.minOrderAmountMxn,
    required this.deliveryFeeMxn,
    required this.deliveryEnabled,
    required this.pickupEnabled,
    this.businessHours,
  });

  /// Deserialización segura desde JSON.
  factory CatalogSettingsDto.fromJson(Map<String, dynamic> json) {
    return CatalogSettingsDto(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      isCatalogEnabled: json['is_catalog_enabled'] as bool? ?? true,
      whatsappNumber: json['whatsapp_number'] as String?,
      welcomeMessage: json['welcome_message'] as String?,
      minOrderAmountMxn: (json['min_order_amount_mxn'] as num?)?.toDouble() ?? 0.0,
      deliveryFeeMxn: (json['delivery_fee_mxn'] as num?)?.toDouble() ?? 0.0,
      deliveryEnabled: json['delivery_enabled'] as bool? ?? true,
      pickupEnabled: json['pickup_enabled'] as bool? ?? true,
      businessHours: json['business_hours'] as String?,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'is_catalog_enabled': isCatalogEnabled,
      'whatsapp_number': whatsappNumber,
      'welcome_message': welcomeMessage,
      'min_order_amount_mxn': minOrderAmountMxn,
      'delivery_fee_mxn': deliveryFeeMxn,
      'delivery_enabled': deliveryEnabled,
      'pickup_enabled': pickupEnabled,
      'business_hours': businessHours,
    };
  }
}

/// Solicitud de actualización de parámetros del catálogo digital.
class CatalogSettingsUpdateRequestDto {
  /// Habilitar/Deshabilitar catálogo.
  final bool? isCatalogEnabled;
  /// Número de WhatsApp oficial.
  final String? whatsappNumber;
  /// Mensaje de bienvenida.
  final String? welcomeMessage;
  /// Monto mínimo en Pesos Mexicanos ($ MXN).
  final double? minOrderAmountMxn;
  /// Costo de entrega a domicilio en $ MXN.
  final double? deliveryFeeMxn;
  /// Permitir entregas a domicilio.
  final bool? deliveryEnabled;
  /// Permitir recoger en tienda.
  final bool? pickupEnabled;
  /// Horario de atención.
  final String? businessHours;

  /// Constructor del DTO de actualización.
  const CatalogSettingsUpdateRequestDto({
    this.isCatalogEnabled,
    this.whatsappNumber,
    this.welcomeMessage,
    this.minOrderAmountMxn,
    this.deliveryFeeMxn,
    this.deliveryEnabled,
    this.pickupEnabled,
    this.businessHours,
  });

  /// Serialización segura a JSON omitiendo nulos.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (isCatalogEnabled != null) map['is_catalog_enabled'] = isCatalogEnabled;
    if (whatsappNumber != null) map['whatsapp_number'] = whatsappNumber;
    if (welcomeMessage != null) map['welcome_message'] = welcomeMessage;
    if (minOrderAmountMxn != null) map['min_order_amount_mxn'] = minOrderAmountMxn;
    if (deliveryFeeMxn != null) map['delivery_fee_mxn'] = deliveryFeeMxn;
    if (deliveryEnabled != null) map['delivery_enabled'] = deliveryEnabled;
    if (pickupEnabled != null) map['pickup_enabled'] = pickupEnabled;
    if (businessHours != null) map['business_hours'] = businessHours;
    return map;
  }
}
