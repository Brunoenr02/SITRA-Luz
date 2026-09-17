# Acuerdos de trabajo — Equipo SITRA-Luz

## 1. Daily Standup

- **Horario:** Lunes a viernes a las **23:00** (11 PM), duración máxima de **15 minutos**.
- **Canal:** Llamada grupal por **WhatsApp** o Google Meet si la daily requiere compartir pantalla.
- **Formato:** Cada integrante responde:
  1. ¿Qué hice desde la última daily?
  2. ¿Qué haré hoy?
  3. ¿Tengo algún bloqueo?

## 2. Canal de comunicación y tiempo de respuesta

- **Canal principal:** Grupo de WhatsApp del equipo «SITRA-Luz — SI988».
- **Canal secundario:** Discord (para compartir código y archivos extensos).
- **Tiempo máximo de respuesta:** **2 horas** en horario activo (8:00 a 23:50). Fuera de ese horario, se responde al día siguiente antes de las 8:00 AM.

## 3. Protocolo de bloqueo (más de 4 horas)

1. El integrante bloqueado **documenta el problema** en el chat del equipo con: descripción, qué intentó y error o resultado obtenido.
2. Si ningún compañero puede ayudar en **2 horas**, se escala al **Scrum Master** (Bruno Ancco) para buscar apoyo externo o del docente.
3. Se registra el bloqueo como impedimento en el tablero del sprint.

## 4. Resolución de desacuerdos técnicos

1. Se exponen las alternativas con **ventajas, desventajas y costo estimado** (formato ADR simplificado).
2. Se vota por mayoría simple. En caso de empate, el **Product Owner** (Walter Salas) tiene voto de desempate en temas de producto; el **Scrum Master** (Bruno Ancco) en temas de proceso.
3. La decisión se documenta en un **ADR** (`docs/decisiones/`).

## 5. Definition of Done (borrador — se formaliza en Semana 02)

Un ítem del backlog se considera **«terminado»** cuando cumple **todos** estos criterios:

- [ ] El código compila sin errores ni warnings críticos.
- [ ] Los tests unitarios pasan (`flutter test`).
- [ ] El análisis estático sale limpio (`flutter analyze`).
- [ ] El código fue subido a una rama `feature/` y el **Pull Request** fue revisado y aprobado por al menos **un integrante distinto del autor**.
- [ ] El CI está en verde.
- [ ] La funcionalidad se verificó en el emulador (Pixel 6 AVD, API 34).
- [ ] La documentación relevante se actualizó (si aplica).

## 6. Reparto de trabajo

- **Por funcionalidad/módulo:** Cada integrante es responsable de uno o más módulos del sistema.
- **Asignación:** Se realiza en la **Sprint Planning** y se registra en **GitHub Projects** con el responsable asignado.
- **Rotación:** Si un módulo es muy grande, se trabaja en **parejas** rotando cada sprint para distribuir el conocimiento.

| Módulo | Responsable principal |
|---|---|
| Módulo 1: Registro Inteligente (Almacén) | Bruno Ancco |
| Módulo 2: Gestión de Inventario y Abastecimiento | Walter Salas |
| Módulo 3: Peticiones y Dispensación a Áreas Críticas | David Anampa |
| Módulo 4: Dashboard de Jefatura y Auditoría | Walter Salas + David Anampa |

## 7. Incumplimiento de compromisos

1. **Primera vez:** Conversación directa en la daily para entender la causa y redistribuir la carga si es necesario.
2. **Segunda vez:** El Scrum Master agenda una reunión individual para establecer un plan de recuperación documentado.
3. **Tercera vez o más:** Se escala al docente y se documenta la situación como evidencia de contribución individual para la evaluación del curso.

> **Estos acuerdos son un compromiso del equipo.** Se revisan en cada retrospectiva de sprint y se ajustan según la experiencia.