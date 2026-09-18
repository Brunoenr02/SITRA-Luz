# 🚀 Guía de Configuración de Supabase — SITRA-Luz

Esta guía detalla **paso a paso** cómo configurar tu proyecto en **Supabase** para que funcione como la **única base de datos y sistema de autenticación** de la aplicación móvil **SITRA-Luz**, manteniendo **Firebase** exclusivamente para el despacho de **notificaciones push (FCM)**.

---

## 📌 Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                    SITRA-Luz (Flutter)                      │
└───────────────┬─────────────────────────────┬───────────────┘
                │                             │
    (Base de Datos & Auth)          (Notificaciones Push)
                ▼                             ▼
┌───────────────────────────────┐  ┌──────────────────────────┐
│           SUPABASE            │  │         FIREBASE         │
│  - PostgreSQL Relacional      │  │  - Cloud Messaging (FCM)│
│  - Supabase Auth (JWT)        │  │  - google-services.json  │
│  - Profiles (con fcm_token)   │  └──────────────────────────┘
│  - Catálogo, Lotes, Stock     │
│  - Pedidos, Dispensaciones    │
│  - Auditoría y Trazabilidad   │
└───────────────────────────────┘
```

---

## 🛠️ Paso 1: Crear Proyecto en Supabase

1. Ingresa a **[supabase.com](https://supabase.com)** e inicia sesión con tu cuenta de GitHub o correo.
2. Haz clic en el botón verde **"New Project"**.
3. Completa los datos:
   * **Organization:** Selecciona tu organización personal o de equipo.
   * **Name:** `SITRA-Luz-Clinica`
   * **Database Password:** Elige una contraseña segura (guárdala en un lugar seguro).
   * **Region:** Elige `South America (São Paulo)` para la menor latencia posible desde Perú.
4. Presiona **"Create new project"** y espera 1 a 2 minutos hasta que el aprovisionamiento finalice.

---

## 🗄️ Paso 2: Ejecutar el Script de la Base de Datos

Hemos preparado el archivo SQL completo con todas las tablas, relaciones, triggers y datos de prueba:  
👉 [`docs/supabase/setup_sitra_luz.sql`](file:///d:/PROYECTOS_UPT/Moviles02/SITRA_LUZ_ANAMPA_ANCCO_SALAS/SITRA-Luz/docs/supabase/setup_sitra_luz.sql)

1. En el panel lateral izquierdo de tu proyecto en Supabase, haz clic en el ícono de **SQL Editor** (o presiona `S` y `Q`).
2. Haz clic en **"New Query"**.
3. Abre el archivo [`setup_sitra_luz.sql`](file:///d:/PROYECTOS_UPT/Moviles02/SITRA_LUZ_ANAMPA_ANCCO_SALAS/SITRA-Luz/docs/supabase/setup_sitra_luz.sql) en tu editor, copia todo su contenido y pégalo en el editor SQL de Supabase.
4. Haz clic en el botón **"Run"** (o presiona `Ctrl + Enter`).
5. Verás el mensaje `Success. No rows returned`.

### ¿Qué se crea con este script?
| Componente | Descripción |
|---|---|
| `public.profiles` | Perfil de usuario con rol, áreas asignadas y columna `fcm_token` vinculada a Firebase. |
| `public.areas` | Áreas clínicas: Almacén, Farmacia, SOP, Emergencia, Hospitalización, Coche de Paros. |
| `public.doctores` | Directorio de médicos con especialidad y colegiatura para trazabilidad. |
| `public.medicamentos` | Catálogo maestro con código GTIN (para escáner ML Kit), principio activo y cadena de frío. |
| `public.lotes` | Registro de lotes con fecha de caducidad para el control FEFO. |
| `public.inventario_stock` | Stock real disponible por cada área y lote. |
| `public.pedidos_abastecimiento` | Peticiones de reposición de Farmacia a Almacén. |
| `public.kits` y `kit_items` | Kits prearmados para Quirófano (SOP) y Coche de Paros. |
| `public.dispensaciones` | Fichas de pedido desde áreas asistenciales a Farmacia. |
| `public.auditoria_trazabilidad` | Bitácora inmutable de movimientos. |
| **Trigger `handle_new_user()`** | Inserta automáticamente el registro en `profiles` cuando se registra un usuario en `auth.users`. |
| **Políticas RLS** | Seguridad fila por fila para usuarios autenticados. |

---

## 🔑 Paso 3: Obtener URL y Clave Anon y Conectar la App

1. En el menú lateral de Supabase, ve a **Project Settings** (el engranaje ⚙️ abajo a la izquierda).
2. Selecciona **API** (o **Data API**).
3. En la sección **Project API keys**, copia:
   * **Project URL:** `https://xxxxxxxxxxxxxxxx.supabase.co`
   * **anon public key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
4. Abre en tu código Flutter el archivo:  
   👉 [`app/lib/core/config/supabase_config.dart`](file:///d:/PROYECTOS_UPT/Moviles02/SITRA_LUZ_ANAMPA_ANCCO_SALAS/SITRA-Luz/app/lib/core/config/supabase_config.dart)
5. Reemplaza los valores:

```dart
class SupabaseConfig {
  SupabaseConfig._();

  // Pega tu Project URL aquí:
  static const String supabaseUrl = 'https://TU_PROYECTO.supabase.co';

  // Pega tu Anon Public Key aquí:
  static const String supabaseAnonKey = 'TU_ANON_PUBLIC_KEY';
  
  // ...
}
```

---

## 👤 Paso 4: Crear los Usuarios de Demostración

Para que puedas iniciar sesión en la app con los 5 roles del sistema, puedes crearlos de dos formas:

### Opción A (Rápida vía SQL en Supabase):
Copia y ejecuta este bloque en el **SQL Editor** de Supabase para crear las 5 cuentas con la contraseña `123456`:

```sql
-- Crear los 5 usuarios demo en Supabase Auth
DO $$
DECLARE
    uid_admin UUID := 'a0000000-0000-0000-0000-000000000001';
    uid_jefe UUID := 'a0000000-0000-0000-0000-000000000002';
    uid_farma UUID := 'a0000000-0000-0000-0000-000000000003';
    uid_almacen UUID := 'a0000000-0000-0000-0000-000000000004';
    uid_enferm UUID := 'a0000000-0000-0000-0000-000000000005';
BEGIN
    -- 1. Administrador
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_admin, '00000000-0000-0000-0000-000000000000', 'admin@sitraluz.pe', crypt('admin123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Ing. Carlos Mendoza","rol":"ADMINISTRADOR","areas":"Sistemas,Auditoría"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- 2. Jefatura de Farmacia
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_jefe, '00000000-0000-0000-0000-000000000000', 'jefatura@sitraluz.pe', crypt('jefe123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Dra. Elena Ramos","rol":"JEFATURA_FARMACIA","areas":"Farmacia Central"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- 3. Farmacia de Turno
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_farma, '00000000-0000-0000-0000-000000000000', 'farmacia@sitraluz.pe', crypt('farma123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Q.F. Manuel Flores","rol":"FARMACIA","areas":"Farmacia Central"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- 4. Almacén General
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_almacen, '00000000-0000-0000-0000-000000000000', 'almacen@sitraluz.pe', crypt('almacen123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Sr. Roberto Paredes","rol":"ALMACEN","areas":"Almacén General"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- 5. Enfermería / Botiquín
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_enferm, '00000000-0000-0000-0000-000000000000', 'enfermeria@sitraluz.pe', crypt('enfermera123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Lic. Ana Morales","rol":"ENFERMERIA","areas":"UCI Adultos,SOP"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;
END $$;
```

### Opción B (Vía Interfaz Web de Supabase):
1. Ve a **Authentication** -> **Users**.
2. Haz clic en **"Add user"** -> **"Create user"**.
3. Ingresa el correo y contraseña (ej: `admin@sitraluz.pe` / `admin123`).
4. Marca la casilla **"Auto Confirm User?"** para que no requiera verificación de correo.
5. Haz clic en **Create User**.
6. Luego, en la tabla `public.profiles` (en **Table Editor**), verás que el usuario ya existe y puedes asignarle el campo `rol` correspondiente (`ADMINISTRADOR`, `JEFATURA_FARMACIA`, `FARMACIA`, `ALMACEN`, `ENFERMERIA`).

---

## ⚙️ Paso 5: Desactivar Confirmación de Correo para Pruebas

Para agilizar las pruebas y evitar que Supabase pida confirmar el correo al registrar nuevos usuarios:
1. En Supabase, ve a **Authentication** -> **Providers** -> **Email**.
2. Desmarca la opción **"Confirm email"**.
3. Haz clic en **Save**.

---

## 🔔 Paso 6: ¿Cómo funciona Firebase para Notificaciones?

1. El archivo [`google-services.json`](file:///d:/PROYECTOS_UPT/Moviles02/SITRA_LUZ_ANAMPA_ANCCO_SALAS/SITRA-Luz/app/android/app/google-services.json) ya se encuentra vinculado en la app Android para el proyecto Firebase `sitra-luz-clinica`.
2. Al iniciar la app, el servicio [`NotificationService`](file:///d:/PROYECTOS_UPT/Moviles02/SITRA_LUZ_ANAMPA_ANCCO_SALAS/SITRA-Luz/app/lib/core/services/notification_service.dart):
   * Solicita permisos de notificación al usuario.
   * Genera el token único de Firebase Cloud Messaging (`FCM Token`).
3. Cuando el usuario inicia sesión:
   * La app actualiza automáticamente la columna `fcm_token` en la tabla `public.profiles` de Supabase:
     ```sql
     UPDATE public.profiles SET fcm_token = '...' WHERE id = 'user_id';
     ```
4. Cuando Farmacia despacha un pedido o se detecta un stock crítico, se puede consultar el `fcm_token` de los usuarios correspondientes en Supabase y enviar la alerta push vía Firebase Cloud Messaging.

---

## 📱 Cuentas de Demostración Disponibles

| Correo | Contraseña | Rol | Pantalla Destino |
|---|---|---|---|
| `admin@sitraluz.pe` | `admin123` | Administrador | `/admin` |
| `jefatura@sitraluz.pe` | `jefe123` | Jefatura de Farmacia | `/jefatura` |
| `farmacia@sitraluz.pe` | `farma123` | Farmacia Central | `/farmacia` |
| `almacen@sitraluz.pe` | `almacen123` | Almacén General | `/almacen` |
| `enfermeria@sitraluz.pe` | `enfermera123` | Enfermería / Técnico | `/enfermeria` |

> 💡 **Nota:** Si aún no has colocado tus credenciales de Supabase en [`supabase_config.dart`](file:///d:/PROYECTOS_UPT/Moviles02/SITRA_LUZ_ANAMPA_ANCCO_SALAS/SITRA-Luz/app/lib/core/config/supabase_config.dart), la aplicación detectará automáticamente el estado y entrará en **Modo Simulación Local**, permitiendo probar la interfaz con cualquiera de las cuentas anteriores sin errores.
