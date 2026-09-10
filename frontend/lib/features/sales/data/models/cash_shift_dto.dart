// Modelos DTO fuertemente tipados para Turnos de Caja, Movimientos y Arqueo (RF-16, RF-17 / Const. Art. 3.3, 7.2)

/// Enumeración de estados posibles de un Turno de Caja en POS.
enum ShiftStatusDto {
  /// Turno actualmente abierto y operativo en mostrador.
  open('OPEN'),
  /// Turno formalmente cerrado con arqueo de efectivo finalizado.
  closed('CLOSED');

  /// Valor serializado en la API REST.
  final String value;
  const ShiftStatusDto(this.value);

  /// Construcción segura a partir de cadena.
  static ShiftStatusDto fromString(String val) {
    return ShiftStatusDto.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => ShiftStatusDto.open,
    );
  }
}

/// Enumeración de clasificación de discrepancias en el arqueo a ciegas.
enum DifferenceStatusDto {
  /// Conteo exacto ($0.00 de diferencia).
  exact('EXACT'),
  /// Dinero físico en caja excede el saldo teórico esperado (Sobrante).
  surplus('SURPLUS'),
  /// Dinero físico en caja es inferior al saldo teórico esperado (Faltante).
  shortage('SHORTAGE');

  /// Valor serializado en la API REST.
  final String value;
  const DifferenceStatusDto(this.value);

  /// Construcción segura a partir de cadena.
  static DifferenceStatusDto fromString(String val) {
    return DifferenceStatusDto.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => DifferenceStatusDto.exact,
    );
  }
}

/// Enumeración para los tipos de movimientos manuales de caja chica.
enum CashMovementTypeDto {
  /// Entrada manual de efectivo (aportación de cambio / depósito).
  cashIn('CASH_IN'),
  /// Salida manual de efectivo (pago menor, gasto operativo, retiro parcial).
  cashOut('CASH_OUT');

  /// Valor serializado en la API REST.
  final String value;
  const CashMovementTypeDto(this.value);

  /// Construcción segura a partir de cadena.
  static CashMovementTypeDto fromString(String val) {
    return CashMovementTypeDto.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => CashMovementTypeDto.cashIn,
    );
  }
}

/// DTO de solicitud para la apertura de turno de caja.
class CashShiftOpenRequestDto {
  /// Fondo inicial de efectivo para cambio en MXN ($).
  final double openingBalanceMxn;
  /// Identificador de la sucursal o almacén asignado (opcional).
  final String? warehouseId;
  /// Observaciones o notas de apertura.
  final String? notes;

  const CashShiftOpenRequestDto({
    this.openingBalanceMxn = 0.0,
    this.warehouseId,
    this.notes,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'opening_balance_mxn': openingBalanceMxn,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (notes != null) 'notes': notes,
    };
  }
}

/// DTO de solicitud para registrar un movimiento manual de efectivo.
class CashMovementCreateRequestDto {
  /// Tipo de movimiento (CASH_IN o CASH_OUT).
  final CashMovementTypeDto movementType;
  /// Monto del movimiento en Pesos Mexicanos (estrictamente > 0).
  final double amountMxn;
  /// Motivo o justificación del movimiento.
  final String reason;
  /// Notas adicionales (opcional).
  final String? notes;
  /// Supervisor autorizador (opcional).
  final String? authorizedByUserId;

  const CashMovementCreateRequestDto({
    required this.movementType,
    required this.amountMxn,
    required this.reason,
    this.notes,
    this.authorizedByUserId,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'movement_type': movementType.value,
      'amount_mxn': amountMxn,
      'reason': reason,
      if (notes != null) 'notes': notes,
      if (authorizedByUserId != null) 'authorized_by_user_id': authorizedByUserId,
    };
  }
}

/// DTO de solicitud para el arqueo a ciegas y cierre de turno.
class CashShiftCloseRequestDto {
  /// Conteo físico de dinero en efectivo contado por el cajero en MXN ($).
  final double countedCashMxn;
  /// Notas u observaciones de auditoría.
  final String? notes;

  const CashShiftCloseRequestDto({
    required this.countedCashMxn,
    this.notes,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'counted_cash_mxn': countedCashMxn,
      if (notes != null) 'notes': notes,
    };
  }
}

/// DTO de respuesta para un movimiento manual de caja chica.
class CashMovementResponseDto {
  /// Identificador único del movimiento.
  final String id;
  /// Identificador del inquilino.
  final String tenantId;
  /// Identificador del turno asociado.
  final String shiftId;
  /// Tipo de movimiento (CASH_IN o CASH_OUT).
  final CashMovementTypeDto movementType;
  /// Monto en Pesos Mexicanos.
  final double amountMxn;
  /// Motivo descriptivo.
  final String reason;
  /// Notas adicionales.
  final String? notes;
  /// Supervisor autorizador.
  final String? authorizedByUserId;
  /// Usuario cajero que registró el movimiento.
  final String createdByUserId;
  /// Fecha y hora de creación.
  final DateTime createdAt;

  const CashMovementResponseDto({
    required this.id,
    required this.tenantId,
    required this.shiftId,
    required this.movementType,
    required this.amountMxn,
    required this.reason,
    this.notes,
    this.authorizedByUserId,
    required this.createdByUserId,
    required this.createdAt,
  });

  /// Deserialización segura desde JSON.
  factory CashMovementResponseDto.fromJson(Map<String, dynamic> json) {
    return CashMovementResponseDto(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      shiftId: json['shift_id'] as String? ?? '',
      movementType: CashMovementTypeDto.fromString(json['movement_type'] as String? ?? 'CASH_IN'),
      amountMxn: (json['amount_mxn'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String? ?? '',
      notes: json['notes'] as String?,
      authorizedByUserId: json['authorized_by_user_id'] as String?,
      createdByUserId: json['created_by_user_id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

/// DTO de resumen consolidado por método de pago.
class PaymentMethodSummaryDto {
  /// Método de pago (CASH_MXN, CARD_TPV, SPEI, CODI, OTHER).
  final String paymentMethod;
  /// Total cobrado en MXN ($).
  final double totalMxn;
  /// Cantidad de transacciones.
  final int transactionCount;

  const PaymentMethodSummaryDto({
    required this.paymentMethod,
    required this.totalMxn,
    required this.transactionCount,
  });

  /// Deserialización segura desde JSON.
  factory PaymentMethodSummaryDto.fromJson(Map<String, dynamic> json) {
    return PaymentMethodSummaryDto(
      paymentMethod: json['payment_method'] as String? ?? '',
      totalMxn: (json['total_mxn'] as num?)?.toDouble() ?? 0.0,
      transactionCount: (json['transaction_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// DTO de respuesta para el resumen contable y arqueo de un turno de caja.
class CashShiftSummaryResponseDto {
  /// Identificador del turno.
  final String shiftId;
  /// Identificador del cajero.
  final String cashierId;
  /// Identificador de la sucursal.
  final String? warehouseId;
  /// Estado del turno.
  final ShiftStatusDto status;
  /// Fecha de apertura.
  final DateTime openedAt;
  /// Fecha de cierre.
  final DateTime? closedAt;
  /// Fondo inicial de caja en MXN ($).
  final double openingBalanceMxn;
  /// Total de ventas cobradas en efectivo en MXN ($).
  final double totalCashSalesMxn;
  /// Total de entradas manuales en MXN ($).
  final double totalCashInMxn;
  /// Total de salidas manuales en MXN ($).
  final double totalCashOutMxn;
  /// Saldo teórico esperado en efectivo en MXN ($).
  final double expectedCashMxn;
  /// Efectivo físico contado en el arqueo en MXN ($).
  final double? countedCashMxn;
  /// Diferencia monetaria (conteo - esperado) en MXN ($).
  final double? differenceMxn;
  /// Clasificación del arqueo (EXACT, SURPLUS, SHORTAGE).
  final DifferenceStatusDto? differenceStatus;
  /// Desglose por método de pago.
  final List<PaymentMethodSummaryDto> paymentMethodsSummary;
  /// Ventas brutas totales del turno en MXN ($).
  final double totalSalesMxn;
  /// Total de transacciones de venta completadas.
  final int totalSalesCount;

  const CashShiftSummaryResponseDto({
    required this.shiftId,
    required this.cashierId,
    this.warehouseId,
    required this.status,
    required this.openedAt,
    this.closedAt,
    required this.openingBalanceMxn,
    required this.totalCashSalesMxn,
    required this.totalCashInMxn,
    required this.totalCashOutMxn,
    required this.expectedCashMxn,
    this.countedCashMxn,
    this.differenceMxn,
    this.differenceStatus,
    required this.paymentMethodsSummary,
    required this.totalSalesMxn,
    required this.totalSalesCount,
  });

  /// Deserialización segura desde JSON.
  factory CashShiftSummaryResponseDto.fromJson(Map<String, dynamic> json) {
    return CashShiftSummaryResponseDto(
      shiftId: json['shift_id'] as String? ?? '',
      cashierId: json['cashier_id'] as String? ?? '',
      warehouseId: json['warehouse_id'] as String?,
      status: ShiftStatusDto.fromString(json['status'] as String? ?? 'OPEN'),
      openedAt: json['opened_at'] != null
          ? DateTime.parse(json['opened_at'] as String)
          : DateTime.now(),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      openingBalanceMxn: (json['opening_balance_mxn'] as num?)?.toDouble() ?? 0.0,
      totalCashSalesMxn: (json['total_cash_sales_mxn'] as num?)?.toDouble() ?? 0.0,
      totalCashInMxn: (json['total_cash_in_mxn'] as num?)?.toDouble() ?? 0.0,
      totalCashOutMxn: (json['total_cash_out_mxn'] as num?)?.toDouble() ?? 0.0,
      expectedCashMxn: (json['expected_cash_mxn'] as num?)?.toDouble() ?? 0.0,
      countedCashMxn: (json['counted_cash_mxn'] as num?)?.toDouble(),
      differenceMxn: (json['difference_mxn'] as num?)?.toDouble(),
      differenceStatus: json['difference_status'] != null
          ? DifferenceStatusDto.fromString(json['difference_status'] as String)
          : null,
      paymentMethodsSummary: (json['payment_methods_summary'] as List<dynamic>?)
              ?.map((item) => PaymentMethodSummaryDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalSalesMxn: (json['total_sales_mxn'] as num?)?.toDouble() ?? 0.0,
      totalSalesCount: (json['total_sales_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// DTO de respuesta completo para un Turno de Caja con sus movimientos asociados.
class CashShiftResponseDto {
  /// Identificador único del turno.
  final String id;
  /// Identificador del inquilino.
  final String tenantId;
  /// Identificador del cajero responsable.
  final String cashierId;
  /// Identificador de la sucursal o almacén.
  final String? warehouseId;
  /// Estado operativo del turno (OPEN o CLOSED).
  final ShiftStatusDto status;
  /// Fondo inicial de caja en MXN ($).
  final double openingBalanceMxn;
  /// Conteo físico de efectivo en MXN ($).
  final double? countedCashMxn;
  /// Saldo esperado según registros del sistema en MXN ($).
  final double? expectedCashMxn;
  /// Diferencia de arqueo en MXN ($).
  final double? differenceMxn;
  /// Fecha y hora de apertura.
  final DateTime openedAt;
  /// Fecha y hora de cierre.
  final DateTime? closedAt;
  /// Usuario que cerró el turno.
  final String? closedByUserId;
  /// Notas u observaciones de auditoría.
  final String? notes;
  /// Lista de movimientos manuales de caja asociados al turno.
  final List<CashMovementResponseDto> movements;
  /// Fecha de creación.
  final DateTime createdAt;
  /// Fecha de última modificación.
  final DateTime updatedAt;

  const CashShiftResponseDto({
    required this.id,
    required this.tenantId,
    required this.cashierId,
    this.warehouseId,
    required this.status,
    required this.openingBalanceMxn,
    this.countedCashMxn,
    this.expectedCashMxn,
    this.differenceMxn,
    required this.openedAt,
    this.closedAt,
    this.closedByUserId,
    this.notes,
    required this.movements,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deserialización segura desde JSON.
  factory CashShiftResponseDto.fromJson(Map<String, dynamic> json) {
    return CashShiftResponseDto(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      cashierId: json['cashier_id'] as String? ?? '',
      warehouseId: json['warehouse_id'] as String?,
      status: ShiftStatusDto.fromString(json['status'] as String? ?? 'OPEN'),
      openingBalanceMxn: (json['opening_balance_mxn'] as num?)?.toDouble() ?? 0.0,
      countedCashMxn: (json['counted_cash_mxn'] as num?)?.toDouble(),
      expectedCashMxn: (json['expected_cash_mxn'] as num?)?.toDouble(),
      differenceMxn: (json['difference_mxn'] as num?)?.toDouble(),
      openedAt: json['opened_at'] != null
          ? DateTime.parse(json['opened_at'] as String)
          : DateTime.now(),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      closedByUserId: json['closed_by_user_id'] as String?,
      notes: json['notes'] as String?,
      movements: (json['movements'] as List<dynamic>?)
              ?.map((item) => CashMovementResponseDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
