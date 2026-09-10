# ADR-001 · Arquitectura de la aplicación

- **Estado:** aceptada · **Fecha:** 2026-09-04 · **Decidido por:** Equipo

## Contexto
La aplicación consumirá servicios REST, usará la cámara y debe funcionar eficientemente.
El horizonte del proyecto es de 5 sprints de 2 semanas.

## Alternativas consideradas
| Alternativa | Ventajas | Desventajas | Adecuación al tamaño |
|---|---|---|---|
| MVC clásico | Simple, conocido | Controladores enormes; difícil de probar | Insuficiente |
| MVVM + repositorio | Testable, estándar de la plataforma, proporcional | Sin casos de uso, la lógica puede filtrarse al ViewModel | **Adecuada** |
| Clean completa con casos de uso | Máxima separación, escala a varios equipos | Sobrecarga estructural | Desproporcionada |

## Decisión
**MVVM + repositorio**, con capa de dominio ligera. Se agregarán **casos de uso solo en las funcionalidades con lógica de negocio real**.

Reglas obligatorias:
1. La vista no contiene lógica de negocio ni llamadas de red.
2. El ViewModel no importa nada del framework de interfaz.
3. Los DTO y las entidades de dominio son **clases distintas**, unidas por un mapeador.
4. Toda dependencia se inyecta; ninguna se instancia dentro de la clase que la usa.

## Consecuencias
**Positivas:** el ViewModel se prueba sin emulador; cambiar el backend afecta solo a la capa de datos.
**Negativas:** más archivos por pantalla.
**Costo de revertir:** alto a partir del sprint 3.
