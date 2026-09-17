# ADR-002 · Stack Tecnológico

- **Estado:** aceptada · **Fecha:** 2026-09-04 · **Decidido por:** Equipo

## Contexto
Necesitamos elegir un stack de desarrollo móvil que permita construir la app en el tiempo del curso (5 sprints).

## Evaluación
Se evaluaron los stacks usando la matriz `evaluacion_stacks.csv`. Flutter y React Native fueron los finalistas.

**Prueba de Humo (Smoke Test):**
Se ejecutó un "hola mundo" implementando el acceso a la cámara en Flutter y React Native.
- Flutter: Logrado en 15 minutos usando `image_picker`.
- React Native: Logrado en 25 minutos.

## Decisión
Se elige **Flutter** como el stack principal debido a su alto rendimiento, facilidad para compilar sin macOS (para la versión Android) y la familiaridad del equipo con Dart.

## Plan de Salida (Exit Strategy)
Si Flutter dejara de ser viable o soportado:
- **Costo de migración:** Alto. Se tendría que reescribir toda la capa de Presentación (UI).
- **Reutilización:** La lógica de negocio y consumo de APIs en Dart podría ser migrada manualmente o traducida a Kotlin, pero no es directamente reutilizable.
- **Cuándo reconsiderar:** Si las dependencias críticas (ej. mapas/cámara) dejan de recibir soporte para las nuevas versiones de Android/iOS.
