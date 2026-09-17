# Validación del problema — SITRA-Luz

## Guion de entrevista aplicado

Se utilizó el guion de 6 preguntas del taller SI988. Las entrevistas se realizaron de forma presencial y por videollamada entre el 01 y 03 de septiembre de 2026. **No se describió la solución antes de la pregunta 6.**

> **Contexto importante:** La clínica ya opera con un sistema de escritorio llamado **Dialyma**, que registra la entrada de medicamentos en Almacén y la salida por venta en Caja de Farmacia. Sin embargo, **todo el flujo interno** —desde que un medicamento sale de Almacén para dar stock a Farmacia, y luego cuando SOP, Emergencias o Coche de Paros solicitan medicamentos para procedimientos— **se gestiona con fichas en papel**, peticiones verbales y esperas presenciales. Ese proceso interno es el que SITRA-Luz busca digitalizar y agilizar.

---

## Registro de entrevistas

| # | Entrevistado (perfil, sin nombre) | Problema confirmado | Qué hace hoy | Costo declarado | ¿Usaría la solución? | **Cita textual relevante** |
|---|---|---|---|---|---|---|
| 1 | Técnica de farmacia, 6 años de experiencia en clínica privada mediana (50 camas), Tacna | **Sí** — confirmó que las peticiones internas de SOP y Emergencias se hacen en papel y generan demoras y pérdida de trazabilidad | Recibe fichas de petición en papel de las enfermeras de SOP y Emergencias. Busca los medicamentos en los estantes, arma el carrito y avisa verbalmente que está listo. Si hay dudas sobre un pedido pasado, busca la ficha en un archivador físico | ~45 minutos por cada carrito que arma; 3-4 veces por día. Las fichas de papel a veces se extravían y no queda registro de quién pidió qué | Sí, lo usaría para recibir los pedidos digitalmente y que quede registro automático | *«Las enfermeras bajan con un papel y me dicen "necesito esto para el doctor tal". Yo armo el carrito, pero si después falta algo y me preguntan quién se lo llevó, tengo que buscar entre cientos de fichas. A veces ni se encuentra.»* |
| 2 | Jefa de farmacia, 10 años de experiencia, clínica privada mediana, Tacna | **Sí** — confirmó que Dialyma solo registra entrada y venta en caja, pero no rastrea el movimiento interno hacia las áreas clínicas | Usa Dialyma para ver lo que entró por almacén y lo que se vendió por caja. El stock que se transfiere internamente a SOP, Emergencias y Coche de Paros lo controla con un cuaderno aparte. No tiene forma de auditar diferencias entre lo que Dialyma dice y lo que realmente hay | Detecta diferencias de inventario de S/ 800 a S/ 1,500 mensuales entre lo que Dialyma marca y el conteo físico. Sin registro digital de los movimientos internos, no puede identificar la causa | Sí, especialmente si complementa a Dialyma cubriendo el flujo interno que hoy no está digitalizado | *«Dialyma me dice cuánto entró y cuánto se vendió por caja, pero todo lo que se mueve por dentro de la clínica —lo que le doy a SOP, a Emergencias, al Coche de Paros— eso no existe en ningún sistema. Lo tengo en un cuaderno. Y cuando no cuadra el inventario, no puedo demostrar a dónde se fue.»* |
| 3 | Enfermero de SOP (Sala de Operaciones), 3 años de experiencia, clínica privada mediana, Tacna | **Sí** — confirmó que el proceso de petición de medicamentos para cirugías es lento, en papel, y genera esperas críticas | Llena una ficha de petición a mano con los medicamentos que necesita para la cirugía (según indicación del cirujano). Baja a farmacia, entrega la ficha y espera a que armen el carrito. A veces tiene que volver a subir y bajar si falta algo | ~30-45 minutos por pedido. En cirugías de urgencia ha esperado hasta 20 minutos porque farmacia no tenía preparado el carrito | Sí, sobre todo si puede enviar la petición desde la tablet y le avisan cuando el carrito está listo sin tener que bajar y esperar | *«Antes de cada cirugía tengo que bajar a farmacia con la ficha de petición. Me toca esperar ahí parado mientras arman el carrito. Si falta algo tengo que subir a preguntarle al doctor si acepta un sustituto y volver a bajar. En una emergencia eso son minutos que importan.»* |
| 4 | Auxiliar de almacén, 4 años de experiencia, clínica mediana, Tacna | **Sí** — confirmó que la transferencia de stock de Almacén a Farmacia no queda registrada digitalmente | Registra la entrada de medicamentos del proveedor en Dialyma. Cuando Farmacia le pide stock, saca los medicamentos del estante y los entrega físicamente, anotando en un cuaderno lo que sacó. En Dialyma esos medicamentos siguen figurando como "en almacén" hasta que se venden por caja | La descuadra entre Dialyma y el stock real aparece en cada inventario mensual. Dedica ~2 horas mensuales a cuadrar manualmente las diferencias | Sí, si puede registrar la salida interna desde el celular en el momento que entrega los medicamentos a farmacia | *«Yo ingreso todo al Dialyma cuando llega del proveedor, pero cuando farmacia me pide 20 cajas de suero, yo se las doy y lo apunto en mi cuaderno. En Dialyma esas cajas siguen apareciendo como si las tuviera yo. Recién desaparecen cuando las venden por caja. Entonces cada vez que hacen inventario, nada cuadra.»* |
| 5 | Enfermera de Emergencias, 5 años de experiencia, clínica privada mediana, Tacna | **Sí** — confirmó que las peticiones de medicamentos para emergencias son urgentes y el proceso en papel genera retrasos peligrosos | Llena la ficha de petición a mano en medio de la atención, manda a un técnico a farmacia a entregar la ficha y esperar. En emergencias nocturnas, a veces farmacia tarda más porque hay menos personal | En una guardia nocturna esperó ~25 minutos por un carrito de medicamentos que necesitaba para una emergencia. Las fichas de petición a veces se llenan incompletas por la urgencia y luego no sirven como registro | Sí, si puede hacer la solicitud rápido desde la tablet sin tener que llenar toda la ficha a mano | *«En emergencia todo es contra el reloj. No puedo sentarme a llenar una ficha bonita con todos los datos. A veces pongo solo lo mínimo y mando al técnico corriendo a farmacia. Después cuando piden auditoría, la ficha está incompleta y queda como que yo no la llené bien, pero es que estaba atendiendo al paciente.»* |

---

## Veredicto de validación

| Métrica | Resultado |
|---|---|
| Entrevistas realizadas | **5 de 5** |
| Confirmaron el problema con un **hecho concreto** (no opinión) | **5 de 5** — todos describieron situaciones reales y específicas del flujo interno de la clínica |
| Umbral mínimo requerido (≥ 3 de 5) | ✅ **CUMPLIDO** |

### Hallazgos clave

1. **Dialyma cubre solo los extremos** (entrada por almacén y venta por caja), pero **no registra el movimiento interno** de medicamentos entre áreas. Ese vacío genera descuadres de inventario imposibles de explicar.
2. **Las fichas de petición en papel** son el cuello de botella operativo: se llenan a mano, se extravían, se llenan incompletas en urgencias y no sirven como registro auditable.
3. **Las esperas presenciales en farmacia** para armar carritos consumen entre 30 y 45 minutos por pedido, y en emergencias esos minutos son críticos.
4. **Ningún entrevistado** tiene un sistema digital para el flujo interno. Todos usan cuadernos, fichas de papel o comunicación verbal.
5. **Los 5 entrevistados** usarían una solución móvil que permita enviar peticiones digitales y recibir notificación cuando el carrito está listo.

### Decisión

✅ **El problema está validado.** Se procede con la propuesta de valor definida en el Lean Canvas: digitalizar y agilizar el flujo interno de medicamentos que Dialyma no cubre. No se requiere reformulación.
