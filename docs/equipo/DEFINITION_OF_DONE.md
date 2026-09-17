# Definition of Done (DoD)

Este documento define los 12 criterios obligatorios que toda Historia de Usuario debe cumplir antes de considerarse "Terminada".

| # | Criterio | Cómo se verifica |
|---|---|---|
| 1 | Compilación | GitHub Actions verifica que el comando `flutter build apk` (o análogo) termine sin errores. |
| 2 | Análisis estático y linter | GitHub Actions ejecuta `flutter analyze` y debe pasar en verde (sin warnings o errores). |
| 3 | Pruebas unitarias | GitHub Actions ejecuta `flutter test` y todas las pruebas deben pasar en verde. |
| 4 | Cobertura del dominio | Un script en la CI verifica que el reporte de cobertura (`lcov.info`) de la carpeta `domain/` sea ≥ 70%. |
| 5 | Regla de dependencia | Revisión manual de código (Code Review) en el PR: El dominio no debe importar datos ni presentación. |
| 6 | Sin secretos filtrados | GitHub Actions usa `Trivy` para escanear y fallar si hay contraseñas o tokens en el código. |
| 7 | Arquitectura de 4 estados | Revisión en el PR y demo: La UI maneja correctamente Loading, Success, Empty y Error. |
| 8 | ViewModel sin emulador | Las pruebas del ViewModel usan un Repositorio Falso y pasan exitosamente en la CI. |
| 9 | DTO y Entidad separados | Revisión manual en el PR: Existen clases separadas conectadas por un Mapper. |
| 10 | Funcionalidad completa | La historia de usuario atraviesa la base de datos (o API simulada) hasta la vista en el emulador. |
| 11 | Aprobación de PR | GitHub bloquea el merge a `main` hasta tener la aprobación de al menos 1 compañero (Code Review). |
| 12 | Evidencias generadas | Toda evidencia (capturas, salidas de CI) debe estar subida a la carpeta `docs/evidencias`. |
