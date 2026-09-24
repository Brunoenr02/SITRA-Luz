-- ============================================================================
-- SITRA-Luz • Sistema de Trazabilidad — Clínica La Luz (Sede Tacna)
-- Script de Creación y Configuración Completa de Base de Datos en Supabase (PostgreSQL)
-- ============================================================================
-- Instrucciones:
-- 1. Ingresa a tu proyecto en https://supabase.com
-- 2. Ve a la sección "SQL Editor" en el menú lateral izquierdo.
-- 3. Haz clic en "New Query", pega todo este contenido y presiona "Run".
-- ============================================================================

-- 1. EXTENSIONES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. TABLA DE PERFILES DE USUARIO (Vinculada a auth.users)
-- Cada usuario creado en el módulo Authentication de Supabase tendrá su perfil aquí.
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    nombre TEXT NOT NULL,
    rol TEXT NOT NULL DEFAULT 'ENFERMERIA' CHECK (rol IN (
        'ADMINISTRADOR',
        'JEFATURA_FARMACIA',
        'FARMACIA',
        'ALMACEN',
        'ENFERMERIA'
    )),
    areas_asignadas TEXT[] DEFAULT '{}',
    fcm_token TEXT, -- Almacena el token de Firebase Cloud Messaging para Push Notifications
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3. TABLA DE ÁREAS / SERVICIOS CLÍNICOS
CREATE TABLE IF NOT EXISTS public.areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL, -- 'FARMACIA', 'ALMACEN', 'SOP', 'EMERGENCIA', 'HOSPITALIZACION', 'COCHE_PAROS'
    nombre TEXT NOT NULL,
    descripcion TEXT,
    stock_minimo_alerta INT NOT NULL DEFAULT 5,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 4. TABLA DE MÉDICOS (Para auditoría de fichas de dispensación)
CREATE TABLE IF NOT EXISTS public.doctores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    colegiatura TEXT, -- Ej: CMP-45892
    especialidad TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 5. TABLA MAESTRA DE MEDICAMENTOS (Catálogo con GTIN/GS1)
CREATE TABLE IF NOT EXISTS public.medicamentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gtin TEXT UNIQUE, -- Código de barras / GS1 Datamatrix escaneado por ML Kit
    nombre_comercial TEXT NOT NULL,
    principio_activo TEXT NOT NULL,
    forma_farmaceutica TEXT NOT NULL, -- 'Cápsula', 'Ampolla', 'Frasco Jarabe', 'Comprimido'
    concentracion TEXT, -- Ej: '500 mg', '1 g / 10 ml'
    registro_sanitario TEXT, -- Ej: 'RS-12345'
    unidad_presentacion TEXT NOT NULL DEFAULT 'unidades',
    cantidad_por_presentacion INT NOT NULL DEFAULT 1,
    requiere_cadena_frio BOOLEAN NOT NULL DEFAULT false,
    temperatura_min NUMERIC(4, 1) DEFAULT 2.0,
    temperatura_max NUMERIC(4, 1) DEFAULT 8.0,
    imagen_url TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_medicamentos_gtin ON public.medicamentos(gtin);
CREATE INDEX IF NOT EXISTS idx_medicamentos_nombre ON public.medicamentos(nombre_comercial);

-- 6. TABLA DE LOTES (Principio FEFO: First Expired, First Out)
CREATE TABLE IF NOT EXISTS public.lotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    medicamento_id UUID NOT NULL REFERENCES public.medicamentos(id) ON DELETE CASCADE,
    numero_lote TEXT NOT NULL,
    fecha_fabricacion DATE,
    fecha_vencimiento DATE NOT NULL,
    distribuidor TEXT,
    temperatura_recepcion NUMERIC(4, 1),
    observaciones TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    fecha_ingreso TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_medicamento_lote UNIQUE (medicamento_id, numero_lote)
);

CREATE INDEX IF NOT EXISTS idx_lotes_vencimiento ON public.lotes(fecha_vencimiento ASC);

-- 7. TABLA DE INVENTARIO Y STOCK POR ÁREA
CREATE TABLE IF NOT EXISTS public.inventario_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES public.lotes(id) ON DELETE CASCADE,
    area_codigo TEXT NOT NULL REFERENCES public.areas(codigo) ON UPDATE CASCADE,
    cantidad INT NOT NULL DEFAULT 0 CHECK (cantidad >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_lote_area UNIQUE (lote_id, area_codigo)
);

-- 8. TABLA DE PEDIDOS DE ABASTECIMIENTO (Farmacia Central -> Almacén General)
CREATE TABLE IF NOT EXISTS public.pedidos_abastecimiento (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL, -- Ej: 'PED-2026-001'
    solicitante_id UUID REFERENCES public.profiles(id),
    area_origen TEXT NOT NULL DEFAULT 'FARMACIA',
    area_destino TEXT NOT NULL DEFAULT 'ALMACEN',
    estado TEXT NOT NULL DEFAULT 'PENDIENTE' CHECK (estado IN ('PENDIENTE', 'DESPACHADO', 'RECIBIDO', 'RECHAZADO')),
    notas TEXT,
    motivo_rechazo TEXT,
    fecha_solicitud TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    fecha_despacho TIMESTAMPTZ,
    fecha_recepcion TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.pedidos_abastecimiento_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_id UUID NOT NULL REFERENCES public.pedidos_abastecimiento(id) ON DELETE CASCADE,
    medicamento_id UUID NOT NULL REFERENCES public.medicamentos(id),
    cantidad_solicitada INT NOT NULL CHECK (cantidad_solicitada > 0),
    cantidad_despachada INT NOT NULL DEFAULT 0 CHECK (cantidad_despachada >= 0)
);

-- 9. TABLA DE KITS PREARMADOS (Para Quirófano SOP, Coche de Paros, etc.)
CREATE TABLE IF NOT EXISTS public.kits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    area_destino TEXT NOT NULL, -- 'SOP', 'COCHE_PAROS', 'EMERGENCIA'
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.kit_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kit_id UUID NOT NULL REFERENCES public.kits(id) ON DELETE CASCADE,
    medicamento_id UUID NOT NULL REFERENCES public.medicamentos(id),
    cantidad INT NOT NULL DEFAULT 1 CHECK (cantidad > 0)
);

-- 10. TABLA DE FICHAS DE DISPENSACIÓN (Áreas Críticas / Enfermería -> Farmacia)
CREATE TABLE IF NOT EXISTS public.dispensaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_ficha TEXT UNIQUE NOT NULL, -- Ej: 'FCH-2026-001'
    tipo TEXT NOT NULL CHECK (tipo IN ('KIT', 'INDIVIDUAL')),
    kit_id UUID REFERENCES public.kits(id),
    area_origen TEXT NOT NULL, -- Área que solicita: 'SOP', 'EMERGENCIA', etc.
    doctor_id UUID REFERENCES public.doctores(id),
    paciente_nombre TEXT NOT NULL,
    diagnostico_motivo TEXT,
    prioridad TEXT NOT NULL DEFAULT 'NORMAL' CHECK (prioridad IN ('NORMAL', 'URGENTE')),
    estado TEXT NOT NULL DEFAULT 'SOLICITADO' CHECK (estado IN (
        'SOLICITADO',
        'EN_PREPARACION',
        'LISTO_PARA_RECOJO',
        'ENTREGADO',
        'CANCELADO'
    )),
    foto_salida_url TEXT,
    solicitado_por UUID REFERENCES public.profiles(id),
    entregado_por UUID REFERENCES public.profiles(id),
    recibido_por TEXT, -- Nombre de la enfermera/técnico que recoge
    observaciones TEXT,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    fecha_entrega TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.dispensacion_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispensacion_id UUID NOT NULL REFERENCES public.dispensaciones(id) ON DELETE CASCADE,
    medicamento_id UUID NOT NULL REFERENCES public.medicamentos(id),
    cantidad_solicitada INT NOT NULL CHECK (cantidad_solicitada > 0),
    cantidad_entregada INT NOT NULL DEFAULT 0 CHECK (cantidad_entregada >= 0)
);

-- 11. TABLA DE TRAZABILIDAD Y AUDITORÍA INMUTABLE
CREATE TABLE IF NOT EXISTS public.auditoria_trazabilidad (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tipo_evento TEXT NOT NULL, -- 'INGRESO_ALMACEN', 'TRANSFERENCIA_FARMACIA', 'DISPENSACION_AREA', 'AJUSTE_STOCK'
    medicamento_id UUID REFERENCES public.medicamentos(id),
    lote_id UUID REFERENCES public.lotes(id),
    usuario_id UUID REFERENCES public.profiles(id),
    area_origen TEXT,
    area_destino TEXT,
    cantidad INT,
    descripcion TEXT,
    detalles JSONB DEFAULT '{}'::jsonb,
    fecha TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_auditoria_fecha ON public.auditoria_trazabilidad(fecha DESC);

-- ============================================================================
-- 12. TRIGGERS Y FUNCIONES AUTOMÁTICAS
-- ============================================================================

-- Trigger para crear automáticamente el perfil al registrarse un usuario en auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_rol TEXT;
    user_nombre TEXT;
    user_areas TEXT[];
BEGIN
    -- Determinar rol según metadata o inferir automáticamente por email
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

    -- Determinar nombre por defecto según rol
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

    -- Determinar áreas asignadas según rol
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

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- 13. POLÍTICAS DE SEGURIDAD ROW LEVEL SECURITY (RLS)
-- ============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medicamentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventario_stock ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos_abastecimiento ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos_abastecimiento_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kit_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispensaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispensacion_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auditoria_trazabilidad ENABLE ROW LEVEL SECURITY;

-- Políticas para perfiles: todos los autenticados pueden ver perfiles, y editar el suyo propio
CREATE POLICY "Permitir lectura de perfiles a usuarios autenticados" 
    ON public.profiles FOR SELECT TO authenticated USING (true);

CREATE POLICY "Permitir a cada usuario actualizar su propio perfil y FCM token" 
    ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);

-- Políticas para lectura de catálogos y stock a cualquier usuario autenticado
CREATE POLICY "Lectura de áreas a usuarios autenticados" ON public.areas FOR SELECT TO authenticated USING (true);
CREATE POLICY "Lectura de doctores a usuarios autenticados" ON public.doctores FOR SELECT TO authenticated USING (true);
CREATE POLICY "Lectura de medicamentos a usuarios autenticados" ON public.medicamentos FOR SELECT TO authenticated USING (true);
CREATE POLICY "Escritura de medicamentos a usuarios autenticados" ON public.medicamentos FOR ALL TO authenticated USING (true);

CREATE POLICY "Lectura de lotes a usuarios autenticados" ON public.lotes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Escritura de lotes a usuarios autenticados" ON public.lotes FOR ALL TO authenticated USING (true);

CREATE POLICY "Lectura de inventario a usuarios autenticados" ON public.inventario_stock FOR SELECT TO authenticated USING (true);
CREATE POLICY "Escritura de inventario a usuarios autenticados" ON public.inventario_stock FOR ALL TO authenticated USING (true);

CREATE POLICY "Acceso total a pedidos para autenticados" ON public.pedidos_abastecimiento FOR ALL TO authenticated USING (true);
CREATE POLICY "Acceso total a items de pedidos para autenticados" ON public.pedidos_abastecimiento_items FOR ALL TO authenticated USING (true);

CREATE POLICY "Lectura de kits para autenticados" ON public.kits FOR SELECT TO authenticated USING (true);
CREATE POLICY "Lectura de kit_items para autenticados" ON public.kit_items FOR SELECT TO authenticated USING (true);

CREATE POLICY "Acceso total a dispensaciones para autenticados" ON public.dispensaciones FOR ALL TO authenticated USING (true);
CREATE POLICY "Acceso total a items de dispensacion para autenticados" ON public.dispensacion_items FOR ALL TO authenticated USING (true);

CREATE POLICY "Lectura e inserción de auditoría para autenticados" ON public.auditoria_trazabilidad FOR ALL TO authenticated USING (true);

-- ============================================================================
-- 14. DATOS INICIALES (SEED DATA PARA PRUEBAS)
-- ============================================================================

-- Áreas clínicas de la Clínica La Luz
INSERT INTO public.areas (codigo, nombre, descripcion, stock_minimo_alerta) VALUES
('ALMACEN', 'Almacén General', 'Recepción de proveedores y custodia principal', 20),
('FARMACIA', 'Farmacia Central', 'Dispensación interna a pisos y pacientes', 15),
('SOP', 'Sala de Operaciones (Quirófano)', 'Procedimientos quirúrgicos programados y de urgencia', 5),
('EMERGENCIA', 'Servicio de Emergencias', 'Atención crítica continua 24 horas', 10),
('HOSPITALIZACION', 'Pabellón de Hospitalización', 'Habitaciones y camas de reposo clínico', 8),
('COCHE_PAROS', 'Coche de Paros / Reanimación', 'Medicamentos de soporte vital y emergencia extrema', 3)
ON CONFLICT (codigo) DO NOTHING;

-- Doctores de la clínica
INSERT INTO public.doctores (nombre, colegiatura, especialidad) VALUES
('Dr. Roberto Chávez Morales', 'CMP-34120', 'Cirugía General'),
('Dra. Vanessa Ortiz Paredes', 'CMP-42901', 'Anestesiología'),
('Dr. Marco Antonio Vega', 'CMP-28754', 'Traumatología y Ortopedia'),
('Dra. Sofía Benavides Ríos', 'CMP-51209', 'Medicina de Emergencia')
ON CONFLICT DO NOTHING;

-- Medicamentos maestros
INSERT INTO public.medicamentos (gtin, nombre_comercial, principio_activo, forma_farmaceutica, concentracion, registro_sanitario, unidad_presentacion, cantidad_por_presentacion, requiere_cadena_frio) VALUES
('7750215001234', 'Amoxicilina 500mg', 'Amoxicilina', 'Cápsula', '500 mg', 'RS-EE-04812', 'cápsulas', 100, false),
('7750215005678', 'Paracetamol 1g Inyectable', 'Paracetamol', 'Ampolla', '1 g / 100 ml', 'RS-EN-01294', 'ampollas', 1, false),
('7750215009012', 'Fentanilo 0.5mg/10ml', 'Citrato de Fentanilo', 'Ampolla', '0.05 mg / ml', 'RS-EE-09312', 'ampollas', 5, false),
('7750215003456', 'Insulina NPH Humana 100 UI/ml', 'Insulina Humana', 'Frasco', '100 UI / ml', 'RS-BE-01582', 'frascos', 1, true),
('7750215007890', 'Adrenalina 1mg/ml', 'Epinefrina', 'Ampolla', '1 mg / 1 ml', 'RS-EN-03481', 'ampollas', 10, false),
('7750215006543', 'Ceftriaxona 1g', 'Ceftriaxona Sódica', 'Frasco Ampolla', '1 g', 'RS-EE-07821', 'viales', 1, false)
ON CONFLICT (gtin) DO NOTHING;

-- Lotes iniciales para demostración (con fechas de vencimiento para alertas FEFO)
DO $$
DECLARE
    med_amox UUID;
    med_parac UUID;
    med_fenta UUID;
    med_insu UUID;
    med_adren UUID;
    lote_amox_id UUID;
    lote_parac_id UUID;
    lote_fenta_id UUID;
    lote_insu_id UUID;
BEGIN
    SELECT id INTO med_amox FROM public.medicamentos WHERE gtin = '7750215001234' LIMIT 1;
    SELECT id INTO med_parac FROM public.medicamentos WHERE gtin = '7750215005678' LIMIT 1;
    SELECT id INTO med_fenta FROM public.medicamentos WHERE gtin = '7750215009012' LIMIT 1;
    SELECT id INTO med_insu FROM public.medicamentos WHERE gtin = '7750215003456' LIMIT 1;

    IF med_amox IS NOT NULL THEN
        INSERT INTO public.lotes (medicamento_id, numero_lote, fecha_vencimiento, distribuidor)
        VALUES (med_amox, 'L2026-A15', CURRENT_DATE + INTERVAL '180 days', 'Distribuidora Médica Sur')
        ON CONFLICT (medicamento_id, numero_lote) DO NOTHING
        RETURNING id INTO lote_amox_id;

        IF lote_amox_id IS NOT NULL THEN
            INSERT INTO public.inventario_stock (lote_id, area_codigo, cantidad)
            VALUES (lote_amox_id, 'ALMACEN', 120), (lote_amox_id, 'FARMACIA', 40)
            ON CONFLICT (lote_id, area_codigo) DO UPDATE SET cantidad = EXCLUDED.cantidad;
        END IF;
    END IF;

    IF med_parac IS NOT NULL THEN
        -- Lote próximo a vencer (alerta preventiva en semáforo)
        INSERT INTO public.lotes (medicamento_id, numero_lote, fecha_vencimiento, distribuidor)
        VALUES (med_parac, 'L2025-P02', CURRENT_DATE + INTERVAL '20 days', 'Laboratorios Roche / Perú')
        ON CONFLICT (medicamento_id, numero_lote) DO NOTHING
        RETURNING id INTO lote_parac_id;

        IF lote_parac_id IS NOT NULL THEN
            INSERT INTO public.inventario_stock (lote_id, area_codigo, cantidad)
            VALUES (lote_parac_id, 'FARMACIA', 25)
            ON CONFLICT (lote_id, area_codigo) DO UPDATE SET cantidad = EXCLUDED.cantidad;
        END IF;
    END IF;

    IF med_insu IS NOT NULL THEN
        INSERT INTO public.lotes (medicamento_id, numero_lote, fecha_vencimiento, distribuidor)
        VALUES (med_insu, 'L2027-INS8', CURRENT_DATE + INTERVAL '300 days', 'Novo Nordisk')
        ON CONFLICT (medicamento_id, numero_lote) DO NOTHING
        RETURNING id INTO lote_insu_id;

        IF lote_insu_id IS NOT NULL THEN
            INSERT INTO public.inventario_stock (lote_id, area_codigo, cantidad)
            VALUES (lote_insu_id, 'ALMACEN', 30), (lote_insu_id, 'FARMACIA', 10)
            ON CONFLICT (lote_id, area_codigo) DO UPDATE SET cantidad = EXCLUDED.cantidad;
        END IF;
    END IF;
END $$;

-- Kits prearmados de demostración
INSERT INTO public.kits (nombre, descripcion, area_destino) VALUES
('Kit Cirugía General Estándar', 'Insumos y anestésicos para intervenciones de quirófano general', 'SOP'),
('Kit Reanimación Cardiopulmonar (RCP)', 'Medicamentos de primera línea para parada cardiorrespiratoria', 'COCHE_PAROS'),
('Kit Sutura y Urgencias Menores', 'Anestésicos locales y antibióticos profilácticos', 'EMERGENCIA')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 15. USUARIOS OFICIALES DEL SISTEMA (5 ROLES CLÍNICOS)
-- ============================================================================
DO $$
DECLARE
    uid_admin UUID := 'a0000000-0000-0000-0000-000000000001';
    uid_jefe UUID := 'a0000000-0000-0000-0000-000000000002';
    uid_farma UUID := 'a0000000-0000-0000-0000-000000000003';
    uid_almacen UUID := 'a0000000-0000-0000-0000-000000000004';
    uid_enferm UUID := 'a0000000-0000-0000-0000-000000000005';
BEGIN
    -- 1. Administrador (admin123)
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_admin, '00000000-0000-0000-0000-000000000000', 'admin@sitraluz.pe', crypt('admin123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Ing. Carlos Mendoza","rol":"ADMINISTRADOR","areas":"Sistemas,Auditoría"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- 2. Jefatura de Farmacia (jefe123)
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_jefe, '00000000-0000-0000-0000-000000000000', 'jefatura@sitraluz.pe', crypt('jefe123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Dra. Elena Ramos","rol":"JEFATURA_FARMACIA","areas":"Farmacia Central"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- 3. Farmacia (farma123)
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_farma, '00000000-0000-0000-0000-000000000000', 'farmacia@sitraluz.pe', crypt('farma123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Q.F. Manuel Flores","rol":"FARMACIA","areas":"Farmacia Central"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- 4. Almacén General (almacen123)
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_almacen, '00000000-0000-0000-0000-000000000000', 'almacen@sitraluz.pe', crypt('almacen123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Sr. Roberto Paredes","rol":"ALMACEN","areas":"Almacén General"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;

    -- 5. Enfermería / Técnico (enfermera123)
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud)
    VALUES (uid_enferm, '00000000-0000-0000-0000-000000000000', 'enfermeria@sitraluz.pe', crypt('enfermera123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"nombre":"Lic. Ana Morales","rol":"ENFERMERIA","areas":"UCI Adultos,SOP"}', now(), now(), 'authenticated', 'authenticated')
    ON CONFLICT (id) DO NOTHING;
END $$;

-- Asegurar actualización de perfiles con roles específicos
UPDATE public.profiles SET rol = 'ADMINISTRADOR', nombre = 'Ing. Carlos Mendoza', areas_asignadas = ARRAY['Sistemas', 'Auditoría'], activo = true WHERE email ILIKE '%admin@sitraluz.pe%';
UPDATE public.profiles SET rol = 'JEFATURA_FARMACIA', nombre = 'Dra. Elena Ramos', areas_asignadas = ARRAY['Farmacia Central'], activo = true WHERE email ILIKE '%jefatura@sitraluz.pe%';
UPDATE public.profiles SET rol = 'FARMACIA', nombre = 'Q.F. Manuel Flores', areas_asignadas = ARRAY['Farmacia Central'], activo = true WHERE email ILIKE '%farmacia@sitraluz.pe%';
UPDATE public.profiles SET rol = 'ALMACEN', nombre = 'Sr. Roberto Paredes', areas_asignadas = ARRAY['Almacén General'], activo = true WHERE email ILIKE '%almacen@sitraluz.pe%';
UPDATE public.profiles SET rol = 'ENFERMERIA', nombre = 'Lic. Ana Morales', areas_asignadas = ARRAY['UCI Adultos', 'SOP'], activo = true WHERE email ILIKE '%enfermeria@sitraluz.pe%';

