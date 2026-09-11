# Contrato API — SITRA-LUZ

> **Base URL:** `https://api.sitra-luz.clinica.pe/v1`
>
> Todas las peticiones requieren el header `Authorization: Bearer <token>` salvo `/auth/login`.
>
> La API actúa como **orquestador central**: escribe datos transaccionales en **MSSQL** y registros de auditoría/trazabilidad en **Firebase (NoSQL)**.

---

## Convenciones generales

| Aspecto | Convención |
| :--- | :--- |
| Formato de respuesta | JSON |
| Paginación | `?page=1&limit=20` (por defecto `limit=20`, máximo `100`) |
| Filtros | Query params: `?area=farmacia&estado=pendiente` |
| Códigos de éxito | `200 OK`, `201 Created`, `204 No Content` |
| Códigos de error | `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `409 Conflict`, `500 Internal Server Error` |
| Fechas | ISO 8601: `2026-09-11T16:00:00-05:00` |
| IDs | UUID v4 |

### Estructura estándar de respuesta

```json
{
  "success": true,
  "data": { ... },
  "message": "Operación exitosa",
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 85
  }
}
```

### Estructura estándar de error

```json
{
  "success": false,
  "error": {
    "code": "STOCK_INSUFICIENTE",
    "message": "No hay suficiente stock de Amoxicilina 500mg en Farmacia",
    "details": []
  }
}
```

---

## Mapeo MVVM ↔ API

Cada grupo de endpoints corresponde a un **Repository** en la capa `data/` y un **UseCase** en la capa `domain/`. Los ViewModels en `presentation/` nunca llaman a la API directamente.

```
presentation/viewmodels/  →  domain/usecases/  →  domain/repositories/  →  data/repositories/  →  data/datasources/api/
                                                       (interfaces)            (implementaciones)       (llamadas HTTP)
```

---

## 0. Autenticación

> **MVVM:** `AuthRepository` → `LoginUseCase`, `LogoutUseCase`

| Método | Endpoint | Descripción | Rol |
| :--- | :--- | :--- | :--- |
| `POST` | `/auth/login` | Iniciar sesión con correo y contraseña. Retorna JWT + datos del usuario y su rol. | Todos |
| `POST` | `/auth/logout` | Cerrar sesión e invalidar el token. | Todos |
| `GET` | `/auth/me` | Obtener perfil del usuario autenticado (nombre, rol, área asignada). | Todos |
| `POST` | `/auth/refresh` | Renovar el token JWT antes de que expire. | Todos |

### `POST /auth/login` — Request

```json
{
  "email": "jefa.farmacia@clinica.pe",
  "password": "********"
}
```

### `POST /auth/login` — Response `200`

```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "dGhpcyBpcyBhIHJl...",
    "expires_in": 3600,
    "user": {
      "id": "usr-001",
      "nombre": "María García",
      "email": "jefa.farmacia@clinica.pe",
      "rol": "JEFATURA_FARMACIA",
      "area": "FARMACIA"
    }
  }
}
```

### Roles válidos

| Código | Descripción |
| :--- | :--- |
| `ALMACEN` | Personal de almacén |
| `JEFATURA_FARMACIA` | Jefa de Farmacia |
| `FARMACIA` | Personal de turno / guardia de Farmacia |
| `ENFERMERIA_SOP` | Enfermería — Sala de Operaciones |
| `ENFERMERIA_EMERGENCIA` | Enfermería — Emergencias |
| `ENFERMERIA_HOSPITALIZACION` | Enfermería — Hospitalización |
| `ENFERMERIA_COCHE_PAROS` | Enfermería — Coche de Paros |

---

## 1. Registro Inteligente de Medicamentos (Módulo 1 — Almacén)

> **MVVM:** `MedicamentoRepository` → `RegistrarMedicamentoUseCase`, `ExtraerDatosIAUseCase`
>
> **BD destino:** MSSQL (catálogo maestro + lote) · Firebase (auditoría del registro)

| Método | Endpoint | Descripción | Rol |
| :--- | :--- | :--- | :--- |
| `POST` | `/medicamentos` | Registrar un nuevo medicamento con todos sus datos (manual o post-IA). | `ALMACEN` |
| `POST` | `/medicamentos/extraer-ia` | Enviar imagen + código GTIN a Gemini para extracción automática de datos. Retorna los campos sugeridos para revisión antes de confirmar. | `ALMACEN` |
| `GET` | `/medicamentos` | Listar catálogo maestro de medicamentos. Soporta búsqueda por nombre, principio activo o GTIN. | Todos |
| `GET` | `/medicamentos/{id}` | Detalle completo de un medicamento (datos maestros + lotes activos). | Todos |
| `GET` | `/medicamentos/buscar-gtin/{gtin}` | Buscar si un medicamento ya existe en el sistema por su código GTIN. Útil para evitar duplicados al escanear. | `ALMACEN` |

### `POST /medicamentos/extraer-ia` — Request (`multipart/form-data`)

| Campo | Tipo | Requerido | Descripción |
| :--- | :--- | :--- | :--- |
| `imagen` | file (jpg/png) | Sí | Foto de la caja del medicamento |
| `gtin` | string | Sí | Código GTIN escaneado localmente |

### `POST /medicamentos/extraer-ia` — Response `200`

```json
{
  "success": true,
  "data": {
    "nombre_comercial": "Amoxicilina 500mg",
    "principio_activo": "Amoxicilina",
    "lote": "L2026-A45",
    "fecha_vencimiento": "2027-06-15",
    "registro_sanitario": "RS-12345",
    "forma_farmaceutica": "Cápsula",
    "cantidad_presentacion": 100,
    "unidad_presentacion": "cápsulas",
    "confianza_ia": 0.94
  },
  "message": "Datos extraídos. Revise y confirme antes de registrar."
}
```

### `POST /medicamentos` — Request

```json
{
  "gtin": "07750215001234",
  "nombre_comercial": "Amoxicilina 500mg",
  "principio_activo": "Amoxicilina",
  "lote": "L2026-A45",
  "fecha_vencimiento": "2027-06-15",
  "registro_sanitario": "RS-12345",
  "forma_farmaceutica": "Cápsula",
  "cantidad_presentacion": 100,
  "unidad_presentacion": "cápsulas",
  "cantidad_ingresada": 5,
  "imagen_url": "https://storage.firebase.com/...",
  "confianza_ia": 0.94,
  "distribuidor": "Distribuidora Sur SAC"
}
```

---

## 2. Gestión de Inventario y Abastecimiento (Módulo 2)

> **MVVM:** `InventarioRepository`, `PedidoAbastecimientoRepository` → `ConsultarStockUseCase`, `SolicitarAbastecimientoUseCase`, `ConfirmarRecepcionUseCase`
>
> **BD destino:** MSSQL (saldos de stock, transferencias) · Firebase (historial de movimientos)

### 2.1 Consulta de Stock

| Método | Endpoint | Descripción | Rol |
| :--- | :--- | :--- | :--- |
| `GET` | `/inventario` | Stock general. Filtrable por `?area=FARMACIA&categoria=antibiotico`. | `JEFATURA_FARMACIA`, `FARMACIA`, `ALMACEN` |
| `GET` | `/inventario/resumen` | Resumen de totales por área (Almacén, Farmacia, SOP, Emergencia, Coche de Paros). | `JEFATURA_FARMACIA` |
| `GET` | `/inventario/{medicamento_id}/movimientos` | Historial de movimientos de un medicamento (entradas, salidas, transferencias). | `JEFATURA_FARMACIA` |

### `GET /inventario/resumen` — Response `200`

```json
{
  "success": true,
  "data": {
    "total_items": 1250,
    "por_area": [
      { "area": "ALMACEN", "total_items": 580, "valor_estimado": 45200.00 },
      { "area": "FARMACIA", "total_items": 420, "valor_estimado": 32100.00 },
      { "area": "SOP", "total_items": 85, "valor_estimado": 8900.00 },
      { "area": "EMERGENCIA", "total_items": 110, "valor_estimado": 9500.00 },
      { "area": "COCHE_PAROS", "total_items": 55, "valor_estimado": 7200.00 }
    ],
    "alertas_caducidad": 12,
    "items_stock_critico": 8
  }
}
```

### 2.2 Pedidos de Abastecimiento (Farmacia → Almacén)

| Método | Endpoint | Descripción | Rol |
| :--- | :--- | :--- | :--- |
| `POST` | `/pedidos-abastecimiento` | Farmacia crea un pedido de reposición de stock hacia Almacén. | `JEFATURA_FARMACIA`, `FARMACIA` |
| `GET` | `/pedidos-abastecimiento` | Listar pedidos. Filtrable por `?estado=PENDIENTE&origen=FARMACIA`. | `JEFATURA_FARMACIA`, `FARMACIA`, `ALMACEN` |
| `GET` | `/pedidos-abastecimiento/{id}` | Detalle de un pedido con sus ítems. | `JEFATURA_FARMACIA`, `FARMACIA`, `ALMACEN` |
| `PATCH` | `/pedidos-abastecimiento/{id}/despachar` | Almacén marca el pedido como despachado. | `ALMACEN` |
| `PATCH` | `/pedidos-abastecimiento/{id}/confirmar-recepcion` | Farmacia confirma la recepción. El stock se transfiere atómicamente (MSSQL). | `JEFATURA_FARMACIA`, `FARMACIA` |
| `PATCH` | `/pedidos-abastecimiento/{id}/rechazar` | Rechazar un pedido o una recepción incompleta, con motivo obligatorio. | `JEFATURA_FARMACIA`, `FARMACIA`, `ALMACEN` |

### Estados del pedido de abastecimiento

```
PENDIENTE → DESPACHADO → RECIBIDO
                ↘ RECHAZADO ↙
```

### `POST /pedidos-abastecimiento` — Request

```json
{
  "area_destino": "FARMACIA",
  "notas": "Reposición semanal - urgente",
  "items": [
    { "medicamento_id": "med-001", "cantidad_solicitada": 50 },
    { "medicamento_id": "med-015", "cantidad_solicitada": 20 },
    { "medicamento_id": "med-042", "cantidad_solicitada": 10 }
  ]
}
```

---

## 3. Peticiones y Dispensación a Áreas Críticas (Módulo 3)

> **MVVM:** `DispensacionRepository`, `KitRepository` → `SolicitarDispensacionUseCase`, `AlistarPedidoUseCase`, `ConfirmarEntregaUseCase`
>
> **BD destino:** MSSQL (descuento de stock atómico) · Firebase (auditoría completa: usuario, doctor, foto, firma)

### 3.1 Kits Prearmados

| Método | Endpoint | Descripción | Rol |
| :--- | :--- | :--- | :--- |
| `GET` | `/kits` | Listar kits estandarizados disponibles (Kit Cirugía General, Kit RCP, etc.). | Todos |
| `GET` | `/kits/{id}` | Detalle de un kit con su lista de medicamentos y cantidades. | Todos |

### `GET /kits` — Response `200`

```json
{
  "success": true,
  "data": [
    {
      "id": "kit-001",
      "nombre": "Kit Cirugía General",
      "descripcion": "Set estándar para procedimientos de cirugía general",
      "total_items": 12,
      "area_destino": "SOP"
    },
    {
      "id": "kit-002",
      "nombre": "Kit RCP",
      "descripcion": "Medicamentos de reanimación cardiopulmonar",
      "total_items": 8,
      "area_destino": "COCHE_PAROS"
    }
  ]
}
```

### 3.2 Dispensaciones (Solicitudes de Áreas Críticas → Farmacia)

| Método | Endpoint | Descripción | Rol |
| :--- | :--- | :--- | :--- |
| `POST` | `/dispensaciones` | Crear solicitud de dispensación. Requiere datos de auditoría obligatorios (doctor, motivo/paciente). | `ENFERMERIA_*` |
| `GET` | `/dispensaciones` | Listar dispensaciones. Filtrable por `?estado=PENDIENTE&area_origen=SOP`. | `FARMACIA`, `JEFATURA_FARMACIA`, `ENFERMERIA_*` |
| `GET` | `/dispensaciones/{id}` | Detalle de una dispensación con ítems y datos de auditoría. | `FARMACIA`, `JEFATURA_FARMACIA`, `ENFERMERIA_*` |
| `PATCH` | `/dispensaciones/{id}/listo-para-recojo` | Farmacia marca que el pedido está alistado y listo para recoger. Dispara notificación push al área solicitante. | `FARMACIA` |
| `PATCH` | `/dispensaciones/{id}/entregar` | Confirmar la entrega. Descuenta stock de Farmacia y lo asigna al área. Acepta foto opcional de salida. | `FARMACIA` |
| `PATCH` | `/dispensaciones/{id}/cancelar` | Cancelar una dispensación (con motivo). Solo si no ha sido entregada. | `FARMACIA`, `ENFERMERIA_*` |

### Estados de la dispensación

```
SOLICITADO → EN_PREPARACION → LISTO_PARA_RECOJO → ENTREGADO
      ↘          ↘                  ↘
              CANCELADO ←←←←←←←←←←←←←
```

### `POST /dispensaciones` — Request

```json
{
  "area_origen": "SOP",
  "tipo": "KIT",
  "kit_id": "kit-001",
  "doctor_id": "doc-015",
  "paciente": "Juan Pérez Rodríguez",
  "motivo": "Apendicectomía programada",
  "prioridad": "NORMAL",
  "items_adicionales": [
    { "medicamento_id": "med-088", "cantidad": 2 }
  ]
}
```

### `POST /dispensaciones` — Request (individual, sin kit)

```json
{
  "area_origen": "EMERGENCIA",
  "tipo": "INDIVIDUAL",
  "kit_id": null,
  "doctor_id": "doc-003",
  "paciente": "Ana Torres Quispe",
  "motivo": "Reacción alérgica severa",
  "prioridad": "URGENTE",
  "items": [
    { "medicamento_id": "med-012", "cantidad": 1 },
    { "medicamento_id": "med-045", "cantidad": 3 }
  ]
}
```

### `PATCH /dispensaciones/{id}/entregar` — Request (`multipart/form-data`)

| Campo | Tipo | Requerido | Descripción |
| :--- | :--- | :--- | :--- |
| `foto_salida` | file (jpg/png) | No | Foto opcional de los productos al salir de Farmacia |
| `observaciones` | string | No | Notas adicionales sobre la entrega |
| `recibido_por` | string (user_id) | Sí | ID del usuario que recoge el pedido |

---

## 4. Dashboard y Auditoría (Módulo 4 — Jefatura)

> **MVVM:** `DashboardRepository`, `TrazabilidadRepository` → `ObtenerEstadisticasUseCase`, `BuscarTrazabilidadUseCase`, `ObtenerAlertasUseCase`
>
> **BD destino:** MSSQL (consultas agregadas de stock) · Firebase (historial de auditoría)

### 4.1 Estadísticas

| Método | Endpoint | Descripción | Rol |
| :--- | :--- | :--- | :--- |
| `GET` | `/dashboard/consumo-por-area` | Consumo de medicamentos agrupado por área. Filtrable por rango de fechas `?desde=2026-09-01&hasta=2026-09-30`. | `JEFATURA_FARMACIA` |
| `GET` | `/dashboard/consumo-por-doctor` | Ranking de doctores por consumo de medicamentos. | `JEFATURA_FARMACIA` |
| `GET` | `/dashboard/top-medicamentos` | Medicamentos más consumidos en un período. | `JEFATURA_FARMACIA` |

### `GET /dashboard/consumo-por-area` — Response `200`

```json
{
  "success": true,
  "data": {
    "periodo": { "desde": "2026-09-01", "hasta": "2026-09-30" },
    "consumo": [
      { "area": "SOP", "total_items": 320, "total_dispensaciones": 45 },
      { "area": "EMERGENCIA", "total_items": 180, "total_dispensaciones": 92 },
      { "area": "HOSPITALIZACION", "total_items": 150, "total_dispensaciones": 60 },
      { "area": "COCHE_PAROS", "total_items": 25, "total_dispensaciones": 3 }
    ]
  }
}
```

### 4.2 Trazabilidad

| Método | Endpoint | Descripción | Rol |
| :--- | :--- | :--- | :--- |
| `GET` | `/trazabilidad/medicamento/{id}` | Historial completo de un medicamento: desde su ingreso en Almacén hasta su uso final. | `JEFATURA_FARMACIA` |
| `GET` | `/trazabilidad/lote/{numero_lote}` | Rastrear todas las unidades de un lote específico. | `JEFATURA_FARMACIA` |

### `GET /trazabilidad/medicamento/{id}` — Response `200`

```json
{
  "success": true,
  "data": {
    "medicamento": {
      "id": "med-001",
      "nombre_comercial": "Amoxicilina 500mg",
      "lote": "L2026-A45",
      "gtin": "07750215001234"
    },
    "eventos": [
      {
        "tipo": "INGRESO_ALMACEN",
        "fecha": "2026-08-15T10:30:00-05:00",
        "usuario": "Carlos Mendoza",
        "area": "ALMACEN",
        "cantidad": 100,
        "confianza_ia": 0.94
      },
      {
        "tipo": "TRANSFERENCIA_FARMACIA",
        "fecha": "2026-08-16T09:00:00-05:00",
        "usuario": "María García",
        "area_origen": "ALMACEN",
        "area_destino": "FARMACIA",
        "cantidad": 50,
        "pedido_id": "ped-045"
      },
      {
        "tipo": "DISPENSACION_SOP",
        "fecha": "2026-08-20T14:15:00-05:00",
        "usuario": "Ana López (Enfermera)",
        "doctor": "Dr. Roberto Chávez",
        "paciente": "Juan Pérez",
        "motivo": "Apendicectomía",
        "cantidad": 5,
        "dispensacion_id": "disp-078",
        "foto_salida_url": "https://storage.firebase.com/..."
      }
    ]
  }
}
```

### 4.3 Alertas de Caducidad (FEFO)

| Método | Endpoint | Descripción | Rol |
| :--- | :--- | :--- | :--- |
| `GET` | `/alertas/caducidad` | Medicamentos próximos a vencer. Filtrable por `?dias=30&area=FARMACIA`. | `JEFATURA_FARMACIA`, `FARMACIA`, `ALMACEN` |
| `GET` | `/alertas/stock-critico` | Medicamentos con stock por debajo del mínimo configurado. | `JEFATURA_FARMACIA`, `FARMACIA` |

### `GET /alertas/caducidad?dias=30` — Response `200`

```json
{
  "success": true,
  "data": [
    {
      "medicamento_id": "med-022",
      "nombre_comercial": "Diclofenaco 75mg",
      "lote": "L2025-D12",
      "fecha_vencimiento": "2026-10-05",
      "dias_restantes": 24,
      "area": "FARMACIA",
      "cantidad_en_stock": 35,
      "severidad": "WARNING"
    },
    {
      "medicamento_id": "med-009",
      "nombre_comercial": "Ibuprofeno 400mg",
      "lote": "L2025-I08",
      "fecha_vencimiento": "2026-09-20",
      "dias_restantes": 9,
      "area": "ALMACEN",
      "cantidad_en_stock": 120,
      "severidad": "CRITICAL"
    }
  ]
}
```

---

## 5. Recursos de Soporte

> **MVVM:** `DoctorRepository`, `UsuarioRepository`

| Método | Endpoint | Descripción | Rol |
| :--- | :--- | :--- | :--- |
| `GET` | `/doctores` | Listar médicos registrados en la clínica. Necesario para seleccionar doctor en dispensaciones. | Todos |
| `GET` | `/doctores/{id}` | Detalle de un doctor. | Todos |
| `GET` | `/usuarios` | Listar usuarios del sistema (para asignaciones y auditoría). | `JEFATURA_FARMACIA` |
| `GET` | `/areas` | Listar áreas de la clínica con sus configuraciones (stock mínimo, etc.). | Todos |

---

## Notificaciones Push (Firebase Cloud Messaging)

Las siguientes acciones disparan notificaciones push automáticas. No son endpoints REST, sino eventos del backend:

| Evento | Destinatario | Mensaje |
| :--- | :--- | :--- |
| Nueva dispensación creada | `FARMACIA` | "Nueva solicitud de SOP — Kit Cirugía General" |
| Pedido listo para recojo | `ENFERMERIA_*` (solicitante) | "Su pedido #078 está listo para recoger en Farmacia" |
| Nuevo pedido de abastecimiento | `ALMACEN` | "Farmacia solicita reposición — 3 ítems" |
| Alerta de caducidad | `JEFATURA_FARMACIA` | "⚠️ 5 medicamentos vencen en los próximos 15 días" |
| Stock crítico | `JEFATURA_FARMACIA`, `FARMACIA` | "⚠️ Amoxicilina 500mg por debajo del mínimo en Farmacia" |

---

## Resumen de Endpoints

| # | Método | Endpoint | Módulo |
| :--- | :--- | :--- | :--- |
| 1 | `POST` | `/auth/login` | Auth |
| 2 | `POST` | `/auth/logout` | Auth |
| 3 | `GET` | `/auth/me` | Auth |
| 4 | `POST` | `/auth/refresh` | Auth |
| 5 | `POST` | `/medicamentos` | Módulo 1 |
| 6 | `POST` | `/medicamentos/extraer-ia` | Módulo 1 |
| 7 | `GET` | `/medicamentos` | Módulo 1 |
| 8 | `GET` | `/medicamentos/{id}` | Módulo 1 |
| 9 | `GET` | `/medicamentos/buscar-gtin/{gtin}` | Módulo 1 |
| 10 | `GET` | `/inventario` | Módulo 2 |
| 11 | `GET` | `/inventario/resumen` | Módulo 2 |
| 12 | `GET` | `/inventario/{medicamento_id}/movimientos` | Módulo 2 |
| 13 | `POST` | `/pedidos-abastecimiento` | Módulo 2 |
| 14 | `GET` | `/pedidos-abastecimiento` | Módulo 2 |
| 15 | `GET` | `/pedidos-abastecimiento/{id}` | Módulo 2 |
| 16 | `PATCH` | `/pedidos-abastecimiento/{id}/despachar` | Módulo 2 |
| 17 | `PATCH` | `/pedidos-abastecimiento/{id}/confirmar-recepcion` | Módulo 2 |
| 18 | `PATCH` | `/pedidos-abastecimiento/{id}/rechazar` | Módulo 2 |
| 19 | `GET` | `/kits` | Módulo 3 |
| 20 | `GET` | `/kits/{id}` | Módulo 3 |
| 21 | `POST` | `/dispensaciones` | Módulo 3 |
| 22 | `GET` | `/dispensaciones` | Módulo 3 |
| 23 | `GET` | `/dispensaciones/{id}` | Módulo 3 |
| 24 | `PATCH` | `/dispensaciones/{id}/listo-para-recojo` | Módulo 3 |
| 25 | `PATCH` | `/dispensaciones/{id}/entregar` | Módulo 3 |
| 26 | `PATCH` | `/dispensaciones/{id}/cancelar` | Módulo 3 |
| 27 | `GET` | `/dashboard/consumo-por-area` | Módulo 4 |
| 28 | `GET` | `/dashboard/consumo-por-doctor` | Módulo 4 |
| 29 | `GET` | `/dashboard/top-medicamentos` | Módulo 4 |
| 30 | `GET` | `/trazabilidad/medicamento/{id}` | Módulo 4 |
| 31 | `GET` | `/trazabilidad/lote/{numero_lote}` | Módulo 4 |
| 32 | `GET` | `/alertas/caducidad` | Módulo 4 |
| 33 | `GET` | `/alertas/stock-critico` | Módulo 4 |
| 34 | `GET` | `/doctores` | Soporte |
| 35 | `GET` | `/doctores/{id}` | Soporte |
| 36 | `GET` | `/usuarios` | Soporte |
| 37 | `GET` | `/areas` | Soporte |

**Total: 37 endpoints**
