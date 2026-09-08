# REGLAS Y DIRECTRICES DEL PROYECTO NEXUS

## 1. Regla de Rediseño e Interfaz de Usuario (UI)
* **Inspección Previa Obligatoria:** Antes de aplicar cualquier modificación o rediseño a cualquier pantalla o componente en la aplicación frontend, se DEBE consultar y analizar la referencia visual correspondiente ubicada en la carpeta `D:\aland\Documents\Proyectos\Nexus\frontend\UI Design`.
* **Fidelidad Visual:** Todos los estilos (paleta de colores oscuros, tipografía, espacioso de bordes, iconos y diseño de componentes) deben ser modelados de acuerdo a la captura de pantalla de referencia correspondiente.

## 2. Regla de Integración Frontend-Backend y Contratos de Datos API (Obligatoria)
* **Fuente Única de Verdad (OpenAPI & Pydantic):** Todo endpoint, método HTTP, parámetro de ruta/query y cuerpo de petición (payload) en el frontend DEBE corresponder exactamente a los esquemas Pydantic del backend (`app/modules/*/schemas/`) y a la especificación OpenAPI (`nexus_v3/docs/api/`).
* **Moneda Base Nativa MXN ($):** Todos los campos monetarios de productos, ventas, cobros y arqueos operan en Pesos Mexicanos (ej: `price_mxn`, `cost_mxn`, `total_mxn`, `amount_paid_mxn`). Queda terminantemente prohibido utilizar sufijos obsoletos como `_usd` o `_ves` en los modelos y endpoints de la API.
* **Prohibición de Mapas Crudos (`Map<String, dynamic>`):** En el frontend Flutter, todas las respuestas y solicitudes de red deben modelarse a través de **Data Transfer Objects (DTOs)** fuertemente tipados con serialización segura (`fromJson` / `toJson`), evitando el acceso manual por cadenas (`data['tokens']['access_token']`) que puedan ocasionar excepciones de puntero nulo en tiempo de ejecución.
* **Manejo Dinámico de URL Base:** El cliente HTTP (`api_client.dart`) debe soportar resolución dinámica de URL base (vía `const String.fromEnvironment('API_URL')`, emulador Android `10.0.2.2:8000`, Flutter Web `127.0.0.1:8000` o IP local) para que cualquier desarrollador pueda compilar y probar inmediatamente en cualquier plataforma sin modificar el código fuente.
* **Comentarios Exhaustivos Línea por Línea:** Todo archivo generado o modificado debe contener comentarios explicativos en cada línea o bloque lógico para máxima legibilidad y mantenibilidad.
