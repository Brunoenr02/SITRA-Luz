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
* **Enrutamiento:** `GoRouter` con guardias de seguridad basadas en autenticación y rol.
* **Diseño / UI:** Material 3 con tema corporativo médico (`AppTheme`, `AppColors`) y tipografía `GoogleFonts.inter`.
* **Backend Cloud:**
  * **Firebase Authentication:** Autenticación por correo y contraseña.
  * **Cloud Firestore:** Base de datos NoSQL para perfiles de usuario, roles, fichas de pedido y auditoría.
  * **Firebase Storage / FCM:** Para comprobantes/fotos y notificaciones push.

### 4.2 Configuración Firebase y Android
* **Proyecto Firebase Cloud:** `sitra-luz-clinica` (ID: `sitra-luz-clinica`, Número: `998997655822`).
* **Android Application ID / Namespace:** `ap.sitra.luz.clinica`.
* **Archivo de configuración vinculado:** `sitra_luz_app/android/app/google-services.json`.
* **Kotlin Gradle Plugin:** Versión `2.3.0`.
* **Android Gradle Plugin (AGP):** `8.9.1`.
* **Google Services Plugin:** `4.4.2`.
* **Compatibilidad Java / Kotlin:** `JVM 11` sincronizado para tareas Java y Kotlin.

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

1. ✅ **Creación del proyecto base:** Estructurado en `sitra_luz_app` con dependencias modernas (`firebase_core`, `firebase_auth`, `cloud_firestore`, `provider`, `go_router`, `google_fonts`).
2. ✅ **Diseño del Sistema:** Implementado `AppTheme` y `AppColors` con identidad visual médica propia de la clínica.
3. ✅ **Capa de Dominio y Datos:** Entidades, repositorios y modelos mapeados listos para Firestore.
4. ✅ **Seguridad y Enrutamiento:** `GoRouter` configurado con guardias que impiden acceder a dashboards sin sesión y redirigen automáticamente a la pantalla del rol correspondiente tras autenticar.
5. ✅ **5 Pantallas de Roles Completadas:**
   * `/admin`: Métricas de auditoría, control de accesos, sincronización Dialyma.
   * `/jefatura`: Alertas críticas FEFO (<30d, <90d), aprobaciones de alto costo.
   * `/farmacia`: Cola de dispensación de recetas y pedidos de piso pendientes.
   * `/almacen`: Control de guías de remisión, monitoreo de cadena de frío (3.8 °C).
   * `/enfermeria`: Botiquín del servicio (UCI Adultos), botón de pedido urgente de reposición.
6. ✅ **Sincronización Firebase Android:**
   * Archivo `google-services.json` verificado e integrado en `android/app/`.
   * Gradle adaptado con `applicationId = "ap.sitra.luz.clinica"`, plugin `com.google.gms.google-services 4.4.2` y Kotlin `2.3.0`.
7. ✅ **Compilación Exitosa del APK:**
   * `flutter analyze`: 0 errores.
   * `flutter test`: Pruebas de widget aprobadas.
   * `flutter build apk --debug`: **Generado exitosamente** en `sitra_luz_app/build/app/outputs/flutter-apk/app-debug.apk`.

---

## 🗺️ 7. Hoja de Ruta Pendiente (Próximos Pasos para el Siguiente Sprint)

Cuando se retome el proyecto en este o en otro entorno, los siguientes módulos a construir son:

1. **Estructura de Base de Datos Firestore (Colecciones operativas):**
   * `/medicamentos`: Catálogo de principios activos, formas farmacéuticas, stock mínimo.
   * `/lotes`: Registro de lote, fecha de vencimiento, stock actual, semáforo FEFO (verde, ámbar, rojo), condición de almacenamiento (temperatura).
   * `/fichas_pedido`: Solicitudes de enfermería a farmacia (`Borrador` → `Enviado` → `En preparación` → `Listo para recoger` → `Entregado`).
   * `/movimientos_kardex`: Auditoría inmutable de cada entrada, salida, transferencia o administración a paciente.
2. **Escaneo GTIN/GS1 y Código de Barras (Módulo 1 y 3):**
   * Integración de `mobile_scanner` para lectura de código de barras físico en cajas y frascos sin requerir internet.
3. **Flujo de Peticiones y Dispensación en Tiempo Real:**
   * Uso de `Firestore.snapshots()` para que cuando Enfermería presione "Pedido Urgente de Reposición", Farmacia lo vea reflejado al instante en su pantalla de dispensación.
4. **Validación de Administración a Paciente:**
   * Lectura cruzada: Escaneo de pulsera del paciente + escaneo del medicamento administrado para garantizar trazabilidad de dosis unitaria.
