# Convenciones del equipo

## Ramas

- `main` — protegida; solo se integra mediante Pull Request aprobado
- `develop` — integración
- `feature/<US-xx>-descripcion`
- `fix/<descripcion>`
- `chore/<descripcion>`

## Commits — Conventional Commits

Formato:

`<tipo>(<alcance>): <descripción> [US-xx]`

Tipos permitidos:

- `feat` — nueva funcionalidad
- `fix` — corrección de errores
- `docs` — documentación
- `style` — cambios de formato
- `refactor` — refactorización
- `test` — pruebas
- `chore` — tareas de mantenimiento o configuración

Ejemplo:

`feat(auth): agregar inicio de sesión con PKCE [US-07]`

## Pull Request

Todo Pull Request debe:

- Estar vinculado a una historia de usuario del backlog.
- Tener la integración continua (CI) en verde.
- Ser revisado por al menos un integrante distinto del autor.
- Cumplir con la Definition of Done del equipo.
