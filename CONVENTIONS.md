# Convenciones del Proyecto SITRA-LUZ

## Convención de Commits (Conventional Commits)
Los commits deben seguir el formato estándar de Conventional Commits:

`<tipo>[ámbito opcional]: <descripción>`

### Tipos permitidos:
* **feat**: Una nueva característica o funcionalidad.
* **fix**: Solución a un error (bug).
* **docs**: Cambios exclusivos en la documentación.
* **style**: Cambios que no afectan el significado del código (espacios en blanco, formato, punto y coma faltante, etc.).
* **refactor**: Un cambio de código que ni corrige un error ni añade una característica.
* **perf**: Un cambio de código que mejora el rendimiento.
* **test**: Añadir pruebas faltantes o corregir pruebas existentes.
* **build**: Cambios que afectan el sistema de construcción o dependencias externas (ej. pubspec, gradle, pods).
* **ci**: Cambios en los archivos y scripts de configuración de CI (ej. GitHub Actions).
* **chore**: Otras tareas que no modifican los archivos fuente ni las pruebas (ej. actualización de dependencias menores).

### Ejemplo:
`feat(auth): agregar validación de correo y contraseña`

## Convención de Branching (GitFlow Simplificado)
* **main**: Código en producción. Siempre estable.
* **develop**: Código en desarrollo, se integra todo el trabajo antes de pasar a `main`.
* **Sprint-XX**: Rama para el desarrollo del sprint en curso (ej. `Sprint-01`).
* **feat/nombre-funcionalidad**: Para nuevas características. Se fusionan (merge) hacia la rama del sprint o `develop`.
* **fix/nombre-bug**: Para correcciones de errores.
* **hotfix/nombre-urgencia**: Correcciones críticas directamente hacia `main`.

El flujo típico para el equipo será sacar una rama desde la rama del Sprint actual para desarrollar su tarea y luego hacer un Pull Request de regreso al Sprint.
