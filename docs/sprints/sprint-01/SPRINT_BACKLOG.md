# Sprint Backlog — Sprint 1

## Sprint Goal

Al final del Sprint 1, un usuario podrá acceder de forma segura a SITRA-Luz mediante registro e inicio de sesión, dejando preparada la base de acceso para continuar con el flujo de solicitudes de medicamentos.

## Fechas

- Inicio: 04/09/2026
- Fin: 14/09/2026
- Sprint Review: 14/09/2026
- Sprint Retrospective: 14/09/2026

## Capacidad del Sprint

### Cálculo

Para el cálculo de la capacidad se consideran 3 desarrolladores, 7 días hábiles efectivos dentro del periodo del Sprint y 3 horas de trabajo por día:

3 Developers × 7 días hábiles × 3 horas por día = 63 horas

### Descuentos

- Eventos Scrum: aproximadamente 6 horas.
- Imprevistos: 15 % sobre las horas restantes.
- Horas efectivas aproximadas: 48 horas.

Por no existir velocidad histórica, el equipo adopta un compromiso conservador para el primer Sprint.

## Historias seleccionadas

| ID | Historia | Puntos |
|---|---|---:|
| US-01 | Inicio de sesión | 5 |
| US-02 | Registro de usuario | 5 |

**Total comprometido: 10 puntos**

El compromiso se encuentra dentro del rango recomendado de 8 a 13 puntos
para el Sprint 1.

## Plan de entrega

### US-01 — Inicio de sesión

Tareas:

- Crear pantalla de registro.
- Crear pantalla de inicio de sesión.
- Implementar campos de correo electrónico y contraseña.
- Validar campos obligatorios.
- Validar formato del correo electrónico.
- Implementar autenticación mediante el servicio correspondiente.
- Gestionar la sesión del usuario.
- Mostrar mensajes de error cuando las credenciales sean incorrectas.
- Probar escenarios Gherkin.
- Realizar autoprueba en el emulador.

Responsable inicial: Integrante 1.

### US-02 — Registro de usuario

Tareas:

- Crear pantalla de registro.
- Implementar los campos requeridos para el registro.
- Validar campos obligatorios.
- Validar formato del correo electrónico.
- Validar las condiciones requeridas para el registro.
- Implementar registro mediante el servicio correspondiente.
- Mostrar mensajes de éxito y error.
- Probar escenarios Gherkin.
- Realizar autoprueba en el emulador.

Responsable inicial: Integrante 2.

### Tareas técnicas

- Revisar la estructura actual del proyecto.
- Preparar la rama de desarrollo del Sprint 1.
- Configurar el entorno de pruebas.
- Verificar la integración con el servicio.
- Verificar el flujo de autenticación y registro.
- Registrar impedimentos en GitHub Projects.

Responsable inicial: Integrante 3.

## Riesgos del Sprint

| Riesgo | Impacto | Acción |
|---|---|---|
| Problemas de conexión con el servicio | Alto | Registrar impedimento y utilizar datos de prueba mientras se resuelve. |
| Errores en autenticación | Alto | Probar escenarios positivos y negativos antes de pasar a revisión. |
| Falta de tiempo | Medio | Mantener el compromiso en 10 puntos y respetar el WIP establecido. |

## Acuerdo de la Daily

- Hora: 10:00 a. m.
- Canal: canal de comunicación del equipo y GitHub Projects.
- Duración máxima: 15 minutos.

Cada integrante responderá:

1. ¿Qué hice ayer?
2. ¿Qué haré hoy?
3. ¿Tengo algún impedimento?

Los impedimentos identificados durante la Daily se registrarán en GitHub Projects para su seguimiento.

## Prueba del Sprint Goal

El Sprint Goal fue definido antes de seleccionar las historias.

- Si se elimina US-01 — Inicio de sesión, el usuario no podrá acceder mediante autenticación.
- Si se elimina US-02 — Registro de usuario, un usuario nuevo no podrá crear una cuenta para acceder al sistema.
- Por lo tanto, ambas historias son necesarias para cumplir el Sprint Goal de habilitar el acceso seguro mediante registro e inicio de sesión.

El equipo verificará al finalizar el Sprint que ambas funcionalidades estén integradas y puedan ser probadas mediante el emulador.

## Definition of Done

Una historia podrá pasar a "Listo" cuando:

- Los criterios de aceptación estén verificados.
- El código compile correctamente.
- La funcionalidad haya sido probada en el emulador.
- La Pull Request haya sido revisada por otro integrante diferente al autor.
- CI se encuentre en estado correcto.
- No existan errores conocidos que impidan utilizar la funcionalidad.
