# **Sistema de Trazabilidad y Gestión de Farmacia Clínica**

Proyecto de aplicación móvil desarrollada en Flutter para la gestión integral, trazabilidad y auditoría de medicamentos y dispositivos médicos dentro de una clínica. El sistema optimiza el registro utilizando Inteligencia Artificial y lectura de códigos de barras, y controla el flujo de inventario desde el almacén hasta las áreas críticas (SOP, Hospitalización, Emergencias, Coche de Paros).

## **1\. Arquitectura y Roles de Usuario**

El sistema opera bajo una estructura de roles jerárquicos, garantizando que cada usuario vea solo la interfaz y las funciones que le corresponden:

* **Rol Almacén (Punto de Entrada):** Encargado de ingresar los medicamentos al sistema y despachar las solicitudes de abastecimiento interno hacia Farmacia  y a enfermeria en el caso de vacunas .  
* **Rol Jefatura de Farmacia (Centro de Distribución y Control):** Solicita abastecimiento de stock a Almacén y tambien verifica la llegada de  pedidos realizados, compara a las distintas distribuidoras,  medicamentos,   
* **Rol Enfermería / Áreas Críticas (SOP, Emergencia, Coche de Paros):** Encargados de la custodia y control del stock  medicamentos existentes en coches de paro de las distintas areas. Emergencia, solicitan atencion de recetas. SOP, solicitan la reposicion de medicamentos mediantes las hojas de sop usados en cirugia.  Consumidores del stock. Visualizan catálogos, solicitan kits o medicamentos individuales, y registran el uso final.

## **2\. Módulos Principales del Sistema**

### **Módulo 1: Registro Inteligente (Almacén)**

Permite ingresar nuevos medicamentos al sistema combinando lectura local de códigos e Inteligencia Artificial en la nube para automatizar la extracción de datos.

* **Lectura de Código GTIN:** Uso de la cámara del dispositivo para leer el código de barras GS1/GTIN de forma offline e instantánea.  
* **Validación Cruzada con IA (OCR \+ Contexto):** Se captura una foto opcional de la caja. La IA recibe la imagen y el código GTIN, cruzando la información para garantizar precisión.  
* **Campos extraídos y registrados:**  
  * Nombre Comercial estandarizado.  
  * Principio Activo.  
  * Lote.  
  * Fecha de Vencimiento.  
  * Registro Sanitario.  
  * Cantidad / Forma farmaceutica  (ej. Caja x 100 pastillas, ampolla individual, unidad).

### **Módulo 2: Gestión de Inventario y Abastecimiento**

Control del inventario anual   principal y abastecimiento de la Farmacia (se omite el flujo de venta al público). La atencion a las distintas areas es de forma continua , emergencia, hospitalizacion y sop 

* **Peticiones de Abastecimiento:** 

El personal de turno  guardia revisa y elabora un listado de los faltantes , para evitar ruptura  de stock y lo solicita almacen para su l abastecimiento   
 La Jefa de Farmacia monitorea su stock físico y realiza un requerimientode pedidos de medicamentos y almacen los visualiza para realizar la orden de compra de los productos que llegaron.  
**Recepción en Farmacia:** Los medicamentos transferidos cambian de estado y ubicación al ser confirmados por Farmacia.

### **Módulo 3: Peticiones y Dispensación a Áreas Críticas**

Flujo de trabajo para abastecer a Sala de Operaciones (SOP), Emergencias y Coches de Paros.

SOP, solicita sets de cirugias que ya estan estandarizados la relacion de medicamentos.  
Coche de paro, ya estan alistados 

* **Paquetes / Kits Prearmados:** SOP puede solicitar kits estandarizados (ej. "Kit Cirugía General", "Kit RCP") o seleccionar medicamentos individuales desde el catálogo.  
* **Auditoría de Petición (Trazabilidad Humana):** Para crear un pedido, la enfermera debe registrar obligatoriamente:  
  * Usuario que hace la solicitud (firma digital del logueado).  
  * Doctor a cargo (seleccionable desde una base de datos de médicos registrados).  
  * Motivo o paciente.  
* **Flujo de Entrega:**  
  1. El pedido llega a la tablet de Farmacia.  
  2. El personal de Farmacia alista los medicamentos (preparación/picking).  
  3. Farmacia presiona el botón **"Listo para Recojo"**.  
  4. El área solicitante recibe una notificación, recoge el pedido y el sistema descuenta los insumos del stock de Farmacia, trasladándolos al área correspondiente. Se puede adjuntar una **foto opcional** de la salida de los productos.

### **Módulo 4: Dashboard de Jefatura y Auditoría**

Panel de control exclusivo para la Jefa de Farmacia, diseñado para el análisis de datos y prevención de pérdidas.

* **Trazabilidad Total:** Búsqueda por medicamento o lote para ver su historial completo (cuándo entró a Almacén, cuándo pasó a Farmacia, quién lo pidió para SOP y para qué Doctor).  
* **Control de Stock en Tiempo Real:** Visualización del total general de medicamentos y el total dividido por áreas (Almacén, Farmacia, SOP, Emergencias, Coches de Paros).  
* **Gráficos Estadísticos:**  
  * Consumo de dispositivos médicos y medicamentos por área.  
  * Doctores o procedimientos que generan mayor consumo.  
* **Alertas de Caducidad:** Sistema de notificaciones tempranas de fechas de vencimiento basadas en la regla FEFO (*First Expired, First Out*).

## **3\. Modelo de Negocio y Base Económica (Uso Interno)**

El sistema es un software interno (*In-house*) justificado económicamente por el Retorno de Inversión (ROI) operativo:

| Beneficio / Justificación | Impacto Económico para la Clínica |
| :---- | :---- |
| **Reducción de Mermas** | Las alertas de caducidad evitan el desecho de medicamentos vencidos. |
| **Prevención de Hurtos** | La auditoría estricta (quién, para qué doctor, foto de salida) elimina el inventario "fantasma". |
| **Eficiencia Operativa** | Los "Kits" automatizan pedidos complejos, reduciendo las horas-hombre de Enfermería y Farmacia. |

### **Estructura de Mantenimiento (OPEX)**

* **Infraestructura Cloud:** Hospedaje de Base de Datos y almacenamiento de fotografías (AWS / Firebase).  
* **Servicios de Inteligencia Artificial:** Consumo de API (Gemini) para procesamiento OCR y extracción de datos.  
* **Soporte Técnico:** Mantenimiento de la app, actualización a nuevas versiones de OS y resolución de bugs.

## **4\. Stack Tecnológico Sugerido**

* **Frontend (App Móvil/Tablet):** Flutter (Dart) para Android.  
* **Escáner de Código de Barras (GTIN):** Google ML Kit (mobile\_scanner en Flutter) \- Procesamiento local y gratuito.  
* **Procesamiento IA (OCR):** Gemini Flash API (Structured Outputs en JSON).  
* **Backend & Base de Datos:** Firebase (según la infraestructura de la clínica).

EXTRAOFICIAL:

Tenemos que hacer el plan de sprint para poder rellenar lo siguiente, cada semana haremos un informe de daily el cual, tendra que redactar las evidencias del sprint en el que està, es a libre eleccion si colocamos que el sprint 1 duro dos semanas y demostrar porque, no es necesario un sprint cada semana.

1. **Registro del daily**

| Integrante | Que realizó? | Algo lo bloquea? |
| :---- | :---- | :---- |
| Ancco Suaña, Bruno |  |  |
| Sala Jimenez, Walter |  |  |
| Anampa, David |  |  |

2. **Estado del tablero al cerrar la sesión**

| Columna | Historias | Límite de trabajo en curso | Se respeta? |
| :---- | :---- | :---- | :---- |
| Sprint backlog |  |  |  |
| En progreso |  |  |  |
| En revisión |  |  |  |
| En pruebas |  |  |  |
| Listo |  |  |  |

3. **Impedimentos**

| Id | Impedimento | Quien lo levantara | Quien lo remueve | Estado | Fecha de cierre |
| :---- | :---- | :---- | :---- | :---- | :---- |
|  |  |  |  |  |  |
|  |  |  |  |  |  |

### **Propuesta de Arquitectura de Datos: Modelo Híbrido (MSSQL \+ NoSQL)**

**1\. Contexto y Situación Actual** El proyecto del "Sistema de Trazabilidad y Gestión de Farmacia Clínica" requiere integrarse con la base de datos relacional (MSSQL) que la clínica ya utiliza como sistema central. Sin embargo, debido a que la nueva solución es una aplicación móvil desarrollada en Flutter que capturará datos complejos (como fotografías, firmas digitales y metadatos de Inteligencia Artificial), y que operará en áreas críticas donde la conexión a internet puede ser inestable (SOP, Emergencias), se propone una **arquitectura de base de datos híbrida**.

**2\. ¿Cómo funcionará el Modelo Híbrido?**

El sistema dividirá las responsabilidades de almacenamiento para no sobrecargar el servidor actual de la clínica, aprovechando lo mejor de dos tecnologías:

* **MSSQL (Base de Datos de la Clínica):** Se mantendrá como la "fuente única de verdad" para los datos transaccionales duros. Gestionará el catálogo maestro de medicamentos, los lotes, las ubicaciones y los saldos de inventario de cada área.  
* **NoSQL / Firebase (Base de Datos de la App):** Actuará como el motor de trazabilidad y auditoría. Almacenará el historial de eventos, el contexto de las operaciones (quién lo pidió, para qué doctor, firmas digitales, fotos de las entregas) y permitirá que la aplicación móvil funcione con sincronización offline.

**3\. Flujo de Datos y Consultas Estandarizadas**

La aplicación móvil no hará inserciones directas a MSSQL. Toda comunicación pasará por una API central que orquestará la información de la siguiente manera:

* **Caso A: Ingreso de Nuevos Medicamentos (Módulo 1\)**

   Cuando el rol de Almacén escanee un código de barras y la Inteligencia Artificial extraiga los datos del empaque, la API recibirá esta información.  
  * *En MSSQL:* Se ejecutará una consulta estandarizada (ej. INSERT) en la tabla maestra de Medicamentos y se registrará el ingreso del lote.  
  * *En NoSQL:* Se guardará el registro de auditoría de quién ingresó el producto, a qué hora y el grado de precisión que arrojó la IA.  
* **Caso B: Transferencias y Uso en Áreas Críticas (Módulos 2 y 3\)**

   Cuando un enfermero en SOP o Emergencia reciba un kit de medicamentos, la app confirmará la recepción.  
  * *En MSSQL:* Se ejecutará una consulta de actualización (ej. UPDATE) para descontar atómicamente el stock de la Farmacia y sumarlo/consumirlo en el área de destino.  
  * *En NoSQL:* Se creará un documento inmutable con la "fotografía" del momento: el usuario que solicitó, el doctor a cargo, responsable a cargo, que se llevo y la foto opcional de la salida.

**Beneficio de este modelo:** La clínica mantiene intacta y segura su contabilidad e inventario en MSSQL, mientras gana una trazabilidad profunda y prevención de pérdidas gracias a la base NoSQL, todo operando en tiempo real.

