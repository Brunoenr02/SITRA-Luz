# EXAMEN PRÁCTICO — TIPO 2

## Ítem 3: Tolerancia a valores nulos y claves no previstas

### Objetivo

Evitar que un payload incompleto, con campos opcionales en `null` o con nuevas
claves agregadas por el backend provoque errores de tipo o cierres de la app.

### Implementación realizada

Se amplió el mismo método `ProductoFarmaceuticoModel.fromJson` utilizado en el
ítem 2. Los campos opcionales se leen mediante funciones seguras:

```dart
nombre: _readOptionalString(json['nombre']),
descripcion: _readOptionalString(json['descripcion']),
laboratorio: _readOptionalString(json['laboratorio']),
requiereReceta: _readOptionalBool(json['requiere_receta']),
etiquetas: _readOptionalStringList(json['etiquetas']),
```

Los valores predeterminados son:

| Tipo esperado | Valor seguro |
|---|---|
| `String` | `''` |
| `bool` | `false` |
| `List<String>` | `const []` |

### Funciones de lectura tolerante

```dart
static String _readOptionalString(dynamic value) {
  return value is String ? value : '';
}

static bool _readOptionalBool(dynamic value) {
  return value is bool ? value : false;
}

static List<String> _readOptionalStringList(dynamic value) {
  if (value is! List) return const [];
  return List<String>.unmodifiable(value.whereType<String>());
}
```

Estas funciones cubren tres situaciones con el mismo valor predeterminado:

- La clave no existe: `json['clave']` devuelve `null`.
- La clave existe con valor `null`.
- La clave contiene un tipo inesperado.

### Claves adicionales

El mapper es manual y construye el modelo leyendo exclusivamente las claves que
conoce. No recorre el mapa ni realiza una conversión global; por eso claves como
`campo_nuevo_del_backend`, `auditoria` o `valor_desconocido` permanecen en el
mapa de entrada, pero se descartan silenciosamente al crear el modelo.

```dart
// Solo se leen claves conocidas; cualquier clave extra del JSON
// se ignora silenciosamente al no participar en este constructor.
return ProductoFarmaceuticoModel(
  id: safeId,
  nombre: _readOptionalString(json['nombre']),
  // ...únicamente campos declarados por el modelo
);
```

### Pruebas agregadas

1. Todos los campos opcionales enviados como `null` reciben valores seguros.
2. Todos los campos opcionales omitidos reciben los mismos valores seguros.
3. Un payload con tres claves desconocidas se procesa sin lanzar excepciones.

Ejecutar desde la carpeta `app`:

```text
flutter test test/features/inventario/data/models/producto_farmaceutico_model_test.dart -r expanded
flutter analyze
```

### Evidencia para el PDF

Tomar una captura de `producto_farmaceutico_model.dart` donde se vean:

1. Las asignaciones con `_readOptionalString`, `_readOptionalBool` y
   `_readOptionalStringList`.
2. Las tres funciones y sus valores `''`, `false` y `const []`.
3. El comentario que explica que las claves adicionales se ignoran.

Como evidencia complementaria, capturar la terminal mostrando aprobadas las
pruebas de campos nulos, campos omitidos y claves adicionales.

### Explicación técnica breve

No se emplean conversiones directas como `json['nombre'] as String`, porque
fallarían ante `null` o un tipo distinto. Cada lector comprueba el tipo antes de
devolver el valor. El mapper manual actúa además como una lista permitida de
campos: solo transfiere al modelo las propiedades declaradas y descarta el resto
sin necesidad de lanzar una excepción.
