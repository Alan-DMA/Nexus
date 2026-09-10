// DTOs fuertemente tipados para el Módulo de Ventas POS, Checkout, Pagos, Tickets Térmicos y Comisiones
// Cumplimiento estricto de .agents/AGENTS.md (No Map<String, dynamic> crudo en capas de presentación / repositorio)

class SaleItemRequestDto {
  // ID del producto existente (opcional si es al vuelo o combo)
  final String? productId;
  // ID del combo (opcional)
  final String? comboId;
  // Cantidad a vender
  final double quantity;
  // Precio unitario en Pesos Mexicanos ($ MXN)
  final double? unitPriceMxn;
  // Descuento en $ MXN
  final double discountMxn;
  // Bandera de producto al vuelo (Lazy Loading RF-09)
  final bool isOnTheFly;
  // Nombre si es al vuelo
  final String? onTheFlyName;
  // Código de barras si es al vuelo
  final String? onTheFlyBarcode;
  // Costo si es al vuelo
  final double? onTheFlyCostMxn;

  SaleItemRequestDto({
    this.productId,
    this.comboId,
    required this.quantity,
    this.unitPriceMxn,
    this.discountMxn = 0.0,
    this.isOnTheFly = false,
    this.onTheFlyName,
    this.onTheFlyBarcode,
    this.onTheFlyCostMxn,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'quantity': quantity,
      'discount_mxn': discountMxn,
      'is_on_the_fly': isOnTheFly,
    };
    if (productId != null) map['product_id'] = productId;
    if (comboId != null) map['combo_id'] = comboId;
    if (unitPriceMxn != null) map['unit_price_mxn'] = unitPriceMxn;
    if (onTheFlyName != null) map['on_the_fly_name'] = onTheFlyName;
    if (onTheFlyBarcode != null) map['on_the_fly_barcode'] = onTheFlyBarcode;
    if (onTheFlyCostMxn != null) map['on_the_fly_cost_mxn'] = onTheFlyCostMxn;
    return map;
  }
}

class SalePaymentRequestDto {
  // Método de pago (CASH_MXN, SPEI, CODI, CARD_TPV, OTHER)
  final String paymentMethod;
  // Monto pagado en $ MXN
  final double amountPaidMxn;
  // Código de autorización o referencia
  final String? referenceCode;
  // Observaciones
  final String? notes;

  SalePaymentRequestDto({
    required this.paymentMethod,
    required this.amountPaidMxn,
    this.referenceCode,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'payment_method': paymentMethod,
        'amount_paid_mxn': amountPaidMxn,
        if (referenceCode != null) 'reference_code': referenceCode,
        if (notes != null) 'notes': notes,
      };
}

class SaleCheckoutRequestDto {
  // ID del almacén físico
  final String warehouseId;
  // ID opcional del cliente
  final String? clientId;
  // Partidas de la venta
  final List<SaleItemRequestDto> items;
  // Pagos registrados
  final List<SalePaymentRequestDto>? payments;
  // Admite pago parcial o diferido (PENDING_PAYMENT)
  final bool allowPartialPayment;
  // Descuento global
  final double discountMxn;
  // Notas u observaciones
  final String? notes;

  SaleCheckoutRequestDto({
    required this.warehouseId,
    this.clientId,
    required this.items,
    this.payments,
    this.allowPartialPayment = false,
    this.discountMxn = 0.0,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'warehouse_id': warehouseId,
        if (clientId != null) 'client_id': clientId,
        'items': items.map((i) => i.toJson()).toList(),
        if (payments != null)
          'payments': payments!.map((p) => p.toJson()).toList(),
        'allow_partial_payment': allowPartialPayment,
        'discount_mxn': discountMxn,
        if (notes != null) 'notes': notes,
      };
}

class SaleItemResponseDto {
  final String id;
  final String saleId;
  final String? productId;
  final String productName;
  final String? productSku;
  final double quantity;
  final double unitPriceMxn;
  final double unitCostMxn;
  final double subtotalMxn;
  final double totalMxn;
  final double profitMxn;

  SaleItemResponseDto({
    required this.id,
    required this.saleId,
    this.productId,
    required this.productName,
    this.productSku,
    required this.quantity,
    required this.unitPriceMxn,
    required this.unitCostMxn,
    required this.subtotalMxn,
    required this.totalMxn,
    required this.profitMxn,
  });

  factory SaleItemResponseDto.fromJson(Map<String, dynamic> json) {
    return SaleItemResponseDto(
      id: json['id']?.toString() ?? '',
      saleId: json['sale_id']?.toString() ?? '',
      productId: json['product_id']?.toString(),
      productName: json['product_name']?.toString() ?? '',
      productSku: json['product_sku']?.toString(),
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      unitPriceMxn: double.tryParse(json['unit_price_mxn']?.toString() ?? '0') ?? 0.0,
      unitCostMxn: double.tryParse(json['unit_cost_mxn']?.toString() ?? '0') ?? 0.0,
      subtotalMxn: double.tryParse(json['subtotal_mxn']?.toString() ?? '0') ?? 0.0,
      totalMxn: double.tryParse(json['total_mxn']?.toString() ?? '0') ?? 0.0,
      profitMxn: double.tryParse(json['profit_mxn']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class PaymentResponseDto {
  final String id;
  final String saleId;
  final String paymentMethod;
  final double amountPaidMxn;
  final double changeReturnedMxn;
  final String? referenceCode;
  final String? notes;
  final String createdAt;

  PaymentResponseDto({
    required this.id,
    required this.saleId,
    required this.paymentMethod,
    required this.amountPaidMxn,
    required this.changeReturnedMxn,
    this.referenceCode,
    this.notes,
    required this.createdAt,
  });

  factory PaymentResponseDto.fromJson(Map<String, dynamic> json) {
    return PaymentResponseDto(
      id: json['id']?.toString() ?? '',
      saleId: json['sale_id']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? 'CASH_MXN',
      amountPaidMxn: double.tryParse(json['amount_paid_mxn']?.toString() ?? '0') ?? 0.0,
      changeReturnedMxn: double.tryParse(json['change_returned_mxn']?.toString() ?? '0') ?? 0.0,
      referenceCode: json['reference_code']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class SaleResponseDto {
  final String id;
  final String folio;
  final String status;
  final double subtotalMxn;
  final double discountMxn;
  final double taxMxn;
  final double totalMxn;
  final double totalCostMxn;
  final double grossProfitMxn;
  final String? paymentMethodType;
  final double amountPaidMxn;
  final double changeReturnedMxn;
  final List<SaleItemResponseDto> items;
  final List<PaymentResponseDto> payments;
  final String createdAt;

  SaleResponseDto({
    required this.id,
    required this.folio,
    required this.status,
    required this.subtotalMxn,
    required this.discountMxn,
    required this.taxMxn,
    required this.totalMxn,
    required this.totalCostMxn,
    required this.grossProfitMxn,
    this.paymentMethodType,
    this.amountPaidMxn = 0.0,
    this.changeReturnedMxn = 0.0,
    required this.items,
    this.payments = const [],
    required this.createdAt,
  });

  factory SaleResponseDto.fromJson(Map<String, dynamic> json) {
    return SaleResponseDto(
      id: json['id']?.toString() ?? '',
      folio: json['folio']?.toString() ?? '',
      status: json['status']?.toString() ?? 'COMPLETED',
      subtotalMxn: double.tryParse(json['subtotal_mxn']?.toString() ?? '0') ?? 0.0,
      discountMxn: double.tryParse(json['discount_mxn']?.toString() ?? '0') ?? 0.0,
      taxMxn: double.tryParse(json['tax_mxn']?.toString() ?? '0') ?? 0.0,
      totalMxn: double.tryParse(json['total_mxn']?.toString() ?? '0') ?? 0.0,
      totalCostMxn: double.tryParse(json['total_cost_mxn']?.toString() ?? '0') ?? 0.0,
      grossProfitMxn: double.tryParse(json['gross_profit_mxn']?.toString() ?? '0') ?? 0.0,
      paymentMethodType: json['payment_method_type']?.toString(),
      amountPaidMxn: double.tryParse(json['amount_paid_mxn']?.toString() ?? '0') ?? 0.0,
      changeReturnedMxn: double.tryParse(json['change_returned_mxn']?.toString() ?? '0') ?? 0.0,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => SaleItemResponseDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      payments: (json['payments'] as List<dynamic>?)
              ?.map((item) => PaymentResponseDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

// ============================================================================
// DTOs DE CONFIGURACIÓN Y FORMATEO DE TICKETS TÉRMICOS (RF-08)
// ============================================================================

class TicketSettingsUpdateRequestDto {
  final String? businessName;
  final String? legalName;
  final String? rfc;
  final String? address;
  final String? phone;
  final String? email;
  final String? footerMessage;
  final int? paperWidthMm;
  final bool? showSavings;
  final bool? showCashierName;
  final bool? showTaxes;

  TicketSettingsUpdateRequestDto({
    this.businessName,
    this.legalName,
    this.rfc,
    this.address,
    this.phone,
    this.email,
    this.footerMessage,
    this.paperWidthMm,
    this.showSavings,
    this.showCashierName,
    this.showTaxes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (businessName != null) map['business_name'] = businessName;
    if (legalName != null) map['legal_name'] = legalName;
    if (rfc != null) map['rfc'] = rfc;
    if (address != null) map['address'] = address;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (footerMessage != null) map['footer_message'] = footerMessage;
    if (paperWidthMm != null) map['paper_width_mm'] = paperWidthMm;
    if (showSavings != null) map['show_savings'] = showSavings;
    if (showCashierName != null) map['show_cashier_name'] = showCashierName;
    if (showTaxes != null) map['show_taxes'] = showTaxes;
    return map;
  }
}

class TicketSettingsResponseDto {
  final String tenantId;
  final String? businessName;
  final String? legalName;
  final String? rfc;
  final String? address;
  final String? phone;
  final String? email;
  final String footerMessage;
  final int paperWidthMm;
  final bool showSavings;
  final bool showCashierName;
  final bool showTaxes;
  final String updatedAt;

  TicketSettingsResponseDto({
    required this.tenantId,
    this.businessName,
    this.legalName,
    this.rfc,
    this.address,
    this.phone,
    this.email,
    required this.footerMessage,
    required this.paperWidthMm,
    required this.showSavings,
    required this.showCashierName,
    required this.showTaxes,
    required this.updatedAt,
  });

  factory TicketSettingsResponseDto.fromJson(Map<String, dynamic> json) {
    return TicketSettingsResponseDto(
      tenantId: json['tenant_id']?.toString() ?? '',
      businessName: json['business_name']?.toString(),
      legalName: json['legal_name']?.toString(),
      rfc: json['rfc']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      footerMessage: json['footer_message']?.toString() ?? '¡Gracias por su compra!',
      paperWidthMm: int.tryParse(json['paper_width_mm']?.toString() ?? '58') ?? 58,
      showSavings: json['show_savings'] as bool? ?? true,
      showCashierName: json['show_cashier_name'] as bool? ?? true,
      showTaxes: json['show_taxes'] as bool? ?? false,
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class TicketLineItemPayloadDto {
  final double quantity;
  final String productName;
  final double unitPriceMxn;
  final double discountMxn;
  final double totalMxn;

  TicketLineItemPayloadDto({
    required this.quantity,
    required this.productName,
    required this.unitPriceMxn,
    required this.discountMxn,
    required this.totalMxn,
  });

  factory TicketLineItemPayloadDto.fromJson(Map<String, dynamic> json) {
    return TicketLineItemPayloadDto(
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      productName: json['product_name']?.toString() ?? '',
      unitPriceMxn: double.tryParse(json['unit_price_mxn']?.toString() ?? '0') ?? 0.0,
      discountMxn: double.tryParse(json['discount_mxn']?.toString() ?? '0') ?? 0.0,
      totalMxn: double.tryParse(json['total_mxn']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class TicketPaymentPayloadDto {
  final String paymentMethod;
  final double amountPaidMxn;
  final String? referenceCode;

  TicketPaymentPayloadDto({
    required this.paymentMethod,
    required this.amountPaidMxn,
    this.referenceCode,
  });

  factory TicketPaymentPayloadDto.fromJson(Map<String, dynamic> json) {
    return TicketPaymentPayloadDto(
      paymentMethod: json['payment_method']?.toString() ?? 'CASH_MXN',
      amountPaidMxn: double.tryParse(json['amount_paid_mxn']?.toString() ?? '0') ?? 0.0,
      referenceCode: json['reference_code']?.toString(),
    );
  }
}

class TicketPayloadResponseDto {
  final String folio;
  final String createdAt;
  final String? cashierName;
  final String businessName;
  final String? legalName;
  final String? rfc;
  final String? address;
  final String? phone;
  final String? email;
  final int paperWidthMm;
  final List<TicketLineItemPayloadDto> items;
  final double subtotalMxn;
  final double discountMxn;
  final double taxMxn;
  final double totalMxn;
  final double amountPaidMxn;
  final double changeReturnedMxn;
  final double savingsMxn;
  final List<TicketPaymentPayloadDto> payments;
  final String footerMessage;
  final String formattedText;

  TicketPayloadResponseDto({
    required this.folio,
    required this.createdAt,
    this.cashierName,
    required this.businessName,
    this.legalName,
    this.rfc,
    this.address,
    this.phone,
    this.email,
    required this.paperWidthMm,
    required this.items,
    required this.subtotalMxn,
    required this.discountMxn,
    required this.taxMxn,
    required this.totalMxn,
    required this.amountPaidMxn,
    required this.changeReturnedMxn,
    required this.savingsMxn,
    required this.payments,
    required this.footerMessage,
    required this.formattedText,
  });

  factory TicketPayloadResponseDto.fromJson(Map<String, dynamic> json) {
    return TicketPayloadResponseDto(
      folio: json['folio']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      cashierName: json['cashier_name']?.toString(),
      businessName: json['business_name']?.toString() ?? '',
      legalName: json['legal_name']?.toString(),
      rfc: json['rfc']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      paperWidthMm: int.tryParse(json['paper_width_mm']?.toString() ?? '58') ?? 58,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => TicketLineItemPayloadDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotalMxn: double.tryParse(json['subtotal_mxn']?.toString() ?? '0') ?? 0.0,
      discountMxn: double.tryParse(json['discount_mxn']?.toString() ?? '0') ?? 0.0,
      taxMxn: double.tryParse(json['tax_mxn']?.toString() ?? '0') ?? 0.0,
      totalMxn: double.tryParse(json['total_mxn']?.toString() ?? '0') ?? 0.0,
      amountPaidMxn: double.tryParse(json['amount_paid_mxn']?.toString() ?? '0') ?? 0.0,
      changeReturnedMxn: double.tryParse(json['change_returned_mxn']?.toString() ?? '0') ?? 0.0,
      savingsMxn: double.tryParse(json['savings_mxn']?.toString() ?? '0') ?? 0.0,
      payments: (json['payments'] as List<dynamic>?)
              ?.map((item) => TicketPaymentPayloadDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      footerMessage: json['footer_message']?.toString() ?? '',
      formattedText: json['formatted_text']?.toString() ?? '',
    );
  }
}

// ============================================================================
// DTOs DE COMISIONES DINÁMICAS (RF-10)
// ============================================================================

class SaleCommissionResponseDto {
  final String id;
  final String tenantId;
  final String saleId;
  final String userId;
  final String? userName;
  final String commissionType;
  final double commissionRate;
  final double baseAmountMxn;
  final double commissionAmountMxn;
  final bool isSettled;
  final String? settledAt;
  final String createdAt;

  SaleCommissionResponseDto({
    required this.id,
    required this.tenantId,
    required this.saleId,
    required this.userId,
    this.userName,
    required this.commissionType,
    required this.commissionRate,
    required this.baseAmountMxn,
    required this.commissionAmountMxn,
    required this.isSettled,
    this.settledAt,
    required this.createdAt,
  });

  factory SaleCommissionResponseDto.fromJson(Map<String, dynamic> json) {
    return SaleCommissionResponseDto(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? '',
      saleId: json['sale_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString(),
      commissionType: json['commission_type']?.toString() ?? 'PERCENTAGE_SALE',
      commissionRate: double.tryParse(json['commission_rate']?.toString() ?? '0') ?? 0.0,
      baseAmountMxn: double.tryParse(json['base_amount_mxn']?.toString() ?? '0') ?? 0.0,
      commissionAmountMxn: double.tryParse(json['commission_amount_mxn']?.toString() ?? '0') ?? 0.0,
      isSettled: json['is_settled'] as bool? ?? false,
      settledAt: json['settled_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class UserCommissionSummaryDto {
  final String userId;
  final String userName;
  final String userEmail;
  final int totalSalesCount;
  final double totalSalesAmountMxn;
  final double totalCommissionAmountMxn;
  final double pendingSettlementMxn;
  final double settledCommissionMxn;

  UserCommissionSummaryDto({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.totalSalesCount,
    required this.totalSalesAmountMxn,
    required this.totalCommissionAmountMxn,
    required this.pendingSettlementMxn,
    required this.settledCommissionMxn,
  });

  factory UserCommissionSummaryDto.fromJson(Map<String, dynamic> json) {
    return UserCommissionSummaryDto(
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      totalSalesCount: int.tryParse(json['total_sales_count']?.toString() ?? '0') ?? 0,
      totalSalesAmountMxn: double.tryParse(json['total_sales_amount_mxn']?.toString() ?? '0') ?? 0.0,
      totalCommissionAmountMxn: double.tryParse(json['total_commission_amount_mxn']?.toString() ?? '0') ?? 0.0,
      pendingSettlementMxn: double.tryParse(json['pending_settlement_mxn']?.toString() ?? '0') ?? 0.0,
      settledCommissionMxn: double.tryParse(json['settled_commission_mxn']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class CommissionSummaryResponseDto {
  final String? startDate;
  final String? endDate;
  final double totalCommissionsMxn;
  final int totalSalesCount;
  final List<UserCommissionSummaryDto> summariesByUser;

  CommissionSummaryResponseDto({
    this.startDate,
    this.endDate,
    required this.totalCommissionsMxn,
    required this.totalSalesCount,
    required this.summariesByUser,
  });

  factory CommissionSummaryResponseDto.fromJson(Map<String, dynamic> json) {
    return CommissionSummaryResponseDto(
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      totalCommissionsMxn: double.tryParse(json['total_commissions_mxn']?.toString() ?? '0') ?? 0.0,
      totalSalesCount: int.tryParse(json['total_sales_count']?.toString() ?? '0') ?? 0,
      summariesByUser: (json['summaries_by_user'] as List<dynamic>?)
              ?.map((item) => UserCommissionSummaryDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
