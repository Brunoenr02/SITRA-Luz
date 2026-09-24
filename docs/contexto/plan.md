# SITRA-Luz — Plan de Análisis y Preguntas Críticas

## Contexto General

**SITRA-Luz** es una aplicación para la gestión interna de medicamentos de una clínica. Está siendo desarrollada con Flutter (frontend), una API central y un modelo de datos híbrido (MSSQL + NoSQL). Ya existe un Sprint 1 en curso con tareas técnicas de cimientos.

El módulo que se analiza aquí es el de **Fichas/Formularios de Pedido**, que es el núcleo de la Épica C — Peticiones y Dispensación.

---

## 🔴 Preguntas Abiertas — Requieren tu Respuesta

---

### 1. FICHAS / FORMULARIOS — Estructura y Tipos

> [!IMPORTANT]
> Solo mencionas **dos tipos de fichas** por ahora. Necesito saber si habrá más.

- **1.1** ¿La **Ficha General de Pedido** (con nombre del paciente, fecha, procedencia, tipo, diagnóstico/procedimiento, receta) se usa para *todas* las áreas excepto Neonatología, o solo para algunas específicas (Emergencia, Hospitalización)?

Por el momento tengo esos formatos, pero preguntare a la jefa de farmacia quien es el cliente. Igualmente esos son los datos basicos de las fichas solo que quiero agregar al doctor a cargo y el tecnico asignado a recoger el paquete de la ficha
- **1.2** ¿Habrá en el futuro fichas para otras áreas especiales como **UCI, Centro Quirúrgico, Sala de Partos** u otras? ¿O el sistema debe diseñarse desde ahora para soportar más tipos de fichas?
tal vez pero como te indique normalmente es una ficha y ahi tiene para marcar que opcion de tipo es.
- **1.3** En la Ficha General, el campo **"procedencia"** tiene las opciones: `emergencia`, `hospit` (hospitalización) y `otro`. ¿Qué contempla el campo `otro`? ¿El usuario escribe libremente o elige de una lista predefinida? Sip, cuando no esta definido.
- **1.4** El campo **"diagnóstico o procedimiento"** — ¿es texto libre, o debe buscar en un catálogo de diagnósticos (ej. CIE-10) o procedimientos estándar de la clínica?
Por ahora texto libre solo como indicacion.
---

### 2. CAMPO "TIPO" — Financiamiento / Seguro

> [!IMPORTANT]
> Es un campo crítico porque de él depende la trazabilidad económica del medicamento.

- **2.1** La lista de tipos es: `Particular, Convenio, EPS, SOAT, SCTR, Electrosur, SaludPol, Rimac, Mapfre, La Positiva, Sanitas, Pacífico, u Otro`. ¿Esta lista es **fija y cerrada** o puede el administrador agregar más seguros/convenios en el futuro?
Podra agregar o eliminar, como puede habilitar o desahabilitar.
- **2.2** ¿El tipo de financiamiento afecta en algo el flujo de despacho? Por ejemplo: ¿un medicamento de tipo "SOAT" requiere una aprobación adicional antes de dispensarse, comparado con "Particular"? La verdad que todo depende si tienen los insumos/medicamentos en farmacia, y a que medicamento afecta ese tipo, normalmente es un descuento u otra cosa pero de eso no nos preocupamos, nosotros gestionaremos el stock de los dispositivos medicos, insumos medicamentos, etc, que salen de farmacia hacia las demas areas, tmabien cuanto se queda en almacen y poder agilizar como el pedido de traslado del stock de almacen a farmacia, cuando en farmacia se acabe el stock, pero se sabe que en almacen hay mas y no es 0. Gestionamos donde esta el stock fisico.
- **2.3** ¿Se necesita registrar un **número de póliza, número de autorización o código de atención** cuando el tipo es un seguro (Rimac, Mapfre, etc.)?
no necesariamente.
---

### 3. RECETA DE MEDICAMENTOS — Contenido y Lógica

> [!WARNING]
> Este es el corazón funcional del formulario. Los detalles aquí impactan directamente el diseño de la BD y la lógica de stock.

- **3.1** En la receta, ¿qué campos lleva **cada medicamento/dispositivo médico**? ¿Solo nombre y cantidad, o también dosis, vía de administración, frecuencia, número de días?
nombre y cantidad, porque no estamos dando una receta medico, estamos indicando cuanto de que medicamento sale de farmacia hacia otras areas.
- **3.2** La receta, ¿puede mezclar **medicamentos y dispositivos médicos** en la misma lista, o van en secciones separadas?
Si. pero seria bueno separarlas en dos tablas por ejemplo, al momento de su visualizacion una vez guardado, y tambien es mas ordenado al ver para exportar e imprimir.
- **3.3** ¿El farmacéutico/personal de farmacia puede **modificar la cantidad** a dispensar si el stock no alcanza para lo recetado? ¿O despacha todo o nada?
Si, puede modificar e indicar si el pedido esta completo o que es lo que se tiene al momento de indicar que ya esta listo el pedido para recoger. Puede tambien tener una columna de observacion, agregando detalles.
- **3.4** ¿La receta queda **"abierta"** para completarse en varios turnos (ej. un medicamento hoy, otro mañana), o es una dispensación única?
ya dijimos que no somos recetas solo damos los medicamentos.
- **3.5** ¿Se necesita guardar la **receta física** (foto) o es 100% digital desde el inicio?
digital desde el inicio, la trazabilidad es digital.
---

### 4. FICHA DE NEONATOLOGÍA — Particularidades

> [!NOTE]
> Esta ficha tiene una lógica distinta porque el paciente es el recién nacido pero la identificación principal es la madre.

- **4.1** El campo **"apellidos del recién nacido"** — ¿en el momento del pedido el bebé ya tiene nombre registrado, o en la mayoría de casos aún no? ¿Cómo se identifica si no tiene nombre aún (ej. "RN de [apellido materno]")? En el caso de la clinica solo piden los apellidos.
- **4.2** **"Tipo de parto"** — ¿qué valores acepta? ¿Eutócico, distócico, cesárea, u otros? ¿Afecta el flujo de medicamentos? No, solo es un detalle que se queda en esa ficha.
- **4.3** La tabla de **Insumo / Cantidad** en Neonatología — ¿es distinta a la receta general? ¿Los insumos de neonatología vienen de un catálogo propio diferente al catálogo general de medicamentos? Es un catalogo general, de ahi tu seleccionas que insumos quieres, y por eso pensamos en pquetes pre establecido editables para quitar cosas o aumentar, y solo es descripcion y cantidad.
- **4.4** ¿El campo **"habitación"** es un número libre o se selecciona de una lista de habitaciones registradas en el sistema? Solo se llena, es para la ficha no depende de nada mas. Es opcional el dato.

---

### 5. CAMPO "QUIÉN RECOGE" — Trazabilidad y Seguridad

> [!IMPORTANT]
> Este campo tiene implicaciones legales y de auditoría. Es crítico definirlo bien.

- **5.1** **¿Quién puede recoger los medicamentos?** ¿Solo personal de la clínica (enfermera, técnico), o también puede ser el propio paciente/familiar? ¿O ambos casos? Enfermera o tecnico, por eso a la ficha esta registrado el que esta asignado a recgoer o pidio, y el doctor a cargo del area o paciente.
- **5.2** ¿La persona que recoge **debe estar registrada en el sistema** previamente (con usuario y contraseña), o solo se escribe su nombre en texto libre? Obviamente.
- **5.3** ¿Se requiere alguna **firma digital o confirmación** de la persona que recoge para que quede constancia legal? Que lo recogio, pues si, con un boton nomas.
- **5.4** ¿Este campo es el mismo que el que en HU-13 se llama "registro obligatorio de usuario"? ¿O son dos datos distintos?
El campo quien recoge es para la ficha, el registro obligatorio de usuario creo que se refiere al registro de estos en el sistema para poder asignarlos, creo yo que como separaremos por area el modulod e registro de pedido de farmacia, ahi solo listaremos a los enfermer(a)os/tecnicos que en su registro aparezcan en esa area, y como se rotan se podra asignar a mas de 1 area a una persona.
---

### 6. FLUJO DE APROBACIÓN Y ESTADOS DE LA FICHA

> [!CAUTION]
> Sin definir los estados del ciclo de vida de una ficha, es imposible diseñar correctamente la base de datos y la lógica de negocio.

- **6.1** ¿Cuáles son los **estados posibles** de una ficha de pedido? Por ejemplo: `Borrador → Enviado → En preparación → Listo para recoger → Entregado → Anulado`. ¿Cuáles aplican a tu clínica? Borrador, enviado, en preparacion, listo para recoger, entregado, anulado. para mi esta bien, esos estados se podran ver y su calculo esta en el backend. 
- **6.2** ¿Quién **crea** la ficha? ¿Solo el personal de enfermería/médicos desde su área, o también puede crearla el personal de farmacia? son ya establecidos desde el principio, de ehcho un formulario lo pedira, y se exportara en el formato de ficha correspondiente como una plantilla html.
- **6.3** ¿Una ficha puede **anularse o modificarse** después de enviada? ¿Quién tiene permiso para hacerlo? Si aun siguen en estado enviado, si. Sino solo el adminitrador.
- **6.4** ¿Hay algún proceso de **validación médica** (firma del doctor) antes de que farmacia empiece a preparar el pedido?
proceso de validacion no, solo el registro, porque el sistema principal de dialyma ya se encarga de eso.
---

### 7. ROLES DE USUARIO Y PERMISOS

> [!IMPORTANT]
> Ya existe HU-23 (login con roles). Necesito confirmar qué rol accede a los formularios de pedido.

- **7.1** ¿Cuántos roles distintos habrá en el sistema? Del contexto veo: Almacén, Jefatura, Enfermería, Tecnicos, Médico, personal de farmacia (quien prepara, tambien quiero agregar quien lo alisto y quien lo entrego), Administrador. 
- **7.2** ¿El rol de **Enfermería** es quien crea las fichas de pedido? ¿O también puede el médico? solo la enfermera o el tecnico(a), los medicos solo son para adjuntarlos a la ficha, eso puede ser consultado por la base de datos principal, o solo escrito, ya que es solo para registro plano.
- **7.3** ¿El rol de **Farmacia/Almacén** es quien ve los pedidos entrantes, los prepara y registra la entrega? Solo personal de farmacia. 
- **7.4** ¿El **doctor a cargo** (que aparece en el pie de ambas fichas) es seleccionado de una lista de médicos registrados, o se escribe manualmente? lo dije en el 7.2.

---

### 8. PLATAFORMA Y DISPOSITIVOS

- **8.1** ¿Los formularios de pedido los llenará el personal desde un **teléfono móvil, tablet, o computadora de escritorio**? ¿O en todos? desde una app movil.
- **8.2** ¿Se necesita que el formulario **funcione offline** (sin internet) y se sincronice después, como menciona HU-25? no por ahora.
- **8.3** ¿Habrá un módulo de **impresión o exportación a PDF** de las fichas? Actualmente en muchas clínicas se necesita la copia física para archivar. La exportacion a pdf si, y se puede asignar a que suba a un drive, asi que podra adjuntar al registrar el usuario el correo de su area o personal.

---

### 9. INTEGRACIÓN CON EL SISTEMA DE STOCK

> [!WARNING]
> Aquí puede haber conflictos de diseño si no se define bien.

- **9.1** Cuando se despacha un medicamento desde una ficha, ¿el stock se descuenta **automáticamente e inmediatamente**, o el farmacéutico lo confirma manualmente primero? El que confirma la entrega pues, al tecnico presionar el boton de recibido y al pasar ese pedido a estado entregado, se descuenta de farmacia y se indica para donde se fue.
- **9.2** Si un medicamento de la receta **no tiene stock disponible**, ¿qué pasa? ¿Se bloquea toda la ficha, se despacha lo que hay y queda pendiente el resto, o se notifica al área solicitante? No se puede seleccionar ya que se desahbilita, si es que fuera antes de registrarlo, sino se coloca en observaciones como que ese medicamento, insumo ya no tiene stock, seria bueno una tercera columna donde haya un check, un triangulo o una equis, y se pone una nota de que pregunte a farmacia.
- **9.3** ¿El sistema debe diferenciar el stock **por área** (ej. stock de Neonatología vs. stock de Emergencia), o es un stock centralizado de farmacia? Ambos, farmacia y almacen son uno solo, solo que almacen guarda lo que no se puede guardar en farmacia, y se registra lo que se envia a las demas areas para saber que paso con eso medicmanetos e insumos que salieron de farmacia y ver a donde se fueron.

---

### 10. NOMENCLATURA Y DATOS TÉCNICOS

- **10.1** ¿El nombre del proyecto completo es **"SITRA-Luz"**? ¿Qué significa "Luz" — es el nombre de la clínica? Sistema de trazabilidad y dispensacion de medicamentos, la clinica se llama CLINICA LA LUZ.
- **10.2** ¿Habrá un **número de ficha / número de orden correlativo** generado automáticamente por el sistema para identificar cada pedido? Si.
- **10.3** ¿Se necesita un campo de **hora** además de la fecha en las fichas, para trazabilidad de turno (mañana, tarde, noche)? Si, no hay problema en agregar eso. sirve para filtrar, turno mañana, tarde, noche.

---

## Próximos Pasos (una vez respondidas las preguntas)

1. Definir el modelo de datos completo para las fichas.
2. Diseñar los wireframes de ambos formularios.
3. Mapear las fichas a las HU existentes (HU-12, HU-13, HU-14, HU-15, HU-16) y ajustar si hay HU nuevas.
4. Comenzar la construcción de los formularios en Flutter.
