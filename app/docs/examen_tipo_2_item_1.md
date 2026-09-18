# EXAMEN PRÁCTICO — TIPO 2

## Ítem 1: Persistencia local y auto-login

### Objetivo

Mantener la sesión después de cerrar forzosamente la aplicación y, al abrirla
nuevamente, ingresar directamente al dashboard correspondiente al rol del
usuario sin volver a mostrar el formulario de login.

### Implementación realizada

1. Se utilizó `SharedPreferences`, dependencia ya incluida en el proyecto, como
   almacenamiento local persistente.
2. Se creó `AuthLocalDataSource`, responsable de guardar:
   - `auth_user_id`: identificador único del usuario autenticado.
   - `auth_user_profile`: perfil mínimo serializado como JSON.
3. Después de un login exitoso, `AuthRepositoryImpl.login()` guarda la sesión
   local antes de devolver el usuario a la interfaz.
4. Durante el arranque, `main()` espera a que `AuthViewModel.initialize()` lea
   la sesión. El router inicia directamente en el dashboard asociado al rol.
5. Al cerrar sesión se eliminan tanto la sesión remota como los datos locales,
   incluso si el cierre remoto produce un error.
6. La lectura del JSON valida tipos y captura datos corruptos. Si el contenido
   no es válido, devuelve `null` y la app muestra el login sin cerrarse.

### Archivos afectados

- `lib/features/auth/data/datasources/auth_local_datasource.dart`: guardado,
  lectura segura y eliminación de la sesión local.
- `lib/features/auth/data/repositories/auth_repository_impl.dart`: integra la
  persistencia con login, restauración y logout.
- `lib/features/auth/presentation/viewmodels/auth_viewmodel.dart`: expone la
  inicialización de sesión para esperarla durante el arranque.
- `lib/main.dart`: crea `SharedPreferences` y restaura la sesión antes del router.
- `lib/core/routes/app_router.dart`: selecciona la ruta inicial según el usuario.
- `test/features/auth/data/datasources/auth_local_datasource_test.dart`: prueba
  el guardado, el JSON corrupto y la eliminación.
- `test/widget_test.dart`: inicializa explícitamente el ViewModel en la prueba.

### Fragmentos clave para la evidencia

Guardado del identificador y perfil:

```dart
await _preferences.setString(_userIdKey, user.uid);
await _preferences.setString(_userProfileKey, profile);
```

Lectura al iniciar:

```dart
final authViewModel = AuthViewModel(repository: authRepository);
await authViewModel.initialize();
final router = createRouter(authViewModel);
```

Ruta inicial autenticada:

```dart
initialLocation: initialUser == null
    ? AppRoutes.login
    : AppRoutes.routeForRole(initialUser.rol),
```

### Pruebas ejecutadas

Ejecutar desde la carpeta `app`:

```text
flutter analyze
flutter test
```

### Capturas requeridas para el PDF

1. **Sesión iniciada:** dashboard mostrando el nombre y los datos del usuario.
2. **Cierre forzado:** terminal con el comando que detiene la app o pantalla de
   información de Android después de pulsar “Forzar detención”.
3. **Reapertura:** dashboard visible directamente, sin ingresar credenciales.
4. **Código:** métodos `saveSession`, `readSession` y llamada a `initialize()`.
5. **Terminal:** resultado exitoso de `flutter analyze` y `flutter test`.

### Procedimiento de demostración

1. Ejecutar la app e iniciar sesión con un usuario válido.
2. Confirmar que se muestra su dashboard y sus datos.
3. Cerrar la app desde aplicaciones recientes o usar “Forzar detención”.
4. Abrir nuevamente SITRA-Luz desde el ícono del emulador.
5. Verificar que ingresa directamente al mismo dashboard.
6. Pulsar cerrar sesión y comprobar que el siguiente arranque muestra el login.

### Explicación técnica breve

`SharedPreferences` conserva pares clave-valor aunque el proceso de Flutter sea
destruido. El perfil se serializa a JSON y el identificador se guarda de forma
independiente. Antes de construir `GoRouter`, el ViewModel reconstruye un
`UserEntity` a partir de esos datos. La lectura valida el tipo de cada campo y
captura `FormatException`; por ello, un valor incompleto o corrupto no provoca
el cierre de la aplicación. El logout limpia las claves locales para impedir que
una sesión terminada vuelva a restaurarse.

> Las capturas deben obtenerse en la estación donde se ejecuta el emulador e
> insertarse en el PDF final como evidencia real.
