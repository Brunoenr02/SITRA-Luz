# 📊 Análisis Completo — Proyecto SITRA-Luz

## 🏥 ¿Qué es SITRA-Luz?

**SITRA-Luz** (Sistema de Trazabilidad — Luz) es una **aplicación móvil Flutter** para la **Clínica La Luz** en Tacna, Perú. Su propósito es digitalizar el flujo interno de medicamentos que el sistema actual de escritorio de la clínica (**Dialyma**) no cubre.

> Dialyma solo registra: entrada del proveedor → almacén, y salida por caja (venta). Todo el movimiento INTERNO (almacén → farmacia → áreas clínicas) se hace en papel.

---

## 🎯 Misión / Visión del Producto

**"Digitalizar el flujo interno de medicamentos que Dialyma no cubre: desde que salen de Almacén, pasan por Farmacia y llegan a las áreas clínicas, con peticiones digitales, trazabilidad completa y notificaciones en tiempo real — todo desde el celular del personal."**

### Problema validado (5 entrevistas reales):
1. El movimiento interno no tiene registro digital → genera inventario "fantasma" y descuadres de S/ 800-1,500/mes
2. Las peticiones de medicamentos para procedimientos se hacen en papel → esperas de 30-45 min en farmacia
3. No hay trazabilidad de quién consumió qué → si falta stock, es imposible rastrearlo

---

## 👥 Equipo (Grupo 04)

| Integrante | Rol Scrum | Tecnologías |
|---|---|---|
| **Bruno Ancco Suaña** | Scrum Master, Developer | Flutter, Firebase, Git/CI |
| **Walter Sala Jiménez** | Product Owner, Developer | Flutter, Firebase, Análisis |
| **David Anampa** | Developer, QA | Flutter, Firebase, UI/UX |

**Dispositivos de prueba:** Samsung A14, Redmi 13C (×2), Pixel 6 AVD (emulador)

---

## 🏗️ Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Frontend (app) | **Flutter/Dart** para Android |
| Escáner GTIN | **Google ML Kit** (mobile_scanner) — offline, sin internet |
| IA/OCR | **Gemini Flash API** (Structured Outputs JSON) |
| BD Relacional | **MSSQL** (ya existente en la clínica) — catálogo maestro, stock, lotes |
| BD NoSQL | **Firebase (Firestore)** — auditoría, trazabilidad, fotos, metadatos IA |
| Auth & Push | **Firebase Auth + FCM** |
| Storage | **Firebase Storage** (fotos de salida, imágenes de cajas) |
| CI/CD | **GitHub Actions** |
| PDF | Exportación fiel al formato físico de la clínica |
| Drive | Google Drive API (archivado automático) |

**Arquitectura de la app:** MVVM + Repositorio (capa de dominio ligera)

```
View → ViewModel → UseCase (solo si hay lógica real) → Repository (interface) → DataSource
```

---

## 🗂️ Módulos del Sistema

### Módulo 1: Registro Inteligente (Almacén)
- Escaneo de código **GTIN/GS1** con cámara (offline, ML Kit)
- Foto opcional de la caja → Gemini extrae: nombre comercial, principio activo, lote, vencimiento, registro sanitario, forma farmacéutica
- Revisión y corrección humana de datos extraídos
- Registro en MSSQL + auditoría en NoSQL

### Módulo 2: Gestión de Inventario y Abastecimiento
- Stock consolidado (Farmacia + Almacén) en tiempo real
- Solicitudes de faltantes por guardia (Farmacia → Almacén)
- Transferencias atómicas (Almacén → Farmacia)
- Entradas de stock (proveedor → almacén)

### Módulo 3: Peticiones y Dispensación a Áreas Críticas
- **Fichas de pedido** (tipo General y Neonatología)
- Kits prearmados editables (para SOP, Coche de Paros)
- Flujo: Enviado → En preparación → Listo para recoger → Entregado
- Descuento atómico de stock al confirmar recojo
- Exportación a PDF + subida a Google Drive
- Notificaciones push (FCM) al área solicitante

### Módulo 4: Dashboard de Jefatura y Auditoría
- Trazabilidad completa por medicamento o lote
- Stock por área en tiempo real (Almacén, Farmacia, SOP, Emergencia, Coche de Paros)
- Gráficos: consumo por área, por doctor, medicamentos más dispensados
- Alertas FEFO (caducidad) y stock crítico

---

## 👤 Roles de Usuario

| Rol | Acceso |
|---|---|
| **Administrador** | Acceso total; gestiona usuarios, kits, tipos financiamiento |
| **Jefatura de Farmacia** | Dashboard, reportes, trazabilidad, alertas |
| **Farmacia** | Gestión de pedidos entrantes, preparación, entrega, listado de faltantes |
| **Almacén** | Registro de medicamentos (GTIN+IA), stock, transferencias, solicitudes |
| **Enfermería/Técnico** | Crea fichas de pedido, confirma recojo |

---

## 📋 Fichas de Pedido (Núcleo Operativo)

### Ficha General:
- Número autogenerado + fecha/hora
- Nombre del paciente, procedencia (Emergencia / Hospitalización / Otro-libre)
- Tipo de financiamiento (configurable: Particular, EPS, SOAT, Rimac, Mapfre, etc.)
- Diagnóstico/procedimiento (texto libre)
- Lista de ítems: medicamentos y dispositivos médicos (secciones separadas)
- Doctor a cargo, técnico/enfermera que recoge

### Ficha Neonatología:
- Nombre de la madre, habitación (opcional)
- Apellidos del recién nacido, tipo de parto
- Tabla insumos (nombre + cantidad) + kits preestablecidos editables
- Doctor a cargo, técnico/enfermera que recoge

**Estados de ficha:** Borrador → Enviado → En preparación → Listo para recoger → Entregado / Anulado

---

## 📡 API Contract (37 endpoints definidos)

Base URL: `https://api.sitra-luz.clinica.pe/v1`

| Módulo | Endpoints |
|---|---|
| Auth | 4 (login, logout, me, refresh) |
| Medicamentos (Módulo 1) | 5 |
| Inventario/Abastecimiento (Módulo 2) | 9 |
| Dispensaciones/Kits (Módulo 3) | 8 |
| Dashboard/Trazabilidad (Módulo 4) | 7 |
| Soporte (doctores, usuarios, áreas) | 4 |

Patrón de respuesta estándar: `{ success, data, message, pagination }`

---

## 📌 Requerimientos (Resumen)

**31 RF + 13 RNF** (v6)

### RF prioritarios (Alta):
RF-001 Auth · RF-002 Roles · RF-003 Fichas · RF-004 Catálogo · RF-006 Lista fichas · RF-007 Detalle · RF-008 Estados · RF-009 Cantidades despachadas · RF-010 Confirmar recojo · RF-013 Catálogo medicamentos · RF-014 Escaneo GTIN · RF-015 Revisión IA · RF-020 Usuarios · RF-021 Crear usuario · RF-022 Editar usuario · RF-023 Stock · RF-024 Entradas · RF-025 Transferencias · RF-026 Trazabilidad

### RNF críticos:
- RBAC (control por rol en cada endpoint y pantalla)
- Auditoría inmutable de cambios de estado
- Atomicidad del descuento de stock
- Respuesta < 3 segundos en operaciones críticas (4G)
- GTIN offline con ML Kit
- bcrypt/Argon2 para contraseñas
- Sesión expira en 15 min de inactividad (configurable)

---

## 🗓️ Estado Actual del Sprint

### Sprint 1 (07/09 – 18/09/2026) — ACTIVO

**Sprint Goal:** "Establecer base técnica + login funcional con roles (HU-23)"

**Semana 1 (Daily 1 — 11/09/2026) — CERRADA:**

| Tarea | Responsable | Estado |
|---|---|---|
| TT-01: Esquema MSSQL + NoSQL | Bruno | En revisión/Listo parcial |
| TT-02: Contrato API (borrador) | Bruno | En progreso |
| TT-03: Estructura Flutter MVVM + CI/CD | Walter | En pruebas |
| DT-01: Wireframes (Almacén, Jefatura, Enfermería) | David | Listo parcial (falta Enfermería) |
| TT-04: Documentación modelo híbrido | David | En progreso |
| HU-23: Login con roles | — | Sprint Backlog (sin iniciar) |

**Semana 2 (Daily 2) — POR REALIZAR:**
- Cerrar TT-02, DT-01, TT-04
- Desarrollar HU-23: pantalla login, LoginViewModel, endpoint auth, enrutamiento por rol
- Demo cierre Sprint 1: login funcional con 3 roles

---

## 📁 Estructura del Workspace

```
Moviles02/
├── contexto/contexto/          → Documentación de análisis y diseño
│   ├── INFORMACION BASICA.md  → Descripción general del sistema
│   ├── contexto.txt           → Notas de planning del Sprint 1
│   ├── formularios.txt        → Especificación de fichas de pedido
│   └── plan.md                → Preguntas críticas con respuestas del cliente
├── requerimientos.md          → 31 RF + 13 RNF completos (v6)
├── Contexto_Que_Avanzamos_teorico.txt → Contexto teórico del curso
├── Lab03_Sol_Mol02/           → Lab 03 (ejercicio del curso)
├── SITRA-Luz-Sprint-01/       → Repositorio Sprint 01
│   └── lib/ (core/data/domain/presentation — solo estructura vacía)
│   └── docs/api-contract.md  → ✅ 37 endpoints definidos
│   └── CONVENTIONS.md        → Conventional Commits + GitFlow
├── SITRA-Luz-taller-02/       → ← APP ACTIVA (Taller 02)
│   └── docs/ (VISION, LEAN_CANVAS, VALIDACION, EQUIPO, ADRs, evidencias)
│   └── app/flutter_prueba/   → ✅ APP FLUTTER REAL AQUÍ
│       └── lib/features/inventario/ (MVVM implementado, UiState pattern)
└── SITRA-Luz-taller-03/       → Repositorio Taller 03 (misma estructura que taller-02)
```

---

## 💡 Observaciones Clave sobre el Código

1. **App Flutter real** en `SITRA-Luz-taller-02/app/flutter_prueba/` — ya implementa MVVM con patrón `UiState<T>` (Loading, Success, Error, Empty) usando `ChangeNotifier`
2. **El contrato de API** (37 endpoints) está 100% documentado con requests/responses de ejemplo
3. **Arquitectura MVVM correcta:** View no tiene lógica, ViewModel usa `ChangeNotifier`, Repository es interfaz separada de implementación
4. **El Sprint 1 termina el 18/09/2026** — falta la Semana 2 (HU-23: login)
5. **25 HU** en 5 épicas: A: Registro Inteligente (4), B: Inventario (5), C: Dispensación (9), D: Dashboard (4), E: Transversales (3)
6. **Modelo de datos híbrido:** MSSQL para datos transaccionales duros + Firebase para auditoría/trazabilidad
7. **SDK Dart:** ^3.13.2 — proyecto recién inicializado, solo tiene la feature de Inventario como prototipo

---

## 🔗 Referencias

- **GitHub:** https://github.com/Brunoenr02/SITRA-Luz
- **GitHub Projects:** https://github.com/users/Brunoenr02/projects/1/views/1
- **Cliente:** Clínica La Luz, Tacna, Perú
- **Curso:** SI988 — Desarrollo Móvil 02
- **Universidad:** UPT (Universidad Privada de Tacna)
