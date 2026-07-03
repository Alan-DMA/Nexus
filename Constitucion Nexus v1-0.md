# CONSTITUCIÓN DEL SISTEMA NEXUS
## Gestión Comercial Modular para el Comercio Venezolano

> **Versión:** 2.0  
> **Última actualización:** Julio 2026  
> **Fundadores:** Alan y Eduardo  
> **Propósito:** Este documento define los principios fundamentales, reglas inquebrantables y filosofía de diseño del Sistema Nexus. Cualquier cambio, funcionalidad o decisión técnica debe respetar estos principios.

---

## PREÁMBULO

Nexus nace con una misión clara: **democratizar el acceso a herramientas profesionales de gestión comercial para los pequeños y medianos comercios venezolanos**, operando en un contexto de recursos limitados, mercado informal y realidad bimoneda.

Esta constitución es el documento "sagrado" del proyecto. Cuando haya duda sobre si una funcionalidad debe implementarse o no, se consulta este documento. Cuando alguien (un fundador, un futuro empleado, o una IA) proponga un cambio, debe justificarlo frente a estos principios.

---

## ARTÍCULO I: PROPÓSITO Y FILOSOFÍA

### 1.1 Misión del Sistema
Nexus es un **Sistema de Gestión Comercial Modular** diseñado específicamente para el mercado retail venezolano, operando bajo un modelo **SaaS Multi-tenant**. Su propósito es ayudar al comerciante a:
- Controlar su inventario de forma precisa
- Vender más rápido y sin errores
- Tomar decisiones basadas en datos reales
- Digitalizar su negocio sin fricciones

### 1.2 Principios Fundamentales (Inquebrantables)

1. **Simplicidad sobre Complejidad:** Cada funcionalidad debe resolver un problema real del comerciante venezolano. No se implementa tecnología por moda.
2. **Consistencia ACID sobre Velocidad:** En operaciones críticas (ventas, inventario), la consistencia de datos es innegociable. Preferimos un sistema lento pero correcto a uno rápido pero incorrecto.
3. **Multi-tenant desde el Día 1:** Cada línea de código debe asumir que hay múltiples comercios compartiendo la misma infraestructura. El aislamiento de datos es sagrado.
4. **Bimoneda Nativa:** USD y VES son ciudadanos de primera clase, no conversiones de último momento.
5. **Mobile-First:** Diseñamos primero para celular (Android), porque es lo que la mayoría de nuestros clientes van a usar. La PC es secundaria.
6. **Bootstrap (Crecimiento con Recursos Limitados):** Empezamos con lo mínimo, validamos el producto y crecemos reinvirtiendo las ganancias. No gastamos lo que no tenemos.
7. **El Sistema NO es una Pasarela de Pagos:** Solo registra los pagos de las ventas del comercio, no los procesa ni valida.
8. **Rapidez y Eficiencia para el Usuario:** El comerciante debe sentir que ahorra tiempo y trabajo manual. Esta es nuestra ventaja competitiva principal.

---

## ARTÍCULO II: ARQUITECTURA TÉCNICA INQUEBRANTABLE

### 2.1 Stack Tecnológico Obligatorio

| Capa | Tecnología | Justificación |
|------|-----------|---------------|
| **Backend/API** | Python + FastAPI | Alto rendimiento, asincronismo nativo, OpenAPI automático |
| **Frontend** | Flutter (Dart) | Código único para Android, iOS y Web |
| **Base de Datos** | PostgreSQL | RLS, consistencia ACID, consultas complejas |
| **Manejo de Estado** | Riverpod o BLoC | Patrones modernos y escalables |
| **Caché Local** | Hive / SharedPreferences | Solo lectura, sin sincronización bidireccional |
| **Escáner de Código de Barras** | mobile_scanner (Flutter) | Usa la cámara del celular, gratuito, open source |

### 2.2 Arquitectura Multi-tenant

- **Modelo:** Single Database con columna `tenant_id` en cada tabla
- **Seguridad:** Row-Level Security (RLS) de PostgreSQL obligatorio
- **Contexto:** Cada request ejecuta `SET app.current_tenant = 'uuid'` antes de cualquier consulta
- **Índices:** Todos los índices incluyen `tenant_id` como primera columna
- **Escala objetivo inicial:** Hasta 100 comercios

### 2.3 Manejo Bimoneda y Tasa Histórica

**Regla de Oro Contable:**
- Los productos tienen `cost_usd` y `price_usd` como valores base
- Al procesar una venta, el sistema consulta la tasa actual y **la congela** en el registro de la venta (`exchange_rate_applied`)
- La tabla `sale_items` almacena `unit_cost_usd` congelado al momento de la venta
- Los reportes de rentabilidad histórica usan estos valores congelados, garantizando auditoría contable perfecta

### 2.4 Conectividad y Sincronización

- **Arquitectura de Escritura:** Exclusivamente Online (no hay sincronización bidireccional compleja)
- **Modo Caché:** Solo lectura. Sin internet, el usuario puede consultar productos pero no crear ventas
- **Interceptor de Red:** Si falla la conexión en escritura, la UI bloquea la acción y exige reconexión
- **Justificación:** La ruptura de stock es un problema grave. Preferimos que el cajero espere 2 minutos a que vuelva el internet, a que el sistema venda productos que no existen.

### 2.5 Escaneo de Código de Barras

- **Método principal:** Cámara del celular (usando `mobile_scanner`)
- **Método alternativo:** Escáneres Bluetooth/USB externos (para comercios que los tengan)
- **Tipos de códigos soportados:** EAN-13, UPC, Code 128, QR, DataMatrix
- **Velocidad objetivo:** Lectura en menos de 1 segundo con buena iluminación

---

## ARTÍCULO III: SEPARACIÓN DE RESPONSABILIDADES FINANCIERAS

### 3.1 Principio Fundamental

> **El Sistema NO es una Pasarela de Pagos para las ventas del comercio.**

### 3.2 Dos Flujos Financieros Completamente Separados

#### A) Cobro de Suscripciones SaaS (Nexus → Tenant)
- **Propósito:** Los fundadores cobran la mensualidad a los comercios por usar Nexus
- **Métodos:** Binance Pay (USDT), PayPal, Pago Móvil, Zinli, Efectivo en divisas
- **Validación:** Automática (Binance Pay) o manual (resto)
- **Idempotencia:** La tabla `binance_payments_processed` garantiza que no se acredite dos veces el mismo pago de suscripción

#### B) Registro de Ventas del Comercio (Tenant → Cliente Final)
- **Propósito:** El comercio cobra a sus clientes por productos/servicios
- **Métodos:** Efectivo USD/VES, Pago Móvil, Zelle, Tarjetas, etc.
- **Validación:** **NINGUNA automática.** El cajero confirma manualmente que recibió el dinero
- **Rol del Sistema:** Actúa exclusivamente como **registro contable** para arqueo y reportes internos

### 3.3 Implicaciones Técnicas

| Concepto | Interpretación Correcta |
|----------|------------------------|
| **Binance Pay** | Cobra la mensualidad del SaaS a los comercios, NO las ventas |
| **Pago Móvil en ventas** | El cajero anota el número de referencia manualmente |
| **Venta "Pagada"** | El cajero confirma que recibió el dinero (input manual) |
| **sale_payments** | Tabla de registro contable, sin validación de webhooks |
| **Arqueo de caja** | Compara "lo que el sistema dice" vs "lo que hay físicamente" |

---

## ARTÍCULO IV: RESTRICCIONES PRESUPUESTARIAS (BOOTSTRAP)

### 4.1 Límites Financieros

- **Presupuesto máximo de hosting:** $30/mes hasta alcanzar 3 clientes de pago
- **Prioridad:** Servicios gratuitos o de bajo costo sobre soluciones empresariales
- **Backups:** Manuales mediante scripts propios hasta tener ingresos suficientes
- **Soporte:** Manejado directamente por los fundadores (Alan y Eduardo)
- **Equipo:** 2 desarrolladores (Alan y Eduardo)

### 4.2 Estrategia de Crecimiento
La evolución de la infraestructura y el crecimiento proyectado del sistema se rigen por la disponibilidad financiera y se detallan en la especificación técnica (ver [Sección 8.2 del Documento Maestro](file:///d:/aland/Documents/Proyectos/Nexus/Documento%20Maestro%20Nexus%20v3-0.md#82-plan-de-escalamiento-por-fases)).

### 4.3 Decisiones de Arquitectura Limitadas por Presupuesto

- ❌ **NO usar servicios de IA/LLM de pago** (GPT-4, Claude, etc.) hasta tener ingresos suficientes
- ❌ **NO usar servicios de hosting caros** (AWS, Google Cloud) hasta Fase 3
- ❌ **NO implementar backups automáticos costosos** hasta Fase 2
- ❌ **NO construir servidores propios** hasta Fase 3
- ✅ **USAR VPS económicos** (Contabo, Hetzner, ~$10/mes) o servicios gratuitos (Oracle Cloud Free Tier)
- ✅ **USAR almacenamiento gratuito** (Backblaze B2 10GB, Cloudflare R2 10GB)
- ✅ **OPTIMIZAR código** para correr en hardware limitado (2-4GB RAM)
- ✅ **PRIORIZAR soluciones open-source** sobre servicios de pago

### 4.4 Infraestructura Objetivo Inicial
La selección de proveedores de hosting de bajo costo y la configuración inicial de los servicios de infraestructura se detallan en la especificación técnica (ver [Sección 8.1 del Documento Maestro](file:///d:/aland/Documents/Proyectos/Nexus/Documento%20Maestro%20Nexus%20v3-0.md#81-presupuesto-mensual-inicial)).

---

## ARTÍCULO V: MÉTODOS DE COBRO DE SUSCRIPCIONES

### 5.1 Realidad del Mercado Informal

- La mayoría de los comercios informales NO tienen Binance Pay
- El cobro de suscripciones será mayoritariamente MANUAL
- Deben existir mecanismos eficientes para validar pagos manuales

### 5.2 Métodos de Cobro Aceptados

| Método | Automatización | Proceso de Validación |
|--------|----------------|----------------------|
| **Binance Pay** | ✅ Automática | Webhook valida y activa suscripción |
| **PayPal** | ⚠️ Semi-automática | Fundadores validan manualmente en dashboard de PayPal |
| **Pago Móvil** | ❌ Manual | Tenant envía captura → Fundadores verifican en banco → Activan |
| **Zinli** | ❌ Manual | Tenant envía captura → Fundadores verifican → Activan |
| **Efectivo divisas** | ❌ Manual | Fundadores visitan local → Reciben efectivo → Activan |

### 5.3 Panel de Administración Interno

- El sistema debe tener un panel exclusivo para los fundadores
- Lista de pagos pendientes de validación
- Interfaz para aprobar/rechazar pagos manuales
- Notificaciones automáticas al tenant cuando se aprueba su pago
- Historial completo de validaciones

---

## ARTÍCULO VI: MODELO COMERCIAL (SAAS)

### 6.1 Estructura de Planes

| Plan | Precio | Módulos Incluidos | Límite Usuarios | Características Destacadas |
|------|--------|-------------------|-----------------|----------------------------|
| **Emprendedor** | $10/mes | Inventario, Ventas, Compras | Hasta 2 | Tasa Bimoneda, 1 Almacén, Alertas de Stock, Reportes Básicos |
| **Comercio** | $20/mes | Base + Caja y Tesorería | Hasta 5 | Multi-almacén, Arqueo Multimoneda, Catálogo WhatsApp con Pedidos, Pagos Mixtos |
| **Corporativo** | $35/mes | Todos los Módulos | Hasta 15 | Analítica Avanzada, KPIs Predictivos, Reportes Comparativos |

### 6.2 Punto de Equilibrio

- Con **3 clientes en plan Emprendedor** = $30/mes (cubren hosting exacto)
- Con **2 clientes en plan Comercio** = $40/mes (ya tienen margen)
- Con **1 cliente en plan Corporativo** = $35/mes (cubren hosting + ganancia)

### 6.3 Ciclo de Vida de Suscripción

**Máquina de Estados:**
1. **ACTIVE:** Uso normal de todos los módulos contratados
2. **SOFT_LOCK (Días 1-10 de morosidad):** Permite consultar inventario y ver reportes, pero **bloquea la creación de nuevas ventas y compras**
3. **HARD_LOCK (Día 11+):** Bloqueo total. Solo permite ver pantalla de pago y contacto a soporte

**Validación en Middleware:**
- Cada request valida el estado de la suscripción del tenant
- El acceso a módulos (Caja, Analítica) se inyecta dinámicamente según el `PlanID`
- Si un usuario intenta acceder a una sección no pagada, la API retorna `403 Forbidden` con mensaje de Upsell

---

## ARTÍCULO VII: REGLAS DE NEGOCIO SAGRADAS

### 7.1 Inventario y Stock

- **Multi-almacén Unificado:** La tabla `warehouses` existe siempre. El Plan Emprendedor tiene un almacén "Principal" por defecto
- **Stock Reservado con TTL:** El stock en estado "En Espera" (PENDING_PAYMENT) tiene un Tiempo de Vida de **15 minutos**. Un Cron Job debe liberarlo automáticamente si no se cobra
- **Movimientos de Inventario:** Toda entrada/salida debe registrarse en `inventory_movements` con referencia al documento origen (venta, compra, traslado)
- **Alertas de Stock:** Reglas simples basadas en umbrales (ej: "si stock < 5, alertar"), sin machine learning

### 7.2 Ventas y Pagos

- **Máquina de Estados:** Las ventas deben pasar estrictamente por: `DRAFT` → `PENDING_PAYMENT` → `PAID` → `COMPLETED` / `CANCELLED` / `REFUNDED`
- **Idempotencia de Webhooks:** La tabla `binance_payments_processed` debe tener `binance_transaction_id` como UNIQUE. Si Binance envía el webhook duplicado, la segunda inserción debe fallar
- **Pagos Mixtos:** Una venta puede dividirse en múltiples métodos de pago y monedas. El sistema calcula el vuelto matemáticamente
- **Registro Contable:** El cajero registra manualmente los métodos de pago recibidos. **NO hay validación automática de fondos**

### 7.3 Registro de Productos al Vuelo

- **Objetivo:** El cajero debe poder crear un producto nuevo en **menos de 10 segundos** sin interrumpir la venta
- **Estrategias sin IA:**
  - Búsqueda fuzzy (algoritmo de Levenshtein) para autocompletado
  - Formulario ultra-optimizado (máximo 3 campos obligatorios)
  - Atajos de teclado para PC/Tablet
  - Modo "Creación Rápida" que no bloquea la transacción
  - Plantillas de productos predefinidas

### 7.4 Catálogo Digital WhatsApp

- **Formato:** Página web pública con catálogo sincronizado
- **Funcionalidad:** Permite a los clientes hacer pedidos directamente por WhatsApp
- **Sincronización:** Si el comerciante cambia un precio o agrega un producto, el catálogo se actualiza automáticamente
- **SEO:** Renderizado del lado del servidor (SSR) para previews rápidos en WhatsApp

### 7.5 Seguridad y Roles

- **Autenticación:** JWT (Access Token 15 min + Refresh Token 7 días)
- **RBAC Granular:** Matriz de permisos (no roles rígidos). Ejemplo: `inventario.editar_precios`, `ventas.ver_costos`
- **Roles Predefinidos:** `TENANT_OWNER`, `MANAGER`, `CASHIER`, `SALESPERSON` son solo paquetes de permisos
- **Auditoría:** Toda acción crítica debe registrarse en `audit_logs` con `old_values` y `new_values`

---

## ARTÍCULO VIII: CONVENCIONES DE CÓDIGO

### 8.1 Nomenclatura

- **Tablas:** Snake case, plural (ej: `products`, `sale_items`)
- **Columnas:** Snake case (ej: `tenant_id`, `created_at`)
- **Enums:** Upper snake case (ej: `PENDING_PAYMENT`, `ACTIVE`)
- **API Endpoints:** Kebab case (ej: `/api/v1/purchase-orders`)
- **Variables (Python/Dart):** Snake case
- **Clases:** PascalCase

### 8.2 Estructura de Respuestas API

**Éxito:**
```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "total": 50,
    "per_page": 20
  }
}
```

**Error:**
```json
{
  "error": {
    "code": "INSUFFICIENT_STOCK",
    "message": "No hay suficiente stock de Harina PAN",
    "details": {
      "product_id": "uuid",
      "requested": 5,
      "available": 2
    }
  }
}
```

### 8.3 Manejo de Errores
- **Códigos HTTP Estándar:** 200 (OK), 201 (Created), 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found), 409 (Conflict), 422 (Unprocessable Entity), 500 (Internal Server Error)
- **Errores de Negocio:** Usar códigos personalizados (ej: INSUFFICIENT_STOCK, TENANT_SUSPENDED, DUPLICATE_BARCODE)
- **Logs:** Todo error 500 debe loguearse con stack trace completo y contexto del tenant

### 8.4 Migraciones de Base de Datos
- **Herramienta:** Alembic (para SQLAlchemy)
- **Regla:** Nunca modificar una migración ya aplicada. Crear una nueva migración para revertir o ajustar
- **Naming:** YYYYMMDD_HHMMSS_descripcion_corta.py (ej: 20260703_143025_add_exchange_rate_to_sales.py)

### 8.5 Lo que el Sistema NO Debe Hacer (Nunca)
- No implementar sincronización bidireccional offline compleja (WatermelonDB, Isar para escritura)
- No hardcodear roles de usuario en el código. Usar siempre la matriz de permisos
- No permitir ventas sin congelar la tasa de cambio en el registro
- No almacenar contraseñas en texto plano. Siempre usar hashing seguro (bcrypt, argon2)
- No exponer IDs internos en URLs o respuestas. Usar UUIDs públicos
- No implementar facturación fiscal SENIAT (solo comprobantes administrativos)
- No procesar ni validar pagos de ventas del comercio (solo registrar contablemente)
- No integrar Binance Pay para cobro de ventas (solo para suscripciones SaaS)
- No implementar una base de datos semilla global de productos (por el mantenimiento inviable que requiere para el equipo de fundadores)

### 8.6 Lo que el Sistema NO Debe Hacer (Hasta tener ingresos suficientes)
- No usar APIs de LLM/IA (GPT-4, Claude, etc.)
- No construir servidores propios
- No implementar backups automáticos costosos
- No usar servicios de hosting caros (AWS, Google Cloud)

### 8.7 Decisiones Diferidas (Versión 2.0 o 3.0)
⏳ Integración con impresoras térmicas Bluetooth/USB (para tickets y etiquetas)
⏳ Integración con Zinli/PayPal para cobro de suscripciones
⏳ Facturación fiscal electrónica (SENIAT)
⏳ Multi-idioma (i18n) - solo español por ahora
⏳ App de escritorio nativa (Electron) - Flutter Web es suficiente
⏳ Alertas predictivas con ML - solo reglas simples por ahora
⏳ Dashboard analítico avanzado - solo gráficos básicos en MVP

---

## ARTÍCULO IX: ÉTICA, PRIVACIDAD Y SOPORTE

### 9.1 Privacidad del Usuario
- **Datos Personales:** Cumplir con leyes venezolanas de protección de datos
- **Encriptación:** Datos sensibles (contraseñas, tokens) deben estar encriptados en reposo
- **Logs:** Nunca loguear datos sensibles (contraseñas, tokens completos, números de tarjeta)

### 9.2 Transparencia Comercial
- **Precios Claros:** Los planes de suscripción deben mostrar claramente qué incluye cada uno
- **Morosidad:** El sistema debe notificar al tenant antes de aplicar Soft Lock o Hard Lock
- **Exportación de Datos:** El tenant debe poder exportar todos sus datos en cualquier momento

### 9.3 Soporte al Cliente
- **Inicial:** Manejado directamente por los fundadores (Alan y Eduardo)
- **Objetivo:** Tener contacto directo con los clientes para entender sus problemas reales
- **Evolución:** Cuando haya suficientes clientes, contratar personal de soporte dedicado

---

## ARTÍCULO X: PROCESO DE DESARROLLO, CALIDAD Y DESPLIEGUE

### 10.1 Spec-Driven Development (SDD)
- **Regla:** Antes de programar, debe existir una especificación (DBML, OpenAPI, diagrama de estados)
- **Revisión:** Toda spec debe ser revisada por ambos fundadores antes de implementarse
- **Documentación:** El código debe documentarse con docstrings claros. Las APIs deben tener OpenAPI actualizado

### 10.2 Testing
- **Unit Tests:** Obligatorios para lógica de negocio crítica (cálculos de comisiones, validación de stock)
- **Integration Tests:** Obligatorios para endpoints de API
- **E2E Tests:** Recomendados para flujos críticos (checkout, arqueo de caja)
- **Cobertura Mínima:** 80% en módulos core (inventario, ventas)

### 10.3 Despliegue
- **Ambientes:** Development, Staging, Production
- **CI/CD:** GitHub Actions o similar
- **Base de Datos:** Migraciones automáticas en despliegue, pero con rollback manual disponible
- **Backups:** Diarios manuales de PostgreSQL (script propio + upload a almacenamiento gratuito)

---

## ARTÍCULO XI: EVOLUCIÓN Y ENMIENDAS

### 11.1 Proceso de Cambio
- **Propuesta:** Cualquier cambio a esta constitución debe proponerse vía Pull Request o discusión documentada
- **Discusión:** Debe haber discusión documentada (comentarios en PR o issue)
- **Aprobación:** Requiere aprobación de ambos fundadores (Alan y Eduardo)
- **Documentación:** Toda enmienda debe actualizar la versión y fecha de este documento

### 11.2 Principio de Retrocompatibilidad
- **API:** No romper endpoints existentes sin versión (/api/v1/ → /api/v2/)
- **Base de Datos:** No eliminar columnas sin migración de datos previa
- **Frontend:** No cambiar flujos críticos sin período de transición

## ANEXO A: GLOSARIO DE TÉRMINOS
- **Tenant:** Comercio/empresa que usa el sistema
- **Warehouse:** Almacén físico donde se guarda mercancía
- **RLS:** Row-Level Security (seguridad a nivel de fila en PostgreSQL)
- **TTL:** Time To Live (tiempo de vida de un estado temporal)
- **Idempotencia:** Garantía de que una operación puede ejecutarse múltiples veces sin efectos secundarios
- **Bimoneda:** Manejo nativo de dos monedas (USD y VES)
- **Soft Lock:** Estado de suscripción que bloquea operaciones críticas pero permite consulta
- **Hard Lock:** Estado de suscripción que bloquea todo acceso excepto pago
- **SaaS:** Software as a Service (modelo de suscripción)
- **Bootstrap:** Crecimiento con recursos limitados, reinvirtiendo ganancias
- **MVP:** Minimum Viable Product (Producto Mínimo Viable)

## ANEXO B: CHECKLIST PARA NUEVAS FUNCIONALIDADES
- **Antes de implementar cualquier nueva funcionalidad, verificar:**
  - ¿Respeta los principios del Artículo I?
  - ¿Es compatible con la arquitectura multi-tenant (Artículo II)?
  - ¿Maneja correctamente el contexto bimoneda?
  - ¿Tiene una especificación clara (DBML, OpenAPI, diagrama)?
  - ¿Se han considerado los casos de error y edge cases?
  - ¿Se han definido los tests necesarios?
  - ¿Se ha actualizado la documentación?
  - ¿Respeta las restricciones del Artículo IX?
  - ¿Respeta la separación de responsabilidades financieras (Artículo III)?
  - ¿Está dentro del presupuesto actual (Artículo IV)?
  - ¿Es mobile-first (Artículo I, principio 5)?
  - ¿Aporta rapidez y eficiencia al usuario (Artículo I, principio 8)?

