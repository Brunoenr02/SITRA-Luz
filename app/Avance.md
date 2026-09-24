# 📋 SITRA-Luz — Documento Maestro de Contexto, Arquitectura y Avance

> **Propósito de este documento:**  
> Este archivo consolida de forma exhaustiva todo el contexto del proyecto, investigación de campo, requerimientos, arquitectura técnica, estado de avance y decisiones de implementación. Sirve como fuente única de verdad para retomar el desarrollo en cualquier entorno, cuenta o asistente de IA (Claude, Antigravity, etc.) sin necesidad de reanalizar los laboratorios o archivos previos.

---

## 🏥 1. Contexto del Negocio y Problema Real

### 1.1 ¿Qué es SITRA-Luz?
**SITRA-Luz** (*Sistema de Trazabilidad — Luz*) es una aplicación móvil desarrollada para la **Clínica La Luz** (Sede Tacna, Perú), como parte de la asignatura **Desarrollo Móvil 02 (SI988)** de la **Universidad Privada de Tacna (UPT)**.

* **Equipo de Desarrollo (Grupo 04):**
  * **Bruno Enmanuel Ancco Suaña** (Scrum Master / Backend & Mobile Dev)
  * **Walter Sala Jiménez** (Product Owner / Mobile Dev & Business Analyst)
  * **David Anampa** (Developer / Mobile UI & QA)
* **Repositorio GitHub:** `https://github.com/Brunoenr02/SITRA-Luz`

### 1.2 El Problema Validado en Clínica La Luz
La clínica cuenta con un sistema de escritorio llamado **Dialyma (ERP)**. Sin embargo, Dialyma **únicamente registra**:
1. Entrada inicial de compra (Proveedor → Almacén General).
2. Salida comercial final (Venta en caja por farmacia externa).

**La brecha operativa:**  
Todo el flujo logístico y clínico **INTERNO** que ocurre entre:
`Almacén General` ➔ `Farmacia Central` ➔ `Botiquines de Piso / Áreas Críticas (UCI, Emergencia, Hospitalización, SOP, Neonatología)`
se gestionaba tradicionalmente en **papel, libretas manuales y llamadas telefónicas**.

**Consecuencias validadas en entrevistas reales:**
* **Inventario fantasma:** Descuadres mensuales de **S/ 800 a S/ 1,500** en medicamentos no registrados.
* **Tiempos de espera críticos:** Demoras de **30 a 45 minutos** para que enfermería obtenga medicamentos para procedimientos o emergencias.
* **Cero trazabilidad:** Imposibilidad de auditar qué lote específico fue suministrado a cada paciente o si una dosis sobrante fue devuelta al stock.
* **Pérdidas por vencimiento:** Falta de aplicación estricta del principio **FEFO** (*First Expired, First Out* — Primero en vencer, primero en salir).

---

## 🎯 2. Misión y Alcance del Sistema

> **Misión:**  
> "Digitalizar y blindar el flujo interno de medicamentos y material médico que Dialyma no cubre: peticiones digitales en tiempo real, validación estricta de lotes con escaneo GTIN/código de barras, control de temperatura en cadena de frío, semáforo FEFO preventivo y trazabilidad completa por paciente y servicio clínico."

---

## 👥 3. Roles del Sistema y Matriz de Acceso (RF-002)

El sistema define 5 roles estrictamente tipificados:

| Rol (`UserRole`) | Valor Firestore | Alcance y Pantalla | Responsabilidades Principales |
|---|---|---|---|
| **Administrador** | `ADMINISTRADOR` | `/admin` | Gestión de cuentas de usuario, asignación de roles y áreas médicas, consulta de logs de auditoría global y sincronización con Dialyma. |
| **Jefatura de Farmacia** | `JEFATURA_FARMACIA` | `/jefatura` | Supervisión técnica general, matriz FEFO, alertas de lotes críticos (<30d, <90d), aprobación de medicamentos de alto costo o restringidos. |
| **Farmacia** | `FARMACIA` | `/farmacia` | Atención de recetas ambulatorias y hospitalarias, validación de prescripciones, escaneo de lotes y despacho de pedidos a botiquines de piso. |
| **Almacén General** | `ALMACEN` | `/almacen` | Recepción de mercadería con guías de remisión, registro de lotes y fechas de vencimiento, monitoreo de **cadena de frío (2°C a 8°C)** y transferencias a Farmacia. |
| **Enfermería / Técnico** | `ENFERMERIA` | `/enfermeria` | Gestión de botiquín del servicio asignado (UCI, Emergencia, etc.), **pedido urgente de reposición a farmacia**, registro de administración a paciente y devolución de mermas/sobrantes. |

---

## 🏗️ 4. Arquitectura de Software y Stack Tecnológico

### 4.1 Tecnologías Base
* **Frontend Móvil:** Flutter 3.x / Dart 3.
* **Gestor de Estados:** `Provider` (`ChangeNotifierProvider`).
* **Enrutamiento:** `GoRouter` con guardias de seguridad basadas en autenticación y rol (RBAC).
* **Diseño / UI:** Material 3 con tema corporativo médico (`AppTheme`, `AppColors`) y tipografía `GoogleFonts.inter`.
* **Backend Cloud (100% Supabase):**
  * **Supabase Database (PostgreSQL):** Base de datos relacional para catálogo maestro, lotes, inventario por áreas, fichas de dispensación, kits y bitácora inmutable de auditoría (10 tablas con RLS y triggers automáticos).
  * **Supabase Auth:** Autenticación por correo y contraseña con JWT y sincronización automática a la tabla `profiles`.
  * **Modo Offline / Fallback:** Repositorio simulado (`MockAuthRepository`) para pruebas sin conexión.
* **Notificaciones Push (Firebase FCM):**
  * **Firebase Cloud Messaging (FCM):** Servicio reservado exclusivamente para despacho y recepción de alertas y notificaciones push. Actualmente diferido para una fase posterior mediante feature-flag (`NotificationService.enablePushNotifications = false`).

### 4.2 Configuración Supabase y Android
* **Instancia Supabase:** `https://nedeqnvpkalrchswrapr.supabase.co` configurada en `lib/core/config/supabase_config.dart`.
* **Script de BD:** `docs/supabase/setup_sitra_luz.sql` con esquema relacional completo.
* **Android Application ID / Namespace:** `ap.sitra.luz.clinica`.
* **Permisos de Red Android:** `android.permission.INTERNET`, `android.permission.ACCESS_NETWORK_STATE`, y `usesCleartextTraffic="true"`.
* **Google Services Plugin:** Desactivado temporalmente en `android/app/build.gradle.kts` hasta la implementación de Firebase FCM en fases posteriores.

### 4.3 Patrón Arquitectónico (Clean Architecture + MVVM)
El código en `sitra_luz_app/lib/` respeta la separación de capas:

```text
sitra_luz_app/lib/
├── core/
│   ├── routes/
│   │   └── app_router.dart          # Enrutador GoRouter con redirección por rol
│   ├── theme/
│   │   └── app_theme.dart           # Sistema de diseño, paleta de colores y temas
│   └── widgets/
│       └── sitra_app_bar.dart       # Barra corporativa reutilizable con badge de rol y logout
├── features/
│   ├── auth/                        # Módulo de Autenticación y Sesión
│   │   ├── domain/
│   │   │   ├── entities/user_entity.dart         # Entidad pura UserEntity y Enum UserRole
│   │   │   └── repositories/auth_repository.dart # Interfaz abstracta del repositorio
│   │   ├── data/
│   │   │   ├── models/user_model.dart            # DTO para mapear Firestore <-> Dominio
│   │   │   ├── datasources/auth_remote_datasource.dart # Conexión a Firebase Auth y Firestore
│   │   │   ├── repositories/auth_repository_impl.dart  # Implementación concreta con Firebase
│   │   │   └── repositories/mock_auth_repository.dart  # Modo simulación offline/demo
│   │   └── presentation/
│   │       ├── states/auth_state.dart            # Sealed class (Initial, Loading, Authenticated, Error)
│   │       ├── viewmodels/auth_viewmodel.dart    # ViewModel desacoplado (ChangeNotifier)
│   │       └── views/login_view.dart             # Vista de Login con chips de acceso rápido
│   ├── dashboard_admin/presentation/views/admin_dashboard_view.dart
│   ├── dashboard_jefatura/presentation/views/jefatura_dashboard_view.dart
│   ├── dashboard_farmacia/presentation/views/farmacia_dashboard_view.dart
│   ├── dashboard_almacen/presentation/views/almacen_dashboard_view.dart
│   └── dashboard_enfermeria/presentation/views/enfermeria_dashboard_view.dart
└── main.dart                        # Punto de entrada híbrido (Firebase activo / Fallback Demo)
```

---

## ⚡ 5. Cuentas de Demostración y Modo Offline

Para evaluar el sistema inmediatamente (incluso sin internet o antes de poblar Firestore), [login_view.dart](file:///d:/PROYECTOS_UPT/Moviles02/SITRA_LUZ_ANAMPA_ANCCO_SALAS/sitra_luz_app/lib/features/auth/presentation/views/login_view.dart) incorpora botones de acceso rápido de 1 clic:

| Rol | Correo Demo | Contraseña | Nombre en Pantalla | Servicio / Área Asignada |
|---|---|---|---|---|
| **Administrador** | `admin@sitraluz.pe` | `admin123` | Ing. Carlos Mendoza | Sistemas, Dirección, Auditoría |
| **Jefatura de Farmacia** | `jefatura@sitraluz.pe` | `jefe123` | Dra. Elena Ramos | Farmacia Central, Comité |
| **Farmacia** | `farmacia@sitraluz.pe` | `farma123` | Q.F. Manuel Flores | Farmacia Central, Dispensación |
| **Almacén** | `almacen@sitraluz.pe` | `almacen123` | Sr. Roberto Paredes | Almacén General, Recepción |
| **Enfermería** | `enfermeria@sitraluz.pe` | `enfermera123` | Lic. Ana Morales | UCI Adultos, Pabellón Cirugía |

*(Nota: En modo demo, cualquier contraseña ingresada como `123456` también es aceptada para facilitar pruebas).*

---

## 📦 6. Estado Actual de la Implementación (Avance Concluido)

1. ✅ **Creación del proyecto base:** Estructurado en `app/` con dependencias modernas (`supabase_flutter`, `provider`, `go_router`, `google_fonts`, `shared_preferences`).
2. ✅ **Diseño del Sistema:** Implementado `AppTheme` y `AppColors` con identidad visual médica propia de la clínica.
3. ✅ **Capa de Dominio y Datos (100% Supabase):** Entidades, repositorios y modelos mapeados con Supabase Auth y tabla `profiles`, con fallback a `MockAuthRepository`.
4. ✅ **Seguridad y Enrutamiento:** `GoRouter` configurado con guardias RBAC que impiden acceder a dashboards sin sesión y redirigen automáticamente a la pantalla del rol correspondiente tras autenticar.
5. ✅ **5 Pantallas de Roles Completadas:**
   * `/admin`: Métricas de auditoría, control de accesos, sincronización Dialyma.
   * `/jefatura`: Alertas críticas FEFO (<30d, <90d), aprobaciones de alto costo.
   * `/farmacia`: Cola de dispensación de recetas y pedidos de piso pendientes.
   * `/almacen`: Control de guías de remisión, monitoreo de cadena de frío (3.8 °C).
   * `/enfermeria`: Botiquín del servicio (UCI Adultos), botón de pedido urgente de reposición.
6. ✅ **Configuración Android y Red:**
   * Permisos de red en AndroidManifest: `INTERNET`, `ACCESS_NETWORK_STATE`, y `usesCleartextTraffic="true"`.
   * Google Services Plugin desactivado temporalmente para permitir ejecución fluida sin requerir `google-services.json` de inmediato.
   * `NotificationService` con bandera de desacoplamiento seguro (`enablePushNotifications = false`).
7. ✅ **Compilación Exitosa:**
   * `flutter analyze`: 0 errores (Clean).
   * `flutter run` / `flutter build apk`: Ejecutable sin dependencias bloqueantes de Firebase.

---

## 🗺️ 7. Hoja de Ruta Pendiente (Próximos Pasos para el Siguiente Sprint)

Cuando se retome el proyecto, los siguientes módulos a construir son:

1. **Población y Enlace de Vistas con Tablas Supabase:**
   * Vincular los dashboards directamente con las tablas ya creadas en Supabase (`medicamentos`, `lotes`, `inventario_stock`, `dispensaciones`, `pedidos_abastecimiento`, `auditoria_trazabilidad`).
2. **Escaneo GTIN/GS1 y Código de Barras (Módulo 1 y 3):**
   * Integración de `mobile_scanner` para lectura de código de barras físico en cajas y frascos sin requerir internet.
3. **Flujo de Peticiones y Dispensación en Tiempo Real (Supabase Realtime):**
   * Uso de canales `supabase.channel()` / Postgres Changes para que cuando Enfermería presione "Pedido Urgente de Reposición", Farmacia lo vea reflejado al instante en su pantalla de dispensación.
4. **Activación de Notificaciones Push (Firebase FCM):**
   * Incorporar el archivo `google-services.json` en `android/app/`.
   * Reactivar el plugin en `build.gradle.kts` y activar `enablePushNotifications = true` en `NotificationService`.
5. **Validación de Administración a Paciente:**
   * Lectura cruzada: Escaneo de pulsera del paciente + escaneo del medicamento administrado para garantizar trazabilidad de dosis unitaria.
