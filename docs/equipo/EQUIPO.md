# Equipo Scrum — SITRA-Luz

| Campo | Contenido |
|---|---|
| Nombre del equipo | **SITRA-Luz** |
| **Product Owner** | **Walter Salas** — Responsable del valor y del Product Backlog. Decide qué se construye. Define prioridades funcionales alineadas con las necesidades de la clínica |
| **Scrum Master** | **Bruno Ancco** — Responsable de la eficacia del equipo y del proceso. Facilita las ceremonias Scrum y remueve impedimentos. **Rota cada dos sprints** |
| **Developers** | **David Anampa**, **Walter Salas**, **Bruno Ancco** — Todos los integrantes participan como desarrolladores. El PO y SM también programan |

## Competencias del equipo

| Integrante | Tecnologías | Áreas de conocimiento |
|---|---|---|
| Walter Salas | Flutter/Dart, Firebase (Auth, Firestore, Storage) | Análisis de requisitos, diseño de producto, lógica de negocio |
| Bruno Ancco | Flutter/Dart, Firebase, Git/GitHub Actions | Arquitectura de software, integración continua, control de versiones |
| David Anampa | Flutter/Dart, Firebase, diseño de interfaces | Desarrollo frontend móvil, pruebas, UI/UX básico |

## Brechas de competencia

| Brecha identificada | Impacto en el proyecto | Responsable de cerrarla | Plan de aprendizaje |
|---|---|---|---|
| Integración con **Gemini API** (OCR + IA) | Módulo 1: Registro Inteligente no puede extraer datos automáticamente | Bruno Ancco | Estudiar la documentación de Gemini Structured Outputs y hacer un prototipo en Sprint 1 |
| **Google ML Kit** (lectura de código de barras GTIN) | Sin lectura de códigos no hay entrada rápida de medicamentos | David Anampa | Implementar un prototipo con el paquete `mobile_scanner` antes del Sprint 2 |
| Notificaciones push con **Firebase Cloud Messaging** | El flujo de dispensación a áreas críticas requiere alertas en tiempo real | Walter Salas | Configurar FCM y probar envío de notificaciones dirigidas en Sprint 2 |
| Generación de **gráficos y dashboards** en Flutter | El módulo de Jefatura requiere visualización de datos estadísticos | David Anampa | Evaluar paquetes `fl_chart` o `syncfusion_flutter_charts` en Sprint 3 |

## Acceso a macOS

| Integrante | Acceso | Frecuencia |
|---|---|---|
| Walter Salas | No | — |
| Bruno Ancco | No | — |
| David Anampa | No | — |

> **Nota:** La compilación y firma para iOS se resolverá en la Unidad III según lo indicado en el plan del curso. Durante los sprints iniciales el desarrollo y las pruebas se hacen exclusivamente en Android (emulador + dispositivos físicos).

## Dispositivos disponibles

| Integrante | Dispositivo | SO / Versión | Uso |
|---|---|---|---|
| Walter Salas | Redmi 13C | Android 13 (MIUI 14) | Pruebas en dispositivo real |
| Bruno Ancco | Samsung Galaxy A14 | Android 13 (One UI 5.1) | Pruebas en dispositivo real |
| David Anampa | Redmi 13C | Android 14 (HyperOS) | Pruebas en dispositivo real |
| Todos | Pixel 6 (AVD) | Android 14 (API 34) | Emulador de referencia en laboratorio |