# SITRA-Luz - Sistema de Trazabilidad de Medicamentos (Clínica La Luz)

## 📋 Examen Práctico U1 - Tipo de Examen 3
**Tema:** Limpiar y validar el dato antes de enviarlo  
**Estudiante:** Anampa Luz (SITRA_LUZ_ANAMPA_ANCCO_SALAS)  
**Curso:** Desarrollo de Aplicaciones Móviles II  

---

## 🛠️ Resumen de Implementación de los 5 Ítems del Examen

### Ítem 1: Muestra del dato del producto post-login (4 pts)
- **Implementación:** Al autenticarse con cualquier usuario (Administrador, Jefatura de Farmacia, Farmacia, Almacén, Enfermería), la aplicación despliega la tarjeta visual `ProductUserDataCard` mostrando explícitamente la entidad cargada: `Nombre del Usuario`, `Correo Registrado`, `Rol Asignado` y `Áreas / Servicios Médicos`.
- **Archivos Afectados:**
  - `app/lib/core/widgets/product_user_data_card.dart` [NUEVO]
  - `app/lib/features/dashboard_admin/presentation/views/admin_dashboard_view.dart`

---

### Ítem 2: Clase pura de limpieza de datos (4 pts)
- **Implementación:** Se construyó la clase `InputSanitizer` exclusivamente en Dart puro (`dart:core`), sin importaciones de UI (`flutter/material`) ni HTTP (`http`, `supabase`).
- **Funcionalidad:**
  - Remueve caracteres de control invisibles (ASCII 0x00-0x1F y 0x7F como `\r`, `\n`, `\t`).
  - Reemplaza múltiples espacios en blanco o tabulaciones consecutivas internas por un solo espacio.
  - Elimina espacios de los bordes inicio/fin (`trim()`).
  - `InputSanitizer.sanitizeEmail()` convierte a minúsculas limpia.
- **Archivo:** `app/lib/core/utils/input_sanitizer.dart` [NUEVO]
- **Imports:** `dart:core` (0 dependencias externas).

---

### Ítem 3: Validación previa a llamadas de red (4 pts)
- **Implementación:** Se creó la clase `AuthInputValidator` y la excepción `ValidationException`. En `AuthViewModel.login(...)`, antes de invocar cualquier llamado al repositorio/red (Supabase), se validan la estructura del correo (debe incluir `@` y dominio válido) y la contraseña (mínimo 6 caracteres). Si falla la comprobación, lanza `ValidationException`, captura el error y **se niega rotundamente a invocar al repositorio**.
- **Archivos Afectados:**
  - `app/lib/core/utils/auth_input_validator.dart` [NUEVO]
  - `app/lib/features/auth/presentation/viewmodels/auth_viewmodel.dart`

---

### Ítem 4: Pruebas unitarias de Login y Carga en Terminal (4 pts)
- **Ejecución:** Pruebas unitarias puras sin red real ni emulador mediante `FakeAuthRepository`.
- **Casos de prueba evaluados:**
  - `(a)` Al arrancar no hay sesión (`currentUser == null`, estado `AuthStateUnauthenticated`).
  - `(b)` Login correcto con entidad cargada (`UserEntity` cargada correctamente).
  - `(c)` Login rechazado: error devuelto en 1 intento sin reintentos secundarios (`loginCallCount == 1`).
- **Comando de ejecución:**
  ```bash
  flutter test test/exam_item4_login_test.dart
  ```
- **Archivo:** `app/test/exam_item4_login_test.dart` [NUEVO]

---

### Ítem 5: Pruebas unitarias de Limpieza y Rechazo Local (4 pts)
- **Casos de prueba evaluados:**
  - `(a)` Cadena con espacios, tabuladores y saltos de línea (`"   \t \r\n ADMIN@SITRALUZ.PE \t "`) se desinfecta a `"admin@sitraluz.pe"`.
  - `(b)` Entrada inválida (correo sin `@` / clave corta) falla en validación previa y deja las invocaciones al repositorio en exactamente **CERO (0 llamadas)**.
- **Comando de ejecución:**
  ```bash
  flutter test test/exam_item5_sanitizer_validator_test.dart
  ```
- **Archivo:** `app/test/exam_item5_sanitizer_validator_test.dart` [NUEVO]

---

## 🧪 Ejecución Completa de Pruebas Unitarias en Terminal

```bash
cd app
flutter test test/exam_item4_login_test.dart test/exam_item5_sanitizer_validator_test.dart
```

**Resultado:**
```text
00:00 +0: loading test/exam_item4_login_test.dart
✅ [TEST (a) PASADO]: Al arrancar no hay sesión activa. currentUser = null.
✅ [TEST (b) PASADO]: Login exitoso. Entidad cargada: UserEntity(uid: usr-exam-001, nombre: Lic. Ana Morales, rol: ADMINISTRADOR)
✅ [TEST (c) PASADO]: Login rechazado correctamente. Invocaciones al repositorio = 1 (Sin segundo intento).
✅ [TEST 5(a) PASADO]: Cadena sucia: "  	 \r\n ADMIN@SITRALUZ.PE  	  " => Cadena limpia: "admin@sitraluz.pe"
✅ [TEST 5(b) PASADO]: Validación falló localmente. Invocaciones al repositorio de red = 0. Error mostrado: "Formato de correo inválido...".
00:00 +5: All tests passed!
```
