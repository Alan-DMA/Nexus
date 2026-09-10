// DTOs fuertemente tipados para el Módulo de OCR On-Device y Dictado por Voz (RF-28, SR-09)
// Cumplimiento estricto de .agents/AGENTS.md:
// 1. Moneda base Pesos Mexicanos ($ MXN).
// 2. Prohibición de mapas crudos (Map<String, dynamic>) en capas de UI/Negocio.
// 3. Serialización y deserialización segura con conversiones a prueba de nulos.
// 4. Comentarios exhaustivos línea por línea.

/// Solicitud enviada al backend con el texto plano detectado por Google ML Kit On-Device (RF-28).
class ReceiptOcrParseRequestDto {
  /// Texto crudo extraído de la cámara por el motor ML Kit en el dispositivo.
  final String rawText;
  /// Identificador opcional del proveedor emisor en caso de conocerse previamente.
  final String? supplierId;
  /// URL o path local temporal de la fotografía de la factura.
  final String? imageUrl;

  /// Constructor del DTO de solicitud de parseo OCR.
  const ReceiptOcrParseRequestDto({
    required this.rawText,
    this.supplierId,
    this.imageUrl,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'raw_text': rawText,
    };
    if (supplierId != null) {
      map['supplier_id'] = supplierId;
    }
    if (imageUrl != null) {
      map['image_url'] = imageUrl;
    }
    return map;
  }
}

/// Renglón individual de producto interpretado de la nota de remisión o ticket físico.
class ReceiptOcrItemDto {
  /// Línea de texto original tal como fue leída por el OCR.
  final String rawLine;
  /// Nombre o descripción del artículo detectada en la línea.
  final String detectedName;
  /// Cantidad de piezas o unidades físicas extraída.
  final double detectedQuantity;
  /// Costo unitario detectado en Pesos Mexicanos ($ MXN).
  final double detectedUnitCostMxn;
  /// Importe total de la partida en Pesos Mexicanos ($ MXN).
  final double detectedTotalMxn;
  /// ID del producto coincidente en el inventario del comercio (si existe).
  final String? matchedProductId;
  /// Nombre oficial del producto emparejado en el inventario.
  final String? matchedProductName;
  /// Código SKU del producto emparejado.
  final String? matchedProductSku;
  /// Puntuación de certeza del algoritmo de similitud difusa (0.0 a 1.0).
  final double confidenceScore;

  /// Constructor de renglón detectado por OCR.
  const ReceiptOcrItemDto({
    required this.rawLine,
    required this.detectedName,
    required this.detectedQuantity,
    required this.detectedUnitCostMxn,
    required this.detectedTotalMxn,
    this.matchedProductId,
    this.matchedProductName,
    this.matchedProductSku,
    required this.confidenceScore,
  });

  /// Deserialización segura desde JSON.
  factory ReceiptOcrItemDto.fromJson(Map<String, dynamic> json) {
    return ReceiptOcrItemDto(
      rawLine: json['raw_line'] as String? ?? '',
      detectedName: json['detected_name'] as String? ?? '',
      detectedQuantity: (json['detected_quantity'] as num?)?.toDouble() ?? 1.0,
      detectedUnitCostMxn: (json['detected_unit_cost_mxn'] as num?)?.toDouble() ?? 0.0,
      detectedTotalMxn: (json['detected_total_mxn'] as num?)?.toDouble() ?? 0.0,
      matchedProductId: json['matched_product_id'] as String?,
      matchedProductName: json['matched_product_name'] as String?,
      matchedProductSku: json['matched_product_sku'] as String?,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 1.0,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'raw_line': rawLine,
      'detected_name': detectedName,
      'detected_quantity': detectedQuantity,
      'detected_unit_cost_mxn': detectedUnitCostMxn,
      'detected_total_mxn': detectedTotalMxn,
      'matched_product_id': matchedProductId,
      'matched_product_name': matchedProductName,
      'matched_product_sku': matchedProductSku,
      'confidence_score': confidenceScore,
    };
  }
}

/// Respuesta consolidada tras procesar el texto de la remisión física.
class ReceiptOcrParseResponseDto {
  /// Nombre comercial o marca de la distribuidora identificada.
  final String? supplierName;
  /// Folio o referencia de la factura física.
  final String? invoiceReference;
  /// Lista de renglones de compra estructurados y emparejados.
  final List<ReceiptOcrItemDto> items;
  /// Suma total de los renglones en Pesos Mexicanos ($ MXN).
  final double totalAmountMxn;
  /// Cantidad de productos que no existen en el catálogo y requieren alta rápida.
  final int unmatchedItemsCount;

  /// Constructor de respuesta de parseo de factura.
  const ReceiptOcrParseResponseDto({
    this.supplierName,
    this.invoiceReference,
    required this.items,
    required this.totalAmountMxn,
    required this.unmatchedItemsCount,
  });

  /// Deserialización segura desde JSON.
  factory ReceiptOcrParseResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final parsedItems = rawItems
        .map((e) => ReceiptOcrItemDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return ReceiptOcrParseResponseDto(
      supplierName: json['supplier_name'] as String?,
      invoiceReference: json['invoice_reference'] as String?,
      items: parsedItems,
      totalAmountMxn: (json['total_amount_mxn'] as num?)?.toDouble() ?? 0.0,
      unmatchedItemsCount: json['unmatched_items_count'] as int? ?? 0,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'supplier_name': supplierName,
      'invoice_reference': invoiceReference,
      'items': items.map((e) => e.toJson()).toList(),
      'total_amount_mxn': totalAmountMxn,
      'unmatched_items_count': unmatchedItemsCount,
    };
  }
}

/// Solicitud para parsear dictado de voz nativo en español mexicano (SR-09).
class VoiceDictationParseRequestDto {
  /// Frase transcrita por el speech-to-text del sistema operativo.
  final String voiceText;

  /// Constructor de solicitud de dictado de voz.
  const VoiceDictationParseRequestDto({
    required this.voiceText,
  });

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'voice_text': voiceText,
    };
  }
}

/// Respuesta con los 3 Campos Vitales estructurados a partir del dictado de voz (SR-09).
class VoiceDictationParseResponseDto {
  /// Nombre comercial del producto (Campo Vital 1).
  final String name;
  /// Precio de venta en Pesos Mexicanos ($ MXN) (Campo Vital 2).
  final double priceMxn;
  /// Costo de adquisición en $ MXN (opcional).
  final double? costMxn;
  /// Existencias iniciales para inventario (Campo Vital 3).
  final double initialStock;
  /// Nivel de confianza semántica de la interpretación acústica (0.0 a 1.0).
  final double confidence;

  /// Constructor de respuesta de dictado de voz.
  const VoiceDictationParseResponseDto({
    required this.name,
    required this.priceMxn,
    this.costMxn,
    required this.initialStock,
    required this.confidence,
  });

  /// Deserialización segura desde JSON.
  factory VoiceDictationParseResponseDto.fromJson(Map<String, dynamic> json) {
    return VoiceDictationParseResponseDto(
      name: json['name'] as String? ?? 'Producto Dictado',
      priceMxn: (json['price_mxn'] as num?)?.toDouble() ?? 0.0,
      costMxn: (json['cost_mxn'] as num?)?.toDouble(),
      initialStock: (json['initial_stock'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'price_mxn': priceMxn,
      'initial_stock': initialStock,
      'confidence': confidence,
    };
    if (costMxn != null) {
      map['cost_mxn'] = costMxn;
    }
    return map;
  }
}
