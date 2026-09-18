# ADR-003 · Adopción de Supabase como Base de Datos y Firebase exclusivo para Notificaciones Push (FCM)

- **Estado:** aceptada
- **Fecha:** 2026-09-18
- **Decidido por:** Equipo (Bruno Ancco, Walter Sala, David Anampa)

## Contexto
El diseño original contemplaba un modelo híbrido dividiendo datos transaccionales (MSSQL), auditoría/trazabilidad (Cloud Firestore) y autenticación (Firebase Auth). Esta fragmentación generaba duplicidad de esquemas, complejidad al sincronizar transacciones entre SQL y NoSQL, y mayor latencia en dispositivos móviles.

Se requiere simplificar la arquitectura consolidando la persistencia y autenticación en una sola plataforma relacional moderna en la nube, reservando Firebase exclusivamente para el servicio de notificaciones en tiempo real donde FCM es el estándar de facto.

## Alternativas consideradas
| Alternativa | Ventajas | Desventajas | Costo estimado |
|---|---|---|---|
| **Modelo Híbrido (MSSQL + Firestore)** | Aprovechaba MSSQL existente. | Doble fuente de verdad, latencia, desincronización y complejidad de consultas unificadas. | Alto (mantenimiento y código doble). |
| **Firebase Completo (Firestore + Auth + FCM)** | Todo en un solo proveedor. | Firestore no es relacional (dificulta joins para inventario, lotes FEFO y balances de stock atómicos). | Medio. |
| **Supabase (PostgreSQL + Auth) + Firebase FCM** | Base de datos PostgreSQL relacional con soporte nativo para transacciones atómicas, RLS, triggers y consultas complejas. Firebase se utiliza únicamente para mensajería push de alta confiabilidad. | Requiere mantener credenciales de dos proveedores, pero con responsabilidades totalmente desacopladas. | Bajo (tiers gratuitos robustos y arquitectura limpia). |

## Decisión
Se decide migrar la persistencia, modelos relacionales y autenticación a **Supabase (PostgreSQL)**, y utilizar **Firebase Cloud Messaging (FCM)** exclusivamente para el despacho y recepción de notificaciones push móviles.

## Consecuencias
- **Positivas:**
  1. Base de datos 100% relacional con integridad referencial (Foreign Keys, restricciones de stock `>= 0`, triggers de auditoría automática).
  2. Autenticación centralizada en Supabase con JWT y perfiles sincronizados automáticamente mediante trigger en `auth.users`.
  3. Desacoplamiento total: Firebase solo maneja mensajes push y tokens FCM, sin almacenar datos clínicos ni de inventario.
  4. Mayor facilidad para consultas analíticas de FEFO, trazabilidad y balances por área clínica.
- **Negativas / Mitigaciones:**
  - El desarrollador debe gestionar las credenciales de Supabase en `supabase_config.dart`. Se mitigó implementando un fallback inteligente a `MockAuthRepository` para que la app pueda ejecutarse y probarse incluso sin conexión o antes de configurar la nube.
