# SITRA-Luz

Aplicación móvil de trazabilidad y gestión de farmacia para la Clínica La Luz.
El cliente Flutter se encuentra en la carpeta `app`.

## Examen práctico — Tipo 2

### Ítem 1: persistencia local y auto-login

- Se guarda el identificador y el perfil del usuario con `SharedPreferences`.
- La sesión se restaura antes de crear el enrutador de la aplicación.
- Un usuario con sesión guardada ingresa directamente al dashboard de su rol.
- El logout elimina la información persistida.
- El JSON local se lee validando tipos y tolerando contenido corrupto.

Archivos y secciones afectados:

- `app/lib/features/auth/data/datasources/auth_local_datasource.dart`
- `app/lib/features/auth/data/repositories/auth_repository_impl.dart`
- `app/lib/features/auth/presentation/viewmodels/auth_viewmodel.dart`
- `app/lib/core/routes/app_router.dart`
- `app/lib/main.dart`
- `app/test/features/auth/data/datasources/auth_local_datasource_test.dart`
- `app/test/widget_test.dart`

El desarrollo paso a paso y la guía de evidencias están en
[`app/docs/examen_tipo_2_item_1.md`](app/docs/examen_tipo_2_item_1.md).

### Ítem 2: identificadores y valores monetarios seguros

- Nuevo modelo `ProductoFarmaceuticoModel`, correspondiente al inventario.
- Identificadores almacenados estrictamente como texto.
- Precios almacenados como céntimos textuales exactos, sin `double`.
- Validación controlada de formatos monetarios inválidos.

Archivos y secciones incorporados:

- `app/lib/features/inventario/domain/entities/producto_farmaceutico_entity.dart`
- `app/lib/features/inventario/data/models/producto_farmaceutico_model.dart`
- `app/test/features/inventario/data/models/producto_farmaceutico_model_test.dart`

El detalle técnico está en
[`app/docs/examen_tipo_2_item_2.md`](app/docs/examen_tipo_2_item_2.md).

### Ítem 3: tolerancia a nulos y claves no previstas

- Los campos opcionales reciben valores seguros ante `null`, ausencia o tipo
  inesperado.
- Las claves adicionales del backend se ignoran silenciosamente.
- Se agregaron pruebas específicas para los tres escenarios.

El desarrollo está documentado en
[`app/docs/examen_tipo_2_item_3.md`](app/docs/examen_tipo_2_item_3.md).

### Ítem 4: pruebas de lectura y flujo de carga

- Tres pruebas unitarias sin emulador ni conexión.
- Hidratación íntegra, estado de éxito y estado de error sin reintentos.
- ViewModel y estados de carga para datos listos para la interfaz.

La guía de ejecución está en
[`app/docs/examen_tipo_2_item_4.md`](app/docs/examen_tipo_2_item_4.md).
