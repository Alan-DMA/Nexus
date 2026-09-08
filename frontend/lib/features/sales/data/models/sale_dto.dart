// DTOs fuertemente tipados para el Módulo de Ventas POS y Checkout Transaccional
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
  // Descuento global
  final double discountMxn;
  // Notas u observaciones
  final String? notes;

  SaleCheckoutRequestDto({
    required this.warehouseId,
    this.clientId,
    required this.items,
    this.payments,
    this.discountMxn = 0.0,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'warehouse_id': warehouseId,
        if (clientId != null) 'client_id': clientId,
        'items': items.map((i) => i.toJson()).toList(),
        if (payments != null)
          'payments': payments!.map((p) => p.toJson()).toList(),
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
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
