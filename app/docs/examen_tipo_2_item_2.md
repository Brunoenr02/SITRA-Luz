# EXAMEN PRÁCTICO — TIPO 2

## Ítem 2: Parseo seguro de identificadores y valores monetarios

### Objetivo

Deserializar productos farmacéuticos sin perder precisión cuando el backend
envía identificadores numéricos grandes o montos económicos.

### Implementación realizada

Se agregó `ProductoFarmaceuticoModel`, correspondiente al inventario de
SITRA-Luz. Su método `fromJson` aplica dos reglas:

1. El identificador siempre se guarda como `String`. Cuando llega como número,
   se llama directamente a `toString()` sin convertirlo previamente a `int`,
   `Long` o `double`.
2. El precio se almacena en `precioCentimos` como una cadena de dígitos. Si el
   backend envía unidades monetarias, la parte entera y los decimales se unen
   mediante operaciones de texto; no se realizan cálculos de punto flotante.

El mapper admite dos contratos equivalentes:

```json
{"id": 25, "nombre": "Ibuprofeno", "precio_centimos": 1990}
```

```json
{"id": "MED-25", "nombre": "Ibuprofeno", "precio": "19.90"}
```

En ambos casos, los valores finales son textos exactos:

```text
id = "25" o "MED-25"
precioCentimos = "1990"
```

### Fragmento principal para la evidencia

```dart
final safeId = rawId is String ? rawId : rawId.toString();

final rawCents = json['precio_centimos'];
if (rawCents != null) {
  return _normalizeIntegerText(rawCents.toString());
}

return _decimalTextToCents(rawPrice.toString());
```

La conversión decimal se realiza separando caracteres:

```dart
final wholePart = _removeLeadingZeros(match.group(1)!);
final decimalPart = (match.group(2) ?? '').padRight(2, '0');
return _removeLeadingZeros('$wholePart$decimalPart');
```

### Validaciones incorporadas

- El identificador es obligatorio y no puede quedar vacío.
- El precio es obligatorio.
- `precio_centimos` solo admite dígitos.
- `precio` admite cero, uno o dos decimales.
- Un monto con tres o más decimales produce `FormatException` de manera
  controlada en lugar de introducir un redondeo silencioso.

### Archivos creados

- `lib/features/inventario/domain/entities/producto_farmaceutico_entity.dart`
- `lib/features/inventario/data/models/producto_farmaceutico_model.dart`
- `test/features/inventario/data/models/producto_farmaceutico_model_test.dart`

### Pruebas

Ejecutar desde `app`:

```text
flutter test test/features/inventario/data/models/producto_farmaceutico_model_test.dart
flutter analyze
```

Las pruebas verifican:

- ID numérico grande `9007199254740993` conservado como texto exacto.
- Monto textual grande transformado a céntimos sin pérdida de precisión.
- Céntimos numéricos convertidos a texto.
- Rechazo controlado de montos con más de dos decimales.

### Captura para el PDF

Abrir `producto_farmaceutico_model.dart` y mostrar conjuntamente:

1. La declaración `String id` y `String precioCentimos`.
2. La línea de conversión de `safeId`.
3. Los métodos `_readPriceInCents` y `_decimalTextToCents`.
4. La terminal con las cuatro pruebas aprobadas.

### Explicación técnica breve

Los identificadores no son cantidades sobre las que se realizan cálculos, por
lo que se representan como texto. Así se evita que una plataforma aplique sus
límites numéricos. Los montos tampoco utilizan `double`, porque el punto
flotante binario puede introducir aproximaciones. El precio se conserva como
un número entero de céntimos escrito en texto, permitiendo almacenar cantidades
grandes sin redondeos ni desbordamientos dependientes de la plataforma.
