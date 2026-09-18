# EXAMEN PRÁCTICO — TIPO 2

## Ítem 4: Tres pruebas de lectura y parseo en terminal

### Objetivo

Validar sin emulador ni conexión que el JSON hidrata la entidad, que una carga
correcta deja datos listos para renderizar y que un payload inválido termina en
error sin ejecutar reintentos automáticos.

### Componentes agregados

- `ProductoFarmaceuticoRepository`: contrato que entrega una entidad.
- `ProductoCargaState`: estados inicial, cargando, éxito y error.
- `ProductoCargaViewModel`: realiza un único intento y expone el estado final.
- `_JsonProductoRepository`: repositorio falso privado de las pruebas; procesa
  mapas locales y cuenta cuántas veces fue llamado.

No se usa Supabase, Firebase, HTTP, emulador ni otra fuente externa.

### Prueba A: carga de entidad

Construye un payload correcto con todos los atributos y verifica uno por uno:

- ID grande conservado como texto.
- Nombre, descripción y laboratorio íntegros.
- Booleano y lista correctamente hidratados.
- Precio convertido exactamente a céntimos.

### Prueba B: estado exitoso

El repositorio falso devuelve el payload correcto. Después de
`cargarProducto()`, se comprueba que:

- El estado final sea `ProductoCargaSuccess`.
- El estado contenga el producto listo para la interfaz.
- El repositorio haya recibido exactamente una llamada.

### Prueba C: carga fallida sin reintentos

El repositorio recibe un payload sin identificador y con precio inválido. Se
comprueba que:

- El estado final sea `ProductoCargaError`.
- Exista un mensaje de error controlado.
- El contador permanezca en una llamada incluso después de vaciar la cola de
  microtareas, demostrando que no existe un reintento automático.

### Comando para la evidencia

Cerrar antes cualquier `flutter run` con la tecla `q`. Desde la carpeta `app`,
ejecutar:

```text
flutter test test/features/inventario/producto_parseo_flujo_test.dart -r expanded
```

La terminal debe mostrar exactamente las tres pruebas:

```text
a) Carga de entidad: hidrata todos los atributos íntegros
b) Estado exitoso: deja datos listos para renderizar
c) Carga fallida: finaliza en error sin reintentos
All tests passed!
```

### Evidencia para el PDF

Tomar una captura completa donde sean visibles:

1. La ruta `C:\QWERTY\SITRA-Luz\app`.
2. El comando ejecutado.
3. Los nombres completos de las tres pruebas.
4. El mensaje final `All tests passed!`.

Como respaldo técnico puede incluirse una segunda captura del archivo
`producto_parseo_flujo_test.dart`, especialmente las aserciones del estado de
éxito, del estado de error y `numeroDeLlamadas == 1`.
