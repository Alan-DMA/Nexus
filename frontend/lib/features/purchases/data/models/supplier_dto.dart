// DTOs fuertemente tipados para el Módulo de Proveedores y Condiciones Comerciales (RF-15)
// Cumplimiento estricto de .agents/AGENTS.md (No Map<String, dynamic> crudo en capas de UI/Repositorio)

/// Enumeración de estados operativos de un Proveedor.
enum SupplierStatusDto {
  /// Proveedor activo para compras y cotizaciones.
  active('ACTIVE'),
  /// Proveedor inactivo / descontinuado.
  inactive('INACTIVE');

  /// Valor serializado en la API REST.
  final String value;
  const SupplierStatusDto(this.value);

  /// Construcción segura a partir de cadena.
  static SupplierStatusDto fromString(String val) {
    return SupplierStatusDto.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => SupplierStatusDto.active,
    );
  }
}

/// DTO para la solicitud de creación de un nuevo proveedor.
class SupplierCreateRequestDto {
  /// Nombre comercial o razón social.
  final String name;
  /// RFC fiscal (opcional).
  final String? rfc;
  /// Teléfono o WhatsApp.
  final String? phone;
  /// Correo electrónico de contacto.
  final String? email;
  /// Domicilio o centro de distribución.
  final String? address;
  /// Días de crédito concedidos para pago de facturas.
  final int creditDays;
  /// Límite de crédito en Pesos Mexicanos ($ MXN).
  final double creditLimitMxn;
  /// Notas u observaciones.
  final String? notes;

  /// Constructor del DTO de creación.
  SupplierCreateRequestDto({
    required this.name,
    this.rfc,
    this.phone,
    this.email,
    this.address,
    this.creditDays = 0,
    this.creditLimitMxn = 0.0,
    this.notes,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'credit_days': creditDays,
      'credit_limit_mxn': creditLimitMxn,
    };
    if (rfc != null) map['rfc'] = rfc;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (address != null) map['address'] = address;
    if (notes != null) map['notes'] = notes;
    return map;
  }
}

/// DTO para la actualización parcial de un proveedor.
class SupplierUpdateRequestDto {
  /// Nombre actualizado.
  final String? name;
  /// RFC actualizado.
  final String? rfc;
  /// Teléfono actualizado.
  final String? phone;
  /// Correo electrónico actualizado.
  final String? email;
  /// Dirección actualizada.
  final String? address;
  /// Días de crédito actualizados.
  final int? creditDays;
  /// Límite de crédito actualizado en $ MXN.
  final double? creditLimitMxn;
  /// Estado activo/inactivo.
  final SupplierStatusDto? status;
  /// Notas actualizadas.
  final String? notes;

  /// Constructor con campos opcionales.
  SupplierUpdateRequestDto({
    this.name,
    this.rfc,
    this.phone,
    this.email,
    this.address,
    this.creditDays,
    this.creditLimitMxn,
    this.status,
    this.notes,
  });

  /// Serialización segura a JSON omitiendo nulos.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (rfc != null) map['rfc'] = rfc;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (address != null) map['address'] = address;
    if (creditDays != null) map['credit_days'] = creditDays;
    if (creditLimitMxn != null) map['credit_limit_mxn'] = creditLimitMxn;
    if (status != null) map['status'] = status!.value;
    if (notes != null) map['notes'] = notes;
    return map;
  }
}

/// DTO de respuesta para los datos de un Proveedor.
class SupplierResponseDto {
  /// Identificador único UUID del proveedor.
  final String id;
  /// Identificador del inquilino (Aislamiento Multi-tenant).
  final String tenantId;
  /// Nombre comercial o razón social.
  final String name;
  /// RFC fiscal.
  final String? rfc;
  /// Teléfono de pedidos.
  final String? phone;
  /// Correo electrónico.
  final String? email;
  /// Domicilio.
  final String? address;
  /// Días de crédito concedidos.
  final int creditDays;
  /// Límite de crédito en Pesos Mexicanos ($ MXN).
  final double creditLimitMxn;
  /// Estado operativo del proveedor.
  final SupplierStatusDto status;
  /// Observaciones.
  final String? notes;
  /// Fecha de registro.
  final DateTime createdAt;
  /// Fecha de última modificación.
  final DateTime updatedAt;

  /// Constructor completo.
  SupplierResponseDto({
    required this.id,
    required this.tenantId,
    required this.name,
    this.rfc,
    this.phone,
    this.email,
    this.address,
    required this.creditDays,
    required this.creditLimitMxn,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deserialización segura desde JSON.
  factory SupplierResponseDto.fromJson(Map<String, dynamic> json) {
    return SupplierResponseDto(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      rfc: json['rfc'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      creditDays: json['credit_days'] as int? ?? 0,
      creditLimitMxn: (json['credit_limit_mxn'] as num?)?.toDouble() ?? 0.0,
      status: SupplierStatusDto.fromString(json['status'] as String? ?? 'ACTIVE'),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
