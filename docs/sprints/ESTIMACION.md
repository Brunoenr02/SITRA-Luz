# Estimación — Planning Poker

## Método

Se utilizó Planning Poker para realizar una estimación relativa de las
historias previstas para los Sprints 1 y 2.

La escala utilizada corresponde a puntos de historia:

1, 2, 3, 5, 8, 13

## Registro de estimaciones

| Historia | Estimaciones individuales | Consenso | Discrepancia | Qué reveló la discusión |
|---|---|---:|---|---|
| US-01 | 3, 3, 8, 5 | 5 | 3 vs. 8 | Se aclaró que la validación del correo y las condiciones de acceso forman parte del alcance. |
| US-02 | 3, 5, 5, 3 | 5 | 3 vs. 5 | Se discutió la validación de datos y el registro seguro del usuario. |
| US-05 | 5, 8, 8, 8 | 8 | 5 vs. 8 | Se identificó que registrar una petición requiere validar usuario y datos del responsable. |
| US-06 | 5, 5, 8, 5 | 5 | 5 vs. 8 | Se aclaró que la selección de medicamentos y cantidades debe validarse antes del envío. |
| US-07 | 3, 5, 5, 5 | 5 | 3 vs. 5 | Se precisó que el doctor y el motivo deben quedar asociados a la petición. |
| US-08 | 5, 5, 8, 5 | 5 | 5 vs. 8 | Se aclararon los estados que puede consultar el usuario. |
| US-11 | 3, 5, 5, 5 | 5 | 3 vs. 5 | Se precisó que Farmacia debe visualizar las peticiones pendientes. |
| US-12 | 5, 5, 8, 5 | 5 | 5 vs. 8 | Se aclaró que el detalle debe mostrar medicamentos, cantidades y datos necesarios. |
| US-13 | 3, 5, 5, 5 | 5 | 3 vs. 5 | Se definieron los estados permitidos para una petición. |
| US-14 | 5, 8, 8, 8 | 8 | 5 vs. 8 | Se identificó la necesidad de registrar fecha, hora y usuario responsable. |
| US-15 | 3, 5, 5, 5 | 5 | 3 vs. 5 | Se aclararon los datos mínimos necesarios del receptor. |
| US-16 | 3, 5, 5, 5 | 5 | 3 vs. 5 | Se precisó que el stock debe visualizarse antes de una transferencia. |
| US-17 | 5, 8, 8, 8 | 8 | 5 vs. 8 | Se identificó la validación de stock como parte importante del trabajo. |
| US-18 | 3, 5, 5, 5 | 5 | 3 vs. 5 | Se aclaró el cambio de estado al registrar la recepción. |
| US-19 | 3, 5, 5, 5 | 5 | 3 vs. 5 | Se definió qué información mínima debe aparecer en el historial. |
| US-20 | 3, 5, 5, 5 | 5 | 3 vs. 5 | Se identificó la necesidad de conservar la trazabilidad del solicitante. |
| US-21 | 2, 3, 3, 3 | 3 | 2 vs. 3 | Se aclaró que fecha y hora deben quedar asociadas a cada movimiento. |
| US-22 | 2, 3, 3, 3 | 3 | 2 vs. 3 | Se precisó la relación entre la petición y el doctor responsable. |
| US-23 | 3, 5, 5, 5 | 5 | 3 vs. 5 | Se aclaró el criterio de medicamento próximo a vencer. |
| US-24 | 2, 3, 3, 3 | 3 | 2 vs. 3 | Se precisó que Almacén debe visualizar las fechas de vencimiento. |
| US-25 | 2, 3, 3, 3 | 3 | 2 vs. 3 | Se aclaró cuándo debe generarse una notificación. |
| US-26 | 2, 3, 3, 3 | 3 | 2 vs. 3 | Se definió que Farmacia debe recibir aviso cuando exista una nueva petición. |

## Hallazgo principal

La principal discrepancia encontrada durante Planning Poker estuvo relacionada
con el alcance de las historias que involucran validaciones y trazabilidad.

El equipo acordó mantener una estimación mayor cuando la historia requiere
validaciones, persistencia de información o integración entre módulos.

Las historias se mantienen en tamaños manejables y no existen historias de
13 puntos o más.

