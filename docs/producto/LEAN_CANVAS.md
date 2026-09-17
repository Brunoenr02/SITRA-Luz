# Lean Canvas — SITRA-Luz

**Sistema de Trazabilidad y Gestión de Farmacia Clínica**

> Lean Canvas completado en el orden recomendado por Ash Maurya (1 → 9).
>
> **Contexto:** La clínica ya opera con **Dialyma**, un sistema de escritorio que registra la entrada de medicamentos en Almacén y la salida por venta en Caja de Farmacia. SITRA-Luz **no reemplaza a Dialyma**: digitaliza el **flujo interno** que hoy se gestiona con fichas de papel, cuadernos y comunicación verbal.

---

## 1. Problema

Los tres problemas principales del **flujo interno** de medicamentos que Dialyma no cubre:

1. **El movimiento interno no tiene registro digital:** Cuando Almacén transfiere stock a Farmacia, y cuando Farmacia despacha a SOP, Emergencias o Coche de Paros, nada queda en un sistema. Se anota en cuadernos o fichas de papel. Dialyma solo ve entrada (proveedor → almacén) y salida (venta por caja), por lo que todo lo que se mueve internamente genera inventario «fantasma» y descuadres mensuales.
2. **Las peticiones de medicamentos para procedimientos se hacen en papel:** Las enfermeras de SOP, Emergencias y Coche de Paros llenan fichas de petición a mano, bajan a Farmacia, entregan la ficha y esperan presencialmente a que armen el carrito. En urgencias, ese proceso genera demoras de 20-45 minutos. Las fichas se llenan incompletas, se extravían y no sirven como auditoría.
3. **No hay trazabilidad de quién consumió qué:** Cuando falta stock y la jefatura pregunta a dónde se fue un medicamento, no hay forma de rastrearlo porque las fichas de papel (cuando existen) no están digitalizadas ni vinculadas al inventario.

**Alternativa existente:** Dialyma (solo extremos del flujo), cuadernos de control manual, fichas de petición en papel, comunicación verbal entre áreas.

---

## 2. Segmento de clientes

- **Segmento principal:** Jefas/Jefes de Farmacia de clínicas privadas pequeñas y medianas (20-100 camas) que ya tienen un sistema de escritorio para entrada/venta pero **no tienen digitalizado el flujo interno**.
- **Early adopters:** Clínicas que ya usan tablets o celulares corporativos en sus áreas pero siguen con fichas de papel para peticiones internas.
- **Usuarios finales directos:**
  - **Almacén:** Registra entrada y transfiere stock a Farmacia.
  - **Farmacia:** Recibe stock, arma carritos/pedidos para las áreas clínicas.
  - **Enfermería (SOP, Emergencias, Coche de Paros):** Solicita medicamentos y dispositivos médicos para procedimientos.
  - **Jefatura de Farmacia:** Audita y controla todo el flujo.

---

## 3. Propuesta de valor única

**Digitaliza el flujo interno de medicamentos que Dialyma no cubre: desde que salen de Almacén, pasan por Farmacia y llegan a las áreas clínicas, con peticiones digitales, trazabilidad completa y notificaciones en tiempo real — todo desde la tablet o celular del personal.**

Reemplaza las fichas de papel, los cuadernos de control y las esperas presenciales en farmacia por un flujo digital auditable.

---

## 4. Solución

| Problema | Funcionalidad de SITRA-Luz |
|---|---|
| Movimiento interno sin registro digital | **Registro de transferencias:** Cuando Almacén entrega stock a Farmacia, y cuando Farmacia despacha a un área clínica, se registra digitalmente con fecha, hora, usuario y detalle. Complementa a Dialyma cubriendo el tramo interno |
| Peticiones en papel con esperas presenciales | **Peticiones digitales desde la tablet:** La enfermera envía la petición con los medicamentos que necesita, el doctor a cargo y el motivo. Farmacia recibe el pedido, arma el carrito y presiona «Listo para recojo». El área recibe una notificación sin tener que bajar y esperar |
| Sin trazabilidad de consumo | **Auditoría obligatoria:** Cada petición registra quién solicitó, para qué doctor, qué medicamentos y cuándo se despacharon. La jefatura puede buscar por medicamento o lote y ver su historial completo |

**Funcionalidad complementaria:**
- **Registro inteligente en Almacén:** Lectura de código GTIN con la cámara + IA (Gemini) para extraer automáticamente nombre, lote, vencimiento y registro sanitario al momento del ingreso.
- **Alertas FEFO:** Notificaciones tempranas de caducidad para priorizar el uso de lo que vence primero.
- **Kits prearmados:** SOP puede solicitar kits estandarizados (ej. «Kit Cirugía General», «Kit RCP») para agilizar pedidos repetitivos.

---

## 5. Canales

- **Despliegue directo:** Instalación de la app en tablets de farmacia y celulares corporativos del personal de SOP, Emergencias y Almacén.
- **Capacitación presencial:** Sesión de onboarding por área (Almacén, Farmacia, SOP/Emergencias) con el flujo específico de cada rol.
- **Soporte:** Canal de WhatsApp Business para soporte técnico rápido.
- **Distribución:** Google Play Store (versión Android) para facilitar actualizaciones.

---

## 6. Flujos de ingresos

Al ser un software de uso interno (*in-house*) que complementa a Dialyma, el ingreso es por **ahorro operativo (ROI)**:

| Fuente de valor | Estimación de ahorro mensual |
|---|---|
| Reducción de descuadres de inventario (trazabilidad interna) | S/ 800 – S/ 1,500 |
| Reducción de mermas por vencimiento (alertas FEFO) | S/ 1,000 – S/ 3,000 |
| Eliminación de esperas presenciales en farmacia (peticiones digitales) | S/ 500 – S/ 1,000 (horas-hombre recuperadas) |
| Prevención de desvíos con auditoría digital | S/ 1,000 – S/ 2,000 |
| **Potencial ahorro mensual total** | **S/ 3,300 – S/ 7,500** |

**Modelo futuro (escalamiento):** Licenciamiento SaaS mensual para otras clínicas con el mismo problema.

---

## 7. Estructura de costos

| Concepto | Tipo | Costo estimado |
|---|---|---|
| Firebase (Firestore, Auth, Storage, FCM) | OPEX mensual | S/ 0 – S/ 150 (nivel gratuito cubre MVP) |
| Gemini API (OCR + extracción de datos) | OPEX mensual | S/ 50 – S/ 200 (según volumen de escaneos) |
| Google Play Console | Pago único | S/ 90 |
| Horas de desarrollo (equipo de 3) | Inversión inicial | 5 sprints × 3 personas |
| Soporte técnico y mantenimiento | OPEX mensual | S/ 200 – S/ 500 post-lanzamiento |

---

## 8. Métricas clave

| Métrica | Objetivo del MVP (Sprint 5) |
|---|---|
| Peticiones internas procesadas digitalmente vs. papel | ≥ 80% digitales |
| Tiempo promedio desde petición hasta carrito listo | < 15 minutos (vs. 30-45 min actual) |
| Transferencias Almacén → Farmacia registradas digitalmente | 100% |
| Descuadres de inventario mensuales | Reducción ≥ 50% vs. línea base |
| Medicamentos con alerta de caducidad detectada antes de vencer | ≥ 95% |
| Medicamentos registrados por escaneo GTIN + IA vs. manual | ≥ 70% por escaneo |

---

## 9. Ventaja injusta

- **Complementa el sistema existente:** SITRA-Luz no compite con Dialyma ni obliga a migrar; cubre exactamente el tramo que Dialyma no maneja (el flujo interno), lo que reduce la barrera de adopción.
- **Conocimiento del flujo real:** El equipo ha entrevistado directamente a personal de farmacia, almacén, SOP y emergencias de la clínica, entendiendo el proceso real con fichas de papel, carritos y esperas.
- **IA integrada al registro:** La combinación de lectura GTIN local (ML Kit, sin internet) + validación cruzada con IA (Gemini) para automatizar el ingreso no existe en soluciones accesibles para clínicas pequeñas en Perú.
- **Diseñada para la urgencia clínica:** La interfaz permite crear peticiones rápidas (incluso con kits prearmados) pensando en que el usuario está atendiendo un paciente, no sentado frente a una computadora.
