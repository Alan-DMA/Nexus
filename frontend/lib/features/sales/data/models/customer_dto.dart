// DTOs fuertemente tipados para el Módulo de Clientes, Límites de Crédito y Cuentas por Cobrar / Fiado (RF-06, RF-15)
// Cumplimiento estricto de .agents/AGENTS.md (No Map<String, dynamic> crudo en capas de presentación / repositorio)

/// Enumeración de tipos de movimientos contables en el libro mayor de crédito del cliente.
enum LedgerEntryTypeDto {
  /// Cargo o deuda por una venta a crédito (incrementa saldo deudor).
  charge('CHARGE'),
  /// Abono o pago realizado por el cliente (decrementa saldo deudor).
  payment('PAYMENT'),
  /// Ajuste manual administrativo autorizado (incremento o decremento).
  adjustment('ADJUSTMENT');

  /// Valor serializado en la API REST.
  final String value;
  const LedgerEntryTypeDto(this.value);

  /// Construcción segura a partir de cadena.
  static LedgerEntryTypeDto fromString(String val) {
    return LedgerEntryTypeDto.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => LedgerEntryTypeDto.charge,
    );
  }
}

/// DTO para la solicitud de creación de un nuevo cliente con línea de crédito.
class CustomerCreateRequestDto {
  /// Nombre completo o razón social del cliente.
  final String fullName;
  /// Teléfono o WhatsApp de contacto.
  final String? phone;
  /// Correo electrónico.
  final String? email;
  /// Domicilio o dirección fiscal / comercial.
  final String? address;
  /// RFC fiscal (12-13 caracteres).
  final String? rfc;
  /// Límite máximo de crédito en Pesos Mexicanos ($ MXN).
  final double creditLimitMxn;
  /// Plazo concedido para liquidar deudas en días naturales.
  final int creditDays;
  /// Notas adicionales u observaciones sobre el cliente.
  final String? notes;

  /// Constructor con validaciones y valores por defecto.
  CustomerCreateRequestDto({
    required this.fullName,
    this.phone,
    this.email,
    this.address,
    this.rfc,
    this.creditLimitMxn = 0.0,
    this.creditDays = 0,
    this.notes,
  });

  /// Serialización segura a JSON para enviar al backend FastAPI.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'full_name': fullName,
      'credit_limit_mxn': creditLimitMxn,
      'credit_days': creditDays,
    };
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (address != null) map['address'] = address;
    if (rfc != null) map['rfc'] = rfc;
    if (notes != null) map['notes'] = notes;
    return map;
  }
}

/// DTO para la solicitud de actualización de un cliente o ajuste de su línea de crédito.
class CustomerUpdateRequestDto {
  /// Nombre completo o razón social opcional a actualizar.
  final String? fullName;
  /// Teléfono o WhatsApp opcional.
  final String? phone;
  /// Correo electrónico opcional.
  final String? email;
  /// Dirección o domicilio opcional.
  final String? address;
  /// RFC fiscal opcional.
  final String? rfc;
  /// Nuevo límite de crédito en $ MXN.
  final double? creditLimitMxn;
  /// Nuevo plazo de crédito en días.
  final int? creditDays;
  /// Estado activo / inactivo para bloquear nuevas operaciones de fiado.
  final bool? isActive;
  /// Notas actualizadas.
  final String? notes;

  /// Constructor para mutaciones parciales.
  CustomerUpdateRequestDto({
    this.fullName,
    this.phone,
    this.email,
    this.address,
    this.rfc,
    this.creditLimitMxn,
    this.creditDays,
    this.isActive,
    this.notes,
  });

  /// Serialización segura a JSON omitiendo campos no especificados (null).
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['full_name'] = fullName;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (address != null) map['address'] = address;
    if (rfc != null) map['rfc'] = rfc;
    if (creditLimitMxn != null) map['credit_limit_mxn'] = creditLimitMxn;
    if (creditDays != null) map['credit_days'] = creditDays;
    if (isActive != null) map['is_active'] = isActive;
    if (notes != null) map['notes'] = notes;
    return map;
  }
}

/// DTO de respuesta para un cliente con su situación crediticia calculada.
class CustomerResponseDto {
  /// Identificador único UUID del cliente.
  final String id;
  /// Identificador de inquilino (aislamiento multi-tenant).
  final String tenantId;
  /// Nombre completo o razón social.
  final String fullName;
  /// Teléfono de contacto.
  final String? phone;
  /// Correo electrónico.
  final String? email;
  /// Domicilio.
  final String? address;
  /// RFC fiscal.
  final String? rfc;
  /// Límite de crédito en Pesos Mexicanos ($ MXN).
  final double creditLimitMxn;
  /// Saldo deudor actual acumulado en Pesos Mexicanos ($ MXN).
  final double creditBalanceMxn;
  /// Crédito disponible para nuevas compras ($ MXN).
  final double availableCreditMxn;
  /// Plazo en días concedido para liquidar.
  final int creditDays;
  /// Estado activo del cliente.
  final bool isActive;
  /// Notas u observaciones.
  final String? notes;
  /// Fecha de creación en el sistema.
  final DateTime createdAt;
  /// Fecha de última modificación.
  final DateTime updatedAt;

  /// Constructor con todos los atributos requeridos.
  CustomerResponseDto({
    required this.id,
    required this.tenantId,
    required this.fullName,
    this.phone,
    this.email,
    this.address,
    this.rfc,
    required this.creditLimitMxn,
    required this.creditBalanceMxn,
    required this.availableCreditMxn,
    required this.creditDays,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deserialización segura desde JSON de la API.
  factory CustomerResponseDto.fromJson(Map<String, dynamic> json) {
    return CustomerResponseDto(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      rfc: json['rfc'] as String?,
      creditLimitMxn: (json['credit_limit_mxn'] as num?)?.toDouble() ?? 0.0,
      creditBalanceMxn: (json['credit_balance_mxn'] as num?)?.toDouble() ?? 0.0,
      availableCreditMxn: (json['available_credit_mxn'] as num?)?.toDouble() ?? 0.0,
      creditDays: json['credit_days'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// DTO para solicitar el registro de un abono a cuenta de crédito (RF-15).
class CustomerCreditPaymentRequestDto {
  /// Monto abonado en Pesos Mexicanos ($ MXN).
  final double amountMxn;
  /// Método de pago utilizado (CASH_MXN, SPEI, CODI, CARD_TPV, OTHER).
  final String paymentMethod;
  /// Identificador opcional de la venta específica liquidada.
  final String? saleId;
  /// Folio o referencia bancaria del pago.
  final String? referenceCode;
  /// Notas u observaciones del abono.
  final String? notes;

  /// Constructor con validaciones.
  CustomerCreditPaymentRequestDto({
    required this.amountMxn,
    this.paymentMethod = 'CASH_MXN',
    this.saleId,
    this.referenceCode,
    this.notes,
  });

  /// Serialización segura a JSON para enviar a la API.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'amount_mxn': amountMxn,
      'payment_method': paymentMethod,
    };
    if (saleId != null) map['sale_id'] = saleId;
    if (referenceCode != null) map['reference_code'] = referenceCode;
    if (notes != null) map['notes'] = notes;
    return map;
  }
}

/// DTO de respuesta para confirmación de un abono contable exitoso.
class CustomerCreditPaymentResponseDto {
  /// Identificador del asiento en el libro mayor.
  final String ledgerId;
  /// Identificador del cliente.
  final String customerId;
  /// Nombre del cliente.
  final String customerName;
  /// Monto abonado en $ MXN.
  final double amountPaidMxn;
  /// Saldo deudor anterior en $ MXN.
  final double previousBalanceMxn;
  /// Saldo deudor resultante en $ MXN.
  final double resultingBalanceMxn;
  /// Crédito disponible resultante en $ MXN.
  final double availableCreditMxn;
  /// Método de pago utilizado.
  final String paymentMethod;
  /// Código o folio de referencia.
  final String? referenceCode;
  /// Fecha y hora del abono.
  final DateTime createdAt;

  /// Constructor de respuesta del abono.
  CustomerCreditPaymentResponseDto({
    required this.ledgerId,
    required this.customerId,
    required this.customerName,
    required this.amountPaidMxn,
    required this.previousBalanceMxn,
    required this.resultingBalanceMxn,
    required this.availableCreditMxn,
    required this.paymentMethod,
    this.referenceCode,
    required this.createdAt,
  });

  /// Deserialización segura desde JSON.
  factory CustomerCreditPaymentResponseDto.fromJson(Map<String, dynamic> json) {
    return CustomerCreditPaymentResponseDto(
      ledgerId: json['ledger_id'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      amountPaidMxn: (json['amount_paid_mxn'] as num?)?.toDouble() ?? 0.0,
      previousBalanceMxn: (json['previous_balance_mxn'] as num?)?.toDouble() ?? 0.0,
      resultingBalanceMxn: (json['resulting_balance_mxn'] as num?)?.toDouble() ?? 0.0,
      availableCreditMxn: (json['available_credit_mxn'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String,
      referenceCode: json['reference_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// DTO para un asiento individual del libro mayor de crédito / estado de cuenta.
class CreditLedgerEntryResponseDto {
  /// Identificador del asiento.
  final String id;
  /// Identificador del inquilino.
  final String tenantId;
  /// Identificador del cliente.
  final String customerId;
  /// Identificador de venta vinculada (opcional).
  final String? saleId;
  /// Tipo de asiento contable (CHARGE, PAYMENT, ADJUSTMENT).
  final LedgerEntryTypeDto entryType;
  /// Monto del movimiento en $ MXN.
  final double amountMxn;
  /// Saldo deudor anterior en $ MXN.
  final double previousBalanceMxn;
  /// Saldo deudor resultante en $ MXN.
  final double resultingBalanceMxn;
  /// Método de pago utilizado (si aplica).
  final String? paymentMethod;
  /// Código de referencia bancaria o voucher.
  final String? referenceCode;
  /// Observaciones del asiento.
  final String? notes;
  /// Usuario cajero/administrador que registró el movimiento.
  final String createdByUserId;
  /// Fecha y hora del asiento.
  final DateTime createdAt;

  /// Constructor completo.
  CreditLedgerEntryResponseDto({
    required this.id,
    required this.tenantId,
    required this.customerId,
    this.saleId,
    required this.entryType,
    required this.amountMxn,
    required this.previousBalanceMxn,
    required this.resultingBalanceMxn,
    this.paymentMethod,
    this.referenceCode,
    this.notes,
    required this.createdByUserId,
    required this.createdAt,
  });

  /// Deserialización segura desde JSON.
  factory CreditLedgerEntryResponseDto.fromJson(Map<String, dynamic> json) {
    return CreditLedgerEntryResponseDto(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      customerId: json['customer_id'] as String,
      saleId: json['sale_id'] as String?,
      entryType: LedgerEntryTypeDto.fromString(json['entry_type'] as String),
      amountMxn: (json['amount_mxn'] as num?)?.toDouble() ?? 0.0,
      previousBalanceMxn: (json['previous_balance_mxn'] as num?)?.toDouble() ?? 0.0,
      resultingBalanceMxn: (json['resulting_balance_mxn'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String?,
      referenceCode: json['reference_code'] as String?,
      notes: json['notes'] as String?,
      createdByUserId: json['created_by_user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// DTO para el Estado de Cuenta consolidado del cliente.
class CustomerStatementResponseDto {
  /// Identificador del cliente.
  final String customerId;
  /// Nombre o razón social del cliente.
  final String customerName;
  /// Límite de crédito en $ MXN.
  final double creditLimitMxn;
  /// Saldo deudor actual en $ MXN.
  final double creditBalanceMxn;
  /// Crédito disponible restante en $ MXN.
  final double availableCreditMxn;
  /// Total acumulado de cargos o compras a crédito en $ MXN.
  final double totalChargesMxn;
  /// Total acumulado de abonos o pagos en $ MXN.
  final double totalPaymentsMxn;
  /// Fecha inicial del filtro (opcional).
  final DateTime? startDate;
  /// Fecha final del filtro (opcional).
  final DateTime? endDate;
  /// Lista cronológica de asientos en el libro mayor.
  final List<CreditLedgerEntryResponseDto> entries;

  /// Constructor consolidado.
  CustomerStatementResponseDto({
    required this.customerId,
    required this.customerName,
    required this.creditLimitMxn,
    required this.creditBalanceMxn,
    required this.availableCreditMxn,
    required this.totalChargesMxn,
    required this.totalPaymentsMxn,
    this.startDate,
    this.endDate,
    required this.entries,
  });

  /// Deserialización segura desde JSON.
  factory CustomerStatementResponseDto.fromJson(Map<String, dynamic> json) {
    return CustomerStatementResponseDto(
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      creditLimitMxn: (json['credit_limit_mxn'] as num?)?.toDouble() ?? 0.0,
      creditBalanceMxn: (json['credit_balance_mxn'] as num?)?.toDouble() ?? 0.0,
      availableCreditMxn: (json['available_credit_mxn'] as num?)?.toDouble() ?? 0.0,
      totalChargesMxn: (json['total_charges_mxn'] as num?)?.toDouble() ?? 0.0,
      totalPaymentsMxn: (json['total_payments_mxn'] as num?)?.toDouble() ?? 0.0,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => CreditLedgerEntryResponseDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <CreditLedgerEntryResponseDto>[],
    );
  }
}
