# SITRA-Luz

Aplicación móvil para la trazabilidad y gestión de farmacia de la Clínica La Luz.

## Examen práctico — Tipo 2

### Ítem 1: persistencia local y auto-login

Cambios implementados:

- Persistencia del identificador y perfil del usuario mediante
  `SharedPreferences`.
- Restauración de la sesión antes de construir el enrutador.
- Apertura directa del dashboard correspondiente al rol autenticado.
- Eliminación de la sesión persistida durante el logout.
- Lectura tolerante a JSON local corrupto o con tipos inválidos.
- Pruebas automatizadas de guardado, restauración, corrupción y eliminación.

Archivos principales afectados:

- `lib/features/auth/data/datasources/auth_local_datasource.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/presentation/viewmodels/auth_viewmodel.dart`
- `lib/core/routes/app_router.dart`
- `lib/main.dart`
- `test/features/auth/data/datasources/auth_local_datasource_test.dart`
- `test/widget_test.dart`

La explicación paso a paso y la guía de capturas están en
[`docs/examen_tipo_2_item_1.md`](docs/examen_tipo_2_item_1.md).

### Ítem 2: identificadores y valores monetarios seguros

- Se agregó el modelo de inventario `ProductoFarmaceuticoModel`.
- Los identificadores se almacenan siempre como `String`.
- Los precios se almacenan como céntimos en texto exacto, sin usar `double`.
- Se validan formatos incorrectos mediante `FormatException`.
- Se agregaron cuatro pruebas de precisión y validación.

Archivos incorporados:

- `lib/features/inventario/domain/entities/producto_farmaceutico_entity.dart`
- `lib/features/inventario/data/models/producto_farmaceutico_model.dart`
- `test/features/inventario/data/models/producto_farmaceutico_model_test.dart`

La evidencia está descrita en
[`docs/examen_tipo_2_item_2.md`](docs/examen_tipo_2_item_2.md).

### Ítem 3: tolerancia a nulos y claves no previstas

- Valores predeterminados para cadenas, booleanos y listas opcionales.
- Validación de tipos antes de asignar los valores del JSON.
- Claves adicionales ignoradas silenciosamente por el mapper manual.
- Pruebas para campos nulos, omitidos y desconocidos.

Se actualizaron el modelo, la entidad y las pruebas del inventario. El detalle
está en [`docs/examen_tipo_2_item_3.md`](docs/examen_tipo_2_item_3.md).

### Ítem 4: pruebas de lectura y flujo de carga

- Prueba de hidratación completa de la entidad.
- Prueba del estado final de éxito con datos listos para renderizar.
- Prueba del estado de error y verificación de una sola llamada, sin reintentos.
- Repositorio falso local, sin emulador ni conexión.

El comando y la evidencia esperada están en
[`docs/examen_tipo_2_item_4.md`](docs/examen_tipo_2_item_4.md).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
