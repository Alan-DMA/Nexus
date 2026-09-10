// DTOs fuertemente tipados para Órdenes de Compra, Recepción de Mercancía y Cuentas por Pagar (CxP) (RF-15, RF-16, RF-17)
// Cumplimiento estricto de .agents/AGENTS.md (No Map<String, dynamic> crudo en capas de UI/Repositorio)

/// Enumeración del estado operativo de una Orden de Compra.
enum PurchaseOrderStatusDto {
  /// Orden en borrador / edición.
  draft('DRAFT'),
  /// Orden enviada al proveedor.
  sent('SENT'),
  /// Orden confirmada por el proveedor.
  confirmed('CONFIRMED'),
  /// Recepción física parcial en almacén.
  partiallyReceived('PARTIALLY_RECEIVED'),
  /// Recepción física completa en almacén.
  received('RECEIVED'),
  /// Orden formalmente cancelada.
  cancelled('CANCELLED');

  /// Valor serializado en la API REST.
  final String value;
  const PurchaseOrderStatusDto(this.value);

  /// Construcción segura a partir de cadena.
  static PurchaseOrderStatusDto fromString(String val) {
    return PurchaseOrderStatusDto.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => PurchaseOrderStatusDto.draft,
    );
  }
}

/// Enumeración del estado financiero de una Cuenta por Pagar (CxP).
enum AccountPayableStatusDto {
  /// Deuda pendiente de pago.
  pending('PENDING'),
  /// Pago parcial registrado (saldo insoluto pendiente).
  partiallyPaid('PARTIALLY_PAID'),
  /// Totalmente liquidada / pagada ($0.00 de deuda).
  paid('PAID'),
  /// Cuenta con fecha límite vencida.
  overdue('OVERDUE'),
  /// Cuenta anulada o cancelada.
  cancelled('CANCELLED');

  /// Valor serializado en la API REST.
  final String value;
  const AccountPayableStatusDto(this.value);

  /// Construcción segura a partir de cadena.
  static AccountPayableStatusDto fromString(String val) {
    return AccountPayableStatusDto.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => AccountPayableStatusDto.pending,
    );
  }
}

/// DTO para un renglón al crear una Orden de Compra.
class PurchaseOrderItemRequestDto {
  /// Identificador único UUID del producto.
  final String productId;
  /// Cantidad ordenada.
  final double quantityOrdered;
  /// Costo unitario acordado en Pesos Mexicanos ($ MXN).
  final double unitCostMxn;
  /// Número de lote opcional.
  final String? lotNumber;
  /// Fecha de caducidad opcional (YYYY-MM-DD).
  final String? expiryDate;

  /// Constructor con validaciones.
  PurchaseOrderItemRequestDto({
    required this.productId,
    required this.quantityOrdered,
    this.unitCostMxn = 0.0,
    this.lotNumber,
    this.expiryDate,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'product_id': productId,
      'quantity_ordered': quantityOrdered,
      'unit_cost_mxn': unitCostMxn,
    };
    if (lotNumber != null) map['lot_number'] = lotNumber;
    if (expiryDate != null) map['expiry_date'] = expiryDate;
    return map;
  }
}

/// DTO para solicitar la creación de una Orden de Compra.
class PurchaseOrderCreateRequestDto {
  /// Identificador del proveedor acreedor.
  final String supplierId;
  /// Almacén de destino (opcional, por defecto el principal).
  final String? warehouseId;
  /// Lista de renglones ordenados.
  final List<PurchaseOrderItemRequestDto> items;
  /// Fecha estimada de entrega (YYYY-MM-DD).
  final String? expectedDeliveryDate;
  /// Notas u observaciones.
  final String? notes;

  /// Constructor con lista de ítems.
  PurchaseOrderCreateRequestDto({
    required this.supplierId,
    this.warehouseId,
    required this.items,
    this.expectedDeliveryDate,
    this.notes,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'supplier_id': supplierId,
      'items': items.map((i) => i.toJson()).toList(),
    };
    if (warehouseId != null) map['warehouse_id'] = warehouseId;
    if (expectedDeliveryDate != null) map['expected_delivery_date'] = expectedDeliveryDate;
    if (notes != null) map['notes'] = notes;
    return map;
  }
}

/// DTO de respuesta para un renglón de Orden de Compra.
class PurchaseOrderItemResponseDto {
  /// Identificador del renglón.
  final String id;
  /// Identificador del inquilino.
  final String tenantId;
  /// Identificador de la orden de compra padre.
  final String purchaseOrderId;
  /// Identificador del producto.
  final String productId;
  /// Nombre comercial del producto.
  final String? productName;
  /// SKU del producto.
  final String? productSku;
  /// Cantidad total ordenada.
  final double quantityOrdered;
  /// Cantidad recibida físicamente.
  final double quantityReceived;
  /// Costo unitario en $ MXN.
  final double unitCostMxn;
  /// Subtotal en $ MXN.
  final double subtotalMxn;
  /// Número de lote.
  final String? lotNumber;
  /// Fecha de caducidad.
  final String? expiryDate;
  /// Fecha de registro.
  final DateTime createdAt;

  /// Constructor del renglón de compra.
  PurchaseOrderItemResponseDto({
    required this.id,
    required this.tenantId,
    required this.purchaseOrderId,
    required this.productId,
    this.productName,
    this.productSku,
    required this.quantityOrdered,
    required this.quantityReceived,
    required this.unitCostMxn,
    required this.subtotalMxn,
    this.lotNumber,
    this.expiryDate,
    required this.createdAt,
  });

  /// Deserialización segura desde JSON.
  factory PurchaseOrderItemResponseDto.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItemResponseDto(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      purchaseOrderId: json['purchase_order_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String?,
      productSku: json['product_sku'] as String?,
      quantityOrdered: (json['quantity_ordered'] as num?)?.toDouble() ?? 0.0,
      quantityReceived: (json['quantity_received'] as num?)?.toDouble() ?? 0.0,
      unitCostMxn: (json['unit_cost_mxn'] as num?)?.toDouble() ?? 0.0,
      subtotalMxn: (json['subtotal_mxn'] as num?)?.toDouble() ?? 0.0,
      lotNumber: json['lot_number'] as String?,
      expiryDate: json['expiry_date'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// DTO de respuesta para la cabecera de Orden de Compra.
class PurchaseOrderResponseDto {
  /// Identificador único UUID de la orden.
  final String id;
  /// Identificador del inquilino.
  final String tenantId;
  /// Identificador del proveedor.
  final String supplierId;
  /// Nombre comercial del proveedor.
  final String? supplierName;
  /// RFC del proveedor.
  final String? supplierRfc;
  /// Identificador del almacén de destino.
  final String warehouseId;
  /// Nombre del almacén.
  final String? warehouseName;
  /// Consecutivo único (ej: OC-00001).
  final String folio;
  /// Estado de la orden.
  final PurchaseOrderStatusDto status;
  /// Subtotal en Pesos Mexicanos ($ MXN).
  final double subtotalMxn;
  /// Impuestos en $ MXN.
  final double taxMxn;
  /// Total en Pesos Mexicanos ($ MXN).
  final double totalMxn;
  /// Fecha estimada de entrega.
  final String? expectedDeliveryDate;
  /// Fecha real de recepción física.
  final String? receivedDate;
  /// Folio de factura o remisión del proveedor.
  final String? invoiceReference;
  /// Notas u observaciones.
  final String? notes;
  /// Usuario creador.
  final String createdByUserId;
  /// Fecha de creación.
  final DateTime createdAt;
  /// Fecha de última modificación.
  final DateTime updatedAt;
  /// Lista de renglones ordenados.
  final List<PurchaseOrderItemResponseDto> items;

  /// Constructor consolidado.
  PurchaseOrderResponseDto({
    required this.id,
    required this.tenantId,
    required this.supplierId,
    this.supplierName,
    this.supplierRfc,
    required this.warehouseId,
    this.warehouseName,
    required this.folio,
    required this.status,
    required this.subtotalMxn,
    required this.taxMxn,
    required this.totalMxn,
    this.expectedDeliveryDate,
    this.receivedDate,
    this.invoiceReference,
    this.notes,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  /// Deserialización segura desde JSON.
  factory PurchaseOrderResponseDto.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderResponseDto(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      supplierId: json['supplier_id'] as String,
      supplierName: json['supplier_name'] as String?,
      supplierRfc: json['supplier_rfc'] as String?,
      warehouseId: json['warehouse_id'] as String,
      warehouseName: json['warehouse_name'] as String?,
      folio: json['folio'] as String,
      status: PurchaseOrderStatusDto.fromString(json['status'] as String? ?? 'DRAFT'),
      subtotalMxn: (json['subtotal_mxn'] as num?)?.toDouble() ?? 0.0,
      taxMxn: (json['tax_mxn'] as num?)?.toDouble() ?? 0.0,
      totalMxn: (json['total_mxn'] as num?)?.toDouble() ?? 0.0,
      expectedDeliveryDate: json['expected_delivery_date'] as String?,
      receivedDate: json['received_date'] as String?,
      invoiceReference: json['invoice_reference'] as String?,
      notes: json['notes'] as String?,
      createdByUserId: json['created_by_user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PurchaseOrderItemResponseDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <PurchaseOrderItemResponseDto>[],
    );
  }
}

/// DTO para renglón individual de recepción de mercancía.
class PurchaseOrderReceiveItemRequestDto {
  /// Identificador del renglón de compra.
  final String purchaseOrderItemId;
  /// Cantidad recibida físicamente.
  final double quantityReceived;
  /// Costo unitario real facturado si difiere de la cotización ($ MXN).
  final double? unitCostMxn;
  /// Número de lote de fábrica.
  final String? lotNumber;
  /// Fecha de caducidad (YYYY-MM-DD).
  final String? expiryDate;

  /// Constructor con validaciones.
  PurchaseOrderReceiveItemRequestDto({
    required this.purchaseOrderItemId,
    required this.quantityReceived,
    this.unitCostMxn,
    this.lotNumber,
    this.expiryDate,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'purchase_order_item_id': purchaseOrderItemId,
      'quantity_received': quantityReceived,
    };
    if (unitCostMxn != null) map['unit_cost_mxn'] = unitCostMxn;
    if (lotNumber != null) map['lot_number'] = lotNumber;
    if (expiryDate != null) map['expiry_date'] = expiryDate;
    return map;
  }
}

/// DTO para la solicitud de recepción física en almacén.
class PurchaseOrderReceiveRequestDto {
  /// Lista de renglones recepcionados.
  final List<PurchaseOrderReceiveItemRequestDto> itemsReceived;
  /// Fecha real de entrega.
  final String? receivedDate;
  /// Folio o factura del proveedor.
  final String? invoiceReference;
  /// Observaciones.
  final String? notes;

  /// Constructor de recepción.
  PurchaseOrderReceiveRequestDto({
    required this.itemsReceived,
    this.receivedDate,
    this.invoiceReference,
    this.notes,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'items_received': itemsReceived.map((i) => i.toJson()).toList(),
    };
    if (receivedDate != null) map['received_date'] = receivedDate;
    if (invoiceReference != null) map['invoice_reference'] = invoiceReference;
    if (notes != null) map['notes'] = notes;
    return map;
  }
}

/// DTO de respuesta para una Cuenta por Pagar a Proveedor (CxP).
class AccountPayableResponseDto {
  /// Identificador único UUID de la cuenta.
  final String id;
  /// Identificador del inquilino.
  final String tenantId;
  /// Identificador del proveedor.
  final String supplierId;
  /// Nombre comercial del proveedor.
  final String? supplierName;
  /// Identificador de la orden de compra origen.
  final String? purchaseOrderId;
  /// Consecutivo único de la cuenta (ej: CXP-00001).
  final String folio;
  /// Total adeudado en Pesos Mexicanos ($ MXN).
  final double totalMxn;
  /// Monto abonado acumulado en $ MXN.
  final double amountPaidMxn;
  /// Saldo insoluto pendiente en $ MXN.
  final double pendingAmountMxn;
  /// Estado financiero de la cuenta.
  final AccountPayableStatusDto status;
  /// Fecha límite de vencimiento (YYYY-MM-DD).
  final String dueDate;
  /// Bandera de cuenta vencida.
  final bool isOverdue;
  /// Número de factura o remisión del proveedor.
  final String? invoiceReference;
  /// Notas.
  final String? notes;
  /// Fecha de registro.
  final DateTime createdAt;
  /// Fecha de actualización.
  final DateTime updatedAt;

  /// Constructor completo.
  AccountPayableResponseDto({
    required this.id,
    required this.tenantId,
    required this.supplierId,
    this.supplierName,
    this.purchaseOrderId,
    required this.folio,
    required this.totalMxn,
    required this.amountPaidMxn,
    required this.pendingAmountMxn,
    required this.status,
    required this.dueDate,
    required this.isOverdue,
    this.invoiceReference,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deserialización segura desde JSON.
  factory AccountPayableResponseDto.fromJson(Map<String, dynamic> json) {
    return AccountPayableResponseDto(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      supplierId: json['supplier_id'] as String,
      supplierName: json['supplier_name'] as String?,
      purchaseOrderId: json['purchase_order_id'] as String?,
      folio: json['folio'] as String,
      totalMxn: (json['total_mxn'] as num?)?.toDouble() ?? 0.0,
      amountPaidMxn: (json['amount_paid_mxn'] as num?)?.toDouble() ?? 0.0,
      pendingAmountMxn: (json['pending_amount_mxn'] as num?)?.toDouble() ?? 0.0,
      status: AccountPayableStatusDto.fromString(json['status'] as String? ?? 'PENDING'),
      dueDate: json['due_date'] as String,
      isOverdue: json['is_overdue'] as bool? ?? false,
      invoiceReference: json['invoice_reference'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// DTO para la solicitud de abono/pago a una cuenta por pagar.
class SupplierPaymentRequestDto {
  /// Monto abonado en Pesos Mexicanos ($ MXN).
  final double amountPaidMxn;
  /// Método de pago utilizado (CASH_MXN, SPEI, CODI, CARD_TPV, OTHER).
  final String paymentMethod;
  /// Fecha del pago (YYYY-MM-DD).
  final String? paymentDate;
  /// Código o folio de transferencia bancaria / cheque.
  final String? referenceCode;
  /// Notas.
  final String? notes;

  /// Constructor con validaciones.
  SupplierPaymentRequestDto({
    required this.amountPaidMxn,
    this.paymentMethod = 'CASH_MXN',
    this.paymentDate,
    this.referenceCode,
    this.notes,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'amount_paid_mxn': amountPaidMxn,
      'payment_method': paymentMethod,
    };
    if (paymentDate != null) map['payment_date'] = paymentDate;
    if (referenceCode != null) map['reference_code'] = referenceCode;
    if (notes != null) map['notes'] = notes;
    return map;
  }
}

/// DTO de respuesta para confirmación de abono a proveedor.
class SupplierPaymentResponseDto {
  /// Identificador del asiento en el libro mayor de pagos.
  final String id;
  /// Identificador de la cuenta por pagar.
  final String accountPayableId;
  /// Identificador del proveedor.
  final String supplierId;
  /// Nombre del proveedor.
  final String supplierName;
  /// Monto abonado en $ MXN.
  final double amountPaidMxn;
  /// Saldo pendiente anterior en $ MXN.
  final double previousPendingMxn;
  /// Saldo pendiente resultante en $ MXN.
  final double resultingPendingMxn;
  /// Estado resultante de la cuenta por pagar.
  final AccountPayableStatusDto resultingStatus;
  /// Método de pago utilizado.
  final String paymentMethod;
  /// Referencia o folio de transferencia.
  final String? referenceCode;
  /// Fecha del pago.
  final String paymentDate;
  /// Fecha y hora de registro.
  final DateTime createdAt;

  /// Constructor del abono.
  SupplierPaymentResponseDto({
    required this.id,
    required this.accountPayableId,
    required this.supplierId,
    required this.supplierName,
    required this.amountPaidMxn,
    required this.previousPendingMxn,
    required this.resultingPendingMxn,
    required this.resultingStatus,
    required this.paymentMethod,
    this.referenceCode,
    required this.paymentDate,
    required this.createdAt,
  });

  /// Deserialización segura desde JSON.
  factory SupplierPaymentResponseDto.fromJson(Map<String, dynamic> json) {
    return SupplierPaymentResponseDto(
      id: json['id'] as String,
      accountPayableId: json['account_payable_id'] as String,
      supplierId: json['supplier_id'] as String,
      supplierName: json['supplier_name'] as String,
      amountPaidMxn: (json['amount_paid_mxn'] as num?)?.toDouble() ?? 0.0,
      previousPendingMxn: (json['previous_pending_mxn'] as num?)?.toDouble() ?? 0.0,
      resultingPendingMxn: (json['resulting_pending_mxn'] as num?)?.toDouble() ?? 0.0,
      resultingStatus: AccountPayableStatusDto.fromString(json['resulting_status'] as String? ?? 'PENDING'),
      paymentMethod: json['payment_method'] as String,
      referenceCode: json['reference_code'] as String?,
      paymentDate: json['payment_date'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// DTO para el resumen financiero consolidado de Cuentas por Pagar.
class AccountsPayableSummaryResponseDto {
  /// Total pendiente de pago en Pesos Mexicanos ($ MXN).
  final double totalPendingMxn;
  /// Total pagado acumulado en $ MXN.
  final double totalPaidMxn;
  /// Monto total de facturas vencidas en $ MXN.
  final double overdueAmountMxn;
  /// Cantidad de facturas vencidas.
  final int overdueCount;
  /// Cantidad de facturas pendientes totales.
  final int pendingCount;

  /// Constructor del resumen.
  AccountsPayableSummaryResponseDto({
    required this.totalPendingMxn,
    required this.totalPaidMxn,
    required this.overdueAmountMxn,
    required this.overdueCount,
    required this.pendingCount,
  });

  /// Deserialización segura desde JSON.
  factory AccountsPayableSummaryResponseDto.fromJson(Map<String, dynamic> json) {
    return AccountsPayableSummaryResponseDto(
      totalPendingMxn: (json['total_pending_mxn'] as num?)?.toDouble() ?? 0.0,
      totalPaidMxn: (json['total_paid_mxn'] as num?)?.toDouble() ?? 0.0,
      overdueAmountMxn: (json['overdue_amount_mxn'] as num?)?.toDouble() ?? 0.0,
      overdueCount: json['overdue_count'] as int? ?? 0,
      pendingCount: json['pending_count'] as int? ?? 0,
    );
  }
}

/// DTO de respuesta consolidada para la recepción física de una orden.
class PurchaseOrderReceiveResponseDto {
  /// Orden de compra actualizada.
  final PurchaseOrderResponseDto purchaseOrder;
  /// Cantidad de movimientos de stock registrados en Kardex.
  final int stockMovementsCount;
  /// Cuenta por pagar generada automáticamente (si aplica).
  final AccountPayableResponseDto? accountPayable;

  /// Constructor de respuesta de recepción.
  PurchaseOrderReceiveResponseDto({
    required this.purchaseOrder,
    required this.stockMovementsCount,
    this.accountPayable,
  });

  /// Deserialización segura desde JSON.
  factory PurchaseOrderReceiveResponseDto.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderReceiveResponseDto(
      purchaseOrder: PurchaseOrderResponseDto.fromJson(json['purchase_order'] as Map<String, dynamic>),
      stockMovementsCount: json['stock_movements_count'] as int? ?? 0,
      accountPayable: json['account_payable'] != null
          ? AccountPayableResponseDto.fromJson(json['account_payable'] as Map<String, dynamic>)
          : null,
    );
  }
}
