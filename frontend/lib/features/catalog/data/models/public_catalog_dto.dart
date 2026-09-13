// DTOs fuertemente tipados para el Catálogo Web Público y Metadatos OpenGraph (RF-23 / Const. Art. 7.4)
// Cumplimiento estricto de .agents/AGENTS.md:
// 1. Moneda base en Pesos Mexicanos ($ MXN).
// 2. Prohibición de mapas crudos (Map<String, dynamic>) en capas de UI/Negocio.
// 3. Serialización y deserialización a prueba de nulos.
// 4. Comentarios exhaustivos línea por línea.

/// Información pública general del comercio para la cabecera del catálogo digital.
class PublicStoreInfoDto {
  /// Nombre comercial de la tienda o sucursal.
  final String name;
  /// Identificador amigable en la URL (slug).
  final String slug;
  /// Número de WhatsApp configurado para recibir pedidos.
  final String? whatsappNumber;
  /// Mensaje de bienvenida para los clientes.
  final String? welcomeMessage;
  /// Horario comercial de servicio.
  final String? businessHours;
  /// Monto mínimo de compra en Pesos Mexicanos ($ MXN).
  final double minOrderAmountMxn;
  /// Costo de envío a domicilio en $ MXN.
  final double deliveryFeeMxn;
  /// Bandera que indica si el servicio a domicilio está activo.
  final bool deliveryEnabled;
  /// Bandera que indica si se permite recoger en tienda.
  final bool pickupEnabled;
  /// Estado operativo del catálogo web.
  final bool isCatalogEnabled;

  /// Constructor inmutable de información de la tienda.
  const PublicStoreInfoDto({
    required this.name,
    required this.slug,
    this.whatsappNumber,
    this.welcomeMessage,
    this.businessHours,
    required this.minOrderAmountMxn,
    required this.deliveryFeeMxn,
    required this.deliveryEnabled,
    required this.pickupEnabled,
    required this.isCatalogEnabled,
  });

  /// Deserialización segura desde JSON.
  factory PublicStoreInfoDto.fromJson(Map<String, dynamic> json) {
    return PublicStoreInfoDto(
      name: json['name'] as String? ?? 'Tienda',
      slug: json['slug'] as String? ?? '',
      whatsappNumber: json['whatsapp_number'] as String?,
      welcomeMessage: json['welcome_message'] as String?,
      businessHours: json['business_hours'] as String?,
      minOrderAmountMxn: (json['min_order_amount_mxn'] as num?)?.toDouble() ?? 0.0,
      deliveryFeeMxn: (json['delivery_fee_mxn'] as num?)?.toDouble() ?? 0.0,
      deliveryEnabled: json['delivery_enabled'] as bool? ?? true,
      pickupEnabled: json['pickup_enabled'] as bool? ?? true,
      isCatalogEnabled: json['is_catalog_enabled'] as bool? ?? true,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'whatsapp_number': whatsappNumber,
      'welcome_message': welcomeMessage,
      'business_hours': businessHours,
      'min_order_amount_mxn': minOrderAmountMxn,
      'delivery_fee_mxn': deliveryFeeMxn,
      'delivery_enabled': deliveryEnabled,
      'pickup_enabled': pickupEnabled,
      'is_catalog_enabled': isCatalogEnabled,
    };
  }
}

/// Renglón de producto en el catálogo digital.
class PublicProductItemDto {
  /// Identificador único del producto.
  final String id;
  /// Nombre comercial del producto.
  final String name;
  /// Código SKU interno.
  final String sku;
  /// Identificador opcional de la categoría.
  final String? categoryId;
  /// Nombre de la categoría de clasificación.
  final String? categoryName;
  /// Precio de venta en Pesos Mexicanos ($ MXN).
  final double priceMxn;
  /// URL de la imagen del producto.
  final String? imageUrl;
  /// Disponibilidad física de existencias.
  final bool inStock;
  /// Cantidad disponible en existencias.
  final double availableStock;

  /// Constructor inmutable de renglón de catálogo.
  const PublicProductItemDto({
    required this.id,
    required this.name,
    required this.sku,
    this.categoryId,
    this.categoryName,
    required this.priceMxn,
    this.imageUrl,
    required this.inStock,
    required this.availableStock,
  });

  /// Deserialización segura desde JSON.
  factory PublicProductItemDto.fromJson(Map<String, dynamic> json) {
    return PublicProductItemDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      priceMxn: (json['price_mxn'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      inStock: json['in_stock'] as bool? ?? true,
      availableStock: (json['available_stock'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category_id': categoryId,
      'category_name': categoryName,
      'price_mxn': priceMxn,
      'image_url': imageUrl,
      'in_stock': inStock,
      'available_stock': availableStock,
    };
  }
}

/// Categoría pública con contador de productos.
class PublicCategoryDto {
  /// Identificador único de categoría.
  final String id;
  /// Nombre de la categoría.
  final String name;
  /// Conteo de artículos catalogados.
  final int productCount;

  /// Constructor inmutable de categoría pública.
  const PublicCategoryDto({
    required this.id,
    required this.name,
    required this.productCount,
  });

  /// Deserialización segura desde JSON.
  factory PublicCategoryDto.fromJson(Map<String, dynamic> json) {
    return PublicCategoryDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      productCount: json['product_count'] as int? ?? 0,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'product_count': productCount,
    };
  }
}

/// Respuesta consolidada de la vista del catálogo digital (RF-23).
class PublicCatalogDto {
  /// Información comercial de la tienda.
  final PublicStoreInfoDto store;
  /// Lista de categorías con productos disponibles.
  final List<PublicCategoryDto> categories;
  /// Lista de productos disponibles para compra.
  final List<PublicProductItemDto> products;
  /// Total de productos en la lista.
  final int totalProducts;

  /// Constructor del catálogo público.
  const PublicCatalogDto({
    required this.store,
    required this.categories,
    required this.products,
    required this.totalProducts,
  });

  /// Deserialización segura desde JSON.
  factory PublicCatalogDto.fromJson(Map<String, dynamic> json) {
    final rawStore = json['store'] as Map<String, dynamic>? ?? {};
    final rawCats = json['categories'] as List<dynamic>? ?? [];
    final rawProds = json['products'] as List<dynamic>? ?? [];

    return PublicCatalogDto(
      store: PublicStoreInfoDto.fromJson(rawStore),
      categories: rawCats
          .map((e) => PublicCategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      products: rawProds
          .map((e) => PublicProductItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalProducts: json['total_products'] as int? ?? rawProds.length,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'store': store.toJson(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'products': products.map((e) => e.toJson()).toList(),
      'total_products': totalProducts,
    };
  }
}

/// Detalle individual de un producto público.
class PublicProductDetailDto {
  /// Identificador único del producto.
  final String id;
  /// Nombre comercial del producto.
  final String name;
  /// Código SKU.
  final String sku;
  /// Código de barras EAN/UPC opcional.
  final String? barcode;
  /// Nombre de la categoría.
  final String? categoryName;
  /// Precio de venta en Pesos Mexicanos ($ MXN).
  final double priceMxn;
  /// Imagen del producto.
  final String? imageUrl;
  /// Disponibilidad en inventario.
  final bool inStock;
  /// Existencias disponibles.
  final double availableStock;
  /// Nombre de la tienda dueña.
  final String storeName;
  /// Slug identificador de la tienda.
  final String storeSlug;
  /// WhatsApp de contacto de la tienda.
  final String? storeWhatsapp;

  /// Constructor de detalle de producto.
  const PublicProductDetailDto({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    this.categoryName,
    required this.priceMxn,
    this.imageUrl,
    required this.inStock,
    required this.availableStock,
    required this.storeName,
    required this.storeSlug,
    this.storeWhatsapp,
  });

  /// Deserialización segura desde JSON.
  factory PublicProductDetailDto.fromJson(Map<String, dynamic> json) {
    return PublicProductDetailDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      barcode: json['barcode'] as String?,
      categoryName: json['category_name'] as String?,
      priceMxn: (json['price_mxn'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      inStock: json['in_stock'] as bool? ?? true,
      availableStock: (json['available_stock'] as num?)?.toDouble() ?? 0.0,
      storeName: json['store_name'] as String? ?? '',
      storeSlug: json['store_slug'] as String? ?? '',
      storeWhatsapp: json['store_whatsapp'] as String?,
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'category_name': categoryName,
      'price_mxn': priceMxn,
      'image_url': imageUrl,
      'in_stock': inStock,
      'available_stock': availableStock,
      'store_name': storeName,
      'store_slug': storeSlug,
      'store_whatsapp': storeWhatsapp,
    };
  }
}

/// Metadatos OpenGraph para Server-Side Rendering y tarjetas de vista previa (Const. Art. 7.4).
class OpenGraphMetaDto {
  /// Título de la tarjeta og:title.
  final String ogTitle;
  /// Descripción de la tarjeta og:description.
  final String ogDescription;
  /// Enlace a la imagen og:image.
  final String? ogImage;
  /// URL canónica og:url.
  final String ogUrl;
  /// Precio numérico og:price:amount.
  final double? ogPriceAmount;
  /// Moneda ISO 4217 (MXN).
  final String ogPriceCurrency;

  /// Constructor de metadatos OpenGraph.
  const OpenGraphMetaDto({
    required this.ogTitle,
    required this.ogDescription,
    this.ogImage,
    required this.ogUrl,
    this.ogPriceAmount,
    this.ogPriceCurrency = 'MXN',
  });

  /// Deserialización segura desde JSON.
  factory OpenGraphMetaDto.fromJson(Map<String, dynamic> json) {
    return OpenGraphMetaDto(
      ogTitle: json['og_title'] as String? ?? '',
      ogDescription: json['og_description'] as String? ?? '',
      ogImage: json['og_image'] as String?,
      ogUrl: json['og_url'] as String? ?? '',
      ogPriceAmount: (json['og_price_amount'] as num?)?.toDouble(),
      ogPriceCurrency: json['og_price_currency'] as String? ?? 'MXN',
    );
  }

  /// Serialización segura a JSON.
  Map<String, dynamic> toJson() {
    return {
      'og_title': ogTitle,
      'og_description': ogDescription,
      'og_image': ogImage,
      'og_url': ogUrl,
      'og_price_amount': ogPriceAmount,
      'og_price_currency': ogPriceCurrency,
    };
  }
}
