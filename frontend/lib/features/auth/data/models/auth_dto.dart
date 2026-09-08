// DTOs fuertemente tipados para el Módulo de Autenticación y Control de Inquilinos
class UserDto {
  // Identificador único del usuario
  final String id;
  // Identificador del inquilino asociado
  final String tenantId;
  // Correo electrónico de acceso
  final String email;
  // Nombre de usuario único
  final String username;
  // Nombre completo del usuario
  final String fullName;
  // Estado activo o inactivo
  final bool isActive;
  // Lista de roles asignados
  final List<String> roles;

  // Constructor
  UserDto({
    required this.id,
    required this.tenantId,
    required this.email,
    required this.username,
    required this.fullName,
    required this.isActive,
    required this.roles,
  });

  // Fábrica para deserialización segura desde JSON
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      isActive: json['is_active'] == true,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((role) => role.toString())
              .toList() ??
          [],
    );
  }

  // Serialización a mapa JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'tenant_id': tenantId,
        'email': email,
        'username': username,
        'full_name': fullName,
        'is_active': isActive,
        'roles': roles,
      };
}

class TenantDto {
  // Identificador único del comercio
  final String id;
  // Nombre comercial
  final String name;
  // Slug identificador
  final String slug;
  // Plan de suscripción actual
  final String subscriptionPlan;
  // Estado de suscripción (ACTIVE, SOFT_LOCK, HARD_LOCK)
  final String subscriptionStatus;

  // Constructor
  TenantDto({
    required this.id,
    required this.name,
    required this.slug,
    required this.subscriptionPlan,
    required this.subscriptionStatus,
  });

  // Fábrica desde JSON
  factory TenantDto.fromJson(Map<String, dynamic> json) {
    return TenantDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      subscriptionPlan: json['subscription_plan']?.toString() ?? 'EMPRENDEDOR',
      subscriptionStatus: json['subscription_status']?.toString() ?? 'ACTIVE',
    );
  }

  // Serialización
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'subscription_plan': subscriptionPlan,
        'subscription_status': subscriptionStatus,
      };
}

class AuthResponseDto {
  // Token de acceso JWT (15 min)
  final String accessToken;
  // Token de refresco JWT (7 días)
  final String refreshToken;
  // Tipo de token (bearer)
  final String tokenType;
  // Datos del usuario autenticado
  final UserDto user;
  // Datos del comercio inquilino
  final TenantDto tenant;

  // Constructor
  AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
    required this.tenant,
  });

  // Fábrica desde JSON con compatibilidad tanto para respuesta raíz como anidada
  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    // Extracción de tokens desde la raíz o desde sub-objeto 'tokens'
    final String access = json['access_token']?.toString() ??
        json['tokens']?['access_token']?.toString() ??
        '';
    final String refresh = json['refresh_token']?.toString() ??
        json['tokens']?['refresh_token']?.toString() ??
        '';

    return AuthResponseDto(
      accessToken: access,
      refreshToken: refresh,
      tokenType: json['token_type']?.toString() ?? 'bearer',
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      tenant: TenantDto.fromJson(json['tenant'] as Map<String, dynamic>? ?? {}),
    );
  }
}
