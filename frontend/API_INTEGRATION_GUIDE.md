# GUÍA DE INTEGRACIÓN API NEXUS v3.0-MX (FRONTEND <-> BACKEND)

## 1. Introducción y Convenciones Generales
Esta guía es el contrato de referencia oficial entre la aplicación Flutter (`frontend/`) y la API FastAPI (`nexus_v3/backend`).

* **Base URL por Entorno:**
  * Android Emulator: `http://10.0.2.2:8000`
  * Web / Desktop: `http://127.0.0.1:8000`
  * Dispositivo Físico / Red Local: `http://<IP_LOCAL>:8000`
  * Override en tiempo de compilación: `flutter run --dart-define=API_URL=http://<IP>:8000`

* **Cabeceras Estándar:**
  * `Content-Type: application/json`
  * `Accept: application/json`
  * `Authorization: Bearer <access_token>`

* **Moneda Oficial:**
  * Todos los montos operan nativamente en **Pesos Mexicanos ($ MXN)** con precisión decimal estándar.

---

## 2. Módulo de Autenticación (`/api/v1/auth`)

### `POST /api/v1/auth/login`
* **Payload:**
  ```json
  {
    "tenant_id": "uuid-inquilino-opcional-o-slug",
    "username_or_email": "admin@tiendita.mx",
    "password": "password123"
  }
  ```
* **Respuesta Exitosa (200 OK):**
  ```json
  {
    "access_token": "eyJhbGciOi...",
    "refresh_token": "eyJhbGciOi...",
    "token_type": "bearer",
    "user": {
      "id": "uuid",
      "tenant_id": "uuid",
      "email": "admin@tiendita.mx",
      "username": "admin",
      "full_name": "Don Pepe",
      "is_active": true,
      "roles": ["OWNER"]
    },
    "tenant": {
      "id": "uuid",
      "name": "Abarrotes Don Pepe",
      "slug": "abarrotes-don-pepe",
      "subscription_plan": "EMPRENDEDOR",
      "subscription_status": "ACTIVE"
    }
  }
  ```

---

## 3. Módulo de Inventario (`/api/v1/inventory`)

### `GET /api/v1/inventory/products`
* **Query Params:** `q` (búsqueda difusa/código de barras), `category_id`, `low_stock` (bool), `skip`, `limit`.
* **Respuesta Exitosa (200 OK):** Lista de `ProductDto`:
  ```json
  [
    {
      "id": "uuid",
      "name": "Coca-Cola 600ml",
      "sku": "NEX-10001",
      "barcode": "7501055300075",
      "price_mxn": 18.50,
      "cost_mxn": 14.00,
      "total_stock": 48.0,
      "is_low_stock": false,
      "is_active": true,
      "category_name": "Bebidas"
    }
  ]
  ```

### `POST /api/v1/inventory/products` (Alta 3 Campos Vitales)
* **Payload:**
  ```json
  {
    "name": "Sabritas Sal 45g",
    "price_mxn": 22.00,
    "initial_stock": 30.0,
    "cost_mxn": 17.50,
    "barcode": "7501011123456"
  }
  ```

---

## 4. Módulo de Ventas y Checkout POS (`/api/v1/sales`)

### `POST /api/v1/sales/checkout` (Transaccional Atómico)
* **Payload:**
  ```json
  {
    "warehouse_id": "uuid-almacen",
    "client_id": null,
    "discount_mxn": 0.00,
    "items": [
      {
        "product_id": "uuid-producto",
        "quantity": 2.0,
        "unit_price_mxn": 18.50,
        "is_on_the_fly": false
      },
      {
        "is_on_the_fly": true,
        "on_the_fly_name": "Chicles Canels",
        "unit_price_mxn": 2.50,
        "quantity": 4.0,
        "on_the_fly_cost_mxn": 1.20
      }
    ],
    "payments": [
      {
        "payment_method": "CASH_MXN",
        "amount_paid_mxn": 50.00
      }
    ]
  }
  ```
* **Respuesta Exitosa (201 Created):**
  ```json
  {
    "id": "uuid-venta",
    "folio": "VTA-20260908-0001",
    "status": "COMPLETED",
    "subtotal_mxn": 47.00,
    "discount_mxn": 0.00,
    "total_mxn": 47.00,
    "total_cost_mxn": 32.80,
    "gross_profit_mxn": 14.20,
    "payment_method_type": "CASH_MXN",
    "amount_paid_mxn": 50.00,
    "change_returned_mxn": 3.00,
    "items": [],
    "created_at": "2026-09-08T18:00:00Z"
  }
  ```
