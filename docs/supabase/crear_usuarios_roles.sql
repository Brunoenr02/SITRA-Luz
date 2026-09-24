-- ============================================================================
-- SITRA-Luz: Creación y Asignación Oficial de Roles y Cuentas en Supabase
-- Ejecuta este script completo en el SQL Editor de tu consola de Supabase.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Actualizar el trigger handle_new_user para que asigne automáticamente
--    el rol y nombre correspondiente según el correo institucional si no se especificaron metadatos.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_rol TEXT;
    user_nombre TEXT;
    user_areas TEXT[];
BEGIN
    -- Detectar rol
    user_rol := COALESCE(
        NEW.raw_user_meta_data->>'rol',
        CASE
            WHEN NEW.email ILIKE '%admin%' THEN 'ADMINISTRADOR'
            WHEN NEW.email ILIKE '%jef%' THEN 'JEFATURA_FARMACIA'
            WHEN NEW.email ILIKE '%farma%' THEN 'FARMACIA'
            WHEN NEW.email ILIKE '%almacen%' THEN 'ALMACEN'
            ELSE 'ENFERMERIA'
        END
    );

    -- Detectar nombre
    user_nombre := COALESCE(
        NEW.raw_user_meta_data->>'nombre',
        CASE
            WHEN user_rol = 'ADMINISTRADOR' THEN 'Ing. Carlos Mendoza'
            WHEN user_rol = 'JEFATURA_FARMACIA' THEN 'Dra. Elena Ramos'
            WHEN user_rol = 'FARMACIA' THEN 'Q.F. Manuel Flores'
            WHEN user_rol = 'ALMACEN' THEN 'Sr. Roberto Paredes'
            WHEN user_rol = 'ENFERMERIA' THEN 'Lic. Ana Morales'
            ELSE split_part(NEW.email, '@', 1)
        END
    );

    -- Detectar áreas
    IF NEW.raw_user_meta_data->>'areas' IS NOT NULL THEN
        user_areas := string_to_array(NEW.raw_user_meta_data->>'areas', ',');
    ELSIF user_rol = 'ALMACEN' THEN
        user_areas := ARRAY['Almacén General']::text[];
    ELSIF user_rol = 'ADMINISTRADOR' THEN
        user_areas := ARRAY['Sistemas', 'Auditoría']::text[];
    ELSIF user_rol = 'ENFERMERIA' THEN
        user_areas := ARRAY['UCI Adultos', 'SOP']::text[];
    ELSE
        user_areas := ARRAY['Farmacia Central']::text[];
    END IF;

    INSERT INTO public.profiles (id, email, nombre, rol, areas_asignadas, activo)
    VALUES (NEW.id, NEW.email, user_nombre, user_rol, user_areas, true)
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        nombre = EXCLUDED.nombre,
        rol = EXCLUDED.rol,
        areas_asignadas = EXCLUDED.areas_asignadas;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. Asegurar que las 5 cuentas oficiales existan en auth.users con sus contraseñas
DO $$
DECLARE
    uid_admin UUID := 'a0000000-0000-0000-0000-000000000001';
    uid_jefe UUID := 'a0000000-0000-0000-0000-000000000002';
    uid_farma UUID := 'a0000000-0000-0000-0000-000000000003';
    uid_almacen UUID := 'a0000000-0000-0000-0000-000000000004';
    uid_enferm UUID := 'a0000000-0000-0000-0000-000000000005';
BEGIN
    -- Administrador (admin123)
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_admin, '00000000-0000-0000-0000-000000000000', 'admin@sitraluz.pe', crypt('admin123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Ing. Carlos Mendoza","rol":"ADMINISTRADOR","areas":"Sistemas,Auditoría"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- Jefatura de Farmacia (jefe123)
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_jefe, '00000000-0000-0000-0000-000000000000', 'jefatura@sitraluz.pe', crypt('jefe123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Dra. Elena Ramos","rol":"JEFATURA_FARMACIA","areas":"Farmacia Central"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- Farmacia Central (farma123)
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_farma, '00000000-0000-0000-0000-000000000000', 'farmacia@sitraluz.pe', crypt('farma123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Q.F. Manuel Flores","rol":"FARMACIA","areas":"Farmacia Central"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- Almacén General (almacen123)
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_almacen, '00000000-0000-0000-0000-000000000000', 'almacen@sitraluz.pe', crypt('almacen123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Sr. Roberto Paredes","rol":"ALMACEN","areas":"Almacén General"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- Enfermería / Técnico (enfermera123)
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_enferm, '00000000-0000-0000-0000-000000000000', 'enfermeria@sitraluz.pe', crypt('enfermera123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Lic. Ana Morales","rol":"ENFERMERIA","areas":"UCI Adultos,SOP"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;
END $$;

-- 3. Actualizar la tabla public.profiles para asegurar que cada correo tenga su rol oficial establecido
UPDATE public.profiles
SET rol = 'ADMINISTRADOR',
    nombre = 'Ing. Carlos Mendoza',
    areas_asignadas = ARRAY['Sistemas', 'Auditoría'],
    activo = true
WHERE email ILIKE '%admin@sitraluz.pe%';

UPDATE public.profiles
SET rol = 'JEFATURA_FARMACIA',
    nombre = 'Dra. Elena Ramos',
    areas_asignadas = ARRAY['Farmacia Central'],
    activo = true
WHERE email ILIKE '%jefatura@sitraluz.pe%';

UPDATE public.profiles
SET rol = 'FARMACIA',
    nombre = 'Q.F. Manuel Flores',
    areas_asignadas = ARRAY['Farmacia Central'],
    activo = true
WHERE email ILIKE '%farmacia@sitraluz.pe%';

UPDATE public.profiles
SET rol = 'ALMACEN',
    nombre = 'Sr. Roberto Paredes',
    areas_asignadas = ARRAY['Almacén General'],
    activo = true
WHERE email ILIKE '%almacen@sitraluz.pe%';

UPDATE public.profiles
SET rol = 'ENFERMERIA',
    nombre = 'Lic. Ana Morales',
    areas_asignadas = ARRAY['UCI Adultos', 'SOP'],
    activo = true
WHERE email ILIKE '%enfermeria@sitraluz.pe%';

-- 4. Verificación de resultados
SELECT id, email, nombre, rol, areas_asignadas, activo
FROM public.profiles
ORDER BY rol ASC;
