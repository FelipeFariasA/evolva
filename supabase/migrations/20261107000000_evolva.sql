-- Evolva: rutinas por niveles, alimentación y semáforo de evolución.
-- Schema propio "evolva" dentro del proyecto Supabase apps-one.
-- Los datos de salud quedan protegidos por RLS: cada persona solo ve sus filas.

create schema if not exists evolva;
grant usage on schema evolva to anon, authenticated, service_role;

-- ---------------------------------------------------------------
-- Configuración versionada: los umbrales viven aquí, no en el código.
-- ---------------------------------------------------------------
create table evolva.config (
  clave text primary key,
  valor jsonb not null,
  version int not null default 1,
  actualizado_at timestamptz not null default now()
);

insert into evolva.config (clave, valor) values ('reglas', '{
  "sesiones_semana": 3,
  "ventana_semanas": 3,
  "subir_adherencia": 0.85,
  "subir_rpe_max": 7,
  "bajar_adherencia": 0.60,
  "bajar_semanas": 2,
  "peso_entreno": 0.40,
  "peso_nutricion": 0.30,
  "peso_cuerpo": 0.30,
  "verde_min": 70,
  "amarillo_min": 45,
  "tolerancia_kcal": 0.10,
  "proteina_min": 0.90,
  "kcal_piso_mujer": 1200,
  "kcal_piso_hombre": 1500
}'::jsonb);

-- ---------------------------------------------------------------
-- Usuario
-- ---------------------------------------------------------------
create table evolva.perfiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nombre text,
  objetivo text not null default 'fuerza' check (objetivo in ('fuerza', 'bajar_grasa', 'movilidad')),
  nivel text not null default 'principiante' check (nivel in ('principiante', 'intermedio', 'avanzado')),
  sexo text check (sexo in ('mujer', 'hombre')),
  fecha_nacimiento date,
  estatura_cm numeric(5,1) check (estatura_cm between 100 and 250),
  peso_inicial numeric(5,1) check (peso_inicial between 30 and 300),
  actividad text not null default 'moderada' check (actividad in ('baja', 'moderada', 'alta')),
  lesiones text,
  consentimiento_at timestamptz not null,
  creado_at timestamptz not null default now()
);

create table evolva.cambios_nivel (
  id bigint generated always as identity primary key,
  usuario_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  nivel_anterior text not null,
  nivel_nuevo text not null,
  motivo text,
  creado_at timestamptz not null default now()
);
create index on evolva.cambios_nivel (usuario_id);

-- ---------------------------------------------------------------
-- Catálogo de ejercicios y rutinas (lectura para usuarios con sesión)
-- ---------------------------------------------------------------
create table evolva.ejercicios (
  id bigint generated always as identity primary key,
  nombre text not null unique,
  grupo_muscular text not null,
  nivel text not null check (nivel in ('principiante', 'intermedio', 'avanzado')),
  unidad text not null default 'reps' check (unidad in ('reps', 'seg', 'min')),
  usa_carga boolean not null default false,
  descripcion text,
  mas_facil_id bigint references evolva.ejercicios (id),
  mas_dificil_id bigint references evolva.ejercicios (id)
);

create table evolva.rutinas (
  id bigint generated always as identity primary key,
  objetivo text not null check (objetivo in ('fuerza', 'bajar_grasa', 'movilidad')),
  nivel text not null check (nivel in ('principiante', 'intermedio', 'avanzado')),
  dia text not null check (dia in ('A', 'B')),
  nombre text not null,
  unique (objetivo, nivel, dia)
);

create table evolva.rutina_ejercicios (
  rutina_id bigint not null references evolva.rutinas (id) on delete cascade,
  ejercicio_id bigint not null references evolva.ejercicios (id),
  orden smallint not null,
  series smallint not null,
  reps_min smallint not null,
  reps_max smallint not null,
  primary key (rutina_id, ejercicio_id)
);
create index on evolva.rutina_ejercicios (ejercicio_id);

-- ---------------------------------------------------------------
-- Entrenamiento: sesión y series (RPE 1 a 10)
-- ---------------------------------------------------------------
create table evolva.sesiones (
  id bigint generated always as identity primary key,
  usuario_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  fecha date not null default current_date,
  rutina_id bigint references evolva.rutinas (id),
  dolor boolean not null default false,
  nota text,
  creado_at timestamptz not null default now()
);
create index on evolva.sesiones (usuario_id, fecha);
create index on evolva.sesiones (rutina_id);

create table evolva.series (
  id bigint generated always as identity primary key,
  sesion_id bigint not null references evolva.sesiones (id) on delete cascade,
  usuario_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  ejercicio_id bigint not null references evolva.ejercicios (id),
  n_serie smallint not null,
  reps numeric(6,1) not null check (reps >= 0),
  carga_kg numeric(6,1) check (carga_kg >= 0),
  rpe smallint check (rpe between 1 and 10),
  creado_at timestamptz not null default now()
);
create index on evolva.series (sesion_id);
create index on evolva.series (usuario_id);
create index on evolva.series (ejercicio_id);

-- ---------------------------------------------------------------
-- Cuerpo
-- ---------------------------------------------------------------
create table evolva.mediciones (
  id bigint generated always as identity primary key,
  usuario_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  fecha date not null default current_date,
  peso numeric(5,1) check (peso between 30 and 300),
  cintura_cm numeric(5,1) check (cintura_cm between 40 and 200),
  grasa_pct numeric(4,1) check (grasa_pct between 3 and 60),
  unique (usuario_id, fecha)
);

-- ---------------------------------------------------------------
-- Nutrición
-- ---------------------------------------------------------------
create table evolva.alimentos (
  id bigint generated always as identity primary key,
  usuario_id uuid references auth.users (id) on delete cascade, -- null = base común
  nombre text not null,
  kcal numeric(6,1) not null check (kcal >= 0),       -- por 100 g
  proteina numeric(5,1) not null default 0 check (proteina >= 0),
  carbos numeric(5,1) not null default 0 check (carbos >= 0),
  grasas numeric(5,1) not null default 0 check (grasas >= 0),
  porcion_g numeric(6,1) not null default 100,
  fuente text not null default 'propio' check (fuente in ('base', 'propio', 'openfoodfacts'))
);
create index on evolva.alimentos (usuario_id);

create table evolva.registros_alimento (
  id bigint generated always as identity primary key,
  usuario_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  fecha date not null default current_date,
  comida text not null check (comida in ('desayuno', 'almuerzo', 'colacion', 'cena')),
  alimento_id bigint references evolva.alimentos (id) on delete set null,
  nombre text not null,
  gramos numeric(6,1) not null check (gramos > 0),
  kcal numeric(7,1) not null,
  proteina numeric(6,1) not null default 0,
  carbos numeric(6,1) not null default 0,
  grasas numeric(6,1) not null default 0,
  creado_at timestamptz not null default now()
);
create index on evolva.registros_alimento (usuario_id, fecha);
create index on evolva.registros_alimento (alimento_id);

create table evolva.metas_nutricionales (
  usuario_id uuid primary key references auth.users (id) on delete cascade,
  kcal int not null,
  proteina_g int not null,
  carbos_g int not null,
  grasas_g int not null,
  actualizado_at timestamptz not null default now()
);

-- ---------------------------------------------------------------
-- Evaluación semanal (la escribe solo el motor de reglas)
-- ---------------------------------------------------------------
create table evolva.evaluaciones_semanales (
  usuario_id uuid not null references auth.users (id) on delete cascade,
  semana date not null,                -- lunes de la semana
  nivel text not null,
  puntaje_entreno int not null,
  puntaje_nutricion int not null,
  puntaje_cuerpo int not null,
  puntaje int not null,
  color text not null check (color in ('verde', 'amarillo', 'rojo')),
  adherencia numeric(4,2) not null,
  sesiones int not null,
  decision text not null check (decision in ('subir', 'mantener', 'bajar')),
  progreso_nivel int not null,
  motivos text[] not null default '{}',
  motivo_decision text,
  reglas_version int not null,
  calculado_at timestamptz not null default now(),
  primary key (usuario_id, semana)
);

-- ---------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------
alter table evolva.config enable row level security;
alter table evolva.perfiles enable row level security;
alter table evolva.cambios_nivel enable row level security;
alter table evolva.ejercicios enable row level security;
alter table evolva.rutinas enable row level security;
alter table evolva.rutina_ejercicios enable row level security;
alter table evolva.sesiones enable row level security;
alter table evolva.series enable row level security;
alter table evolva.mediciones enable row level security;
alter table evolva.alimentos enable row level security;
alter table evolva.registros_alimento enable row level security;
alter table evolva.metas_nutricionales enable row level security;
alter table evolva.evaluaciones_semanales enable row level security;

create policy "config lectura" on evolva.config for select to authenticated using (true);
create policy "ejercicios lectura" on evolva.ejercicios for select to authenticated using (true);
create policy "rutinas lectura" on evolva.rutinas for select to authenticated using (true);
create policy "rutina_ejercicios lectura" on evolva.rutina_ejercicios for select to authenticated using (true);

create policy "perfil propio" on evolva.perfiles for all to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));
create policy "cambios propios lectura" on evolva.cambios_nivel for select to authenticated
  using (usuario_id = (select auth.uid()));
create policy "cambios propios alta" on evolva.cambios_nivel for insert to authenticated
  with check (usuario_id = (select auth.uid()));
create policy "sesiones propias" on evolva.sesiones for all to authenticated
  using (usuario_id = (select auth.uid())) with check (usuario_id = (select auth.uid()));
create policy "series propias" on evolva.series for all to authenticated
  using (usuario_id = (select auth.uid())) with check (usuario_id = (select auth.uid()));
create policy "mediciones propias" on evolva.mediciones for all to authenticated
  using (usuario_id = (select auth.uid())) with check (usuario_id = (select auth.uid()));
create policy "registros propios" on evolva.registros_alimento for all to authenticated
  using (usuario_id = (select auth.uid())) with check (usuario_id = (select auth.uid()));
create policy "alimentos lectura" on evolva.alimentos for select to authenticated
  using (usuario_id is null or usuario_id = (select auth.uid()));
create policy "alimentos propios alta" on evolva.alimentos for insert to authenticated
  with check (usuario_id = (select auth.uid()));
create policy "alimentos propios cambio" on evolva.alimentos for update to authenticated
  using (usuario_id = (select auth.uid())) with check (usuario_id = (select auth.uid()));
create policy "alimentos propios baja" on evolva.alimentos for delete to authenticated
  using (usuario_id = (select auth.uid()));
create policy "metas propias lectura" on evolva.metas_nutricionales for select to authenticated
  using (usuario_id = (select auth.uid()));
create policy "evaluaciones propias lectura" on evolva.evaluaciones_semanales for select to authenticated
  using (usuario_id = (select auth.uid()));

grant select on evolva.config, evolva.ejercicios, evolva.rutinas, evolva.rutina_ejercicios,
  evolva.metas_nutricionales, evolva.evaluaciones_semanales to authenticated;
grant select, insert on evolva.cambios_nivel to authenticated;
grant select, insert, update, delete on evolva.perfiles, evolva.sesiones, evolva.series,
  evolva.mediciones, evolva.alimentos, evolva.registros_alimento to authenticated;
grant usage on all sequences in schema evolva to authenticated;
grant all on all tables in schema evolva to service_role;

-- ---------------------------------------------------------------
-- Metas nutricionales: Mifflin-St Jeor con piso seguro de calorías
-- ---------------------------------------------------------------
create or replace function evolva.calcular_mi_meta()
returns evolva.metas_nutricionales
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  r jsonb;
  p evolva.perfiles;
  v_peso numeric;
  v_edad numeric;
  v_bmr numeric;
  v_kcal numeric;
  v_piso numeric;
  v_prot numeric;
  v_gras numeric;
  v_carb numeric;
  m evolva.metas_nutricionales;
begin
  if v_uid is null then raise exception 'Sin sesión'; end if;
  select * into p from evolva.perfiles where id = v_uid;
  if not found then raise exception 'Completa tu perfil primero'; end if;
  select valor into r from evolva.config where clave = 'reglas';

  select peso into v_peso from evolva.mediciones
   where usuario_id = v_uid and peso is not null order by fecha desc limit 1;
  v_peso := coalesce(v_peso, p.peso_inicial, 70);
  v_edad := coalesce(extract(year from age(p.fecha_nacimiento)), 30);

  v_bmr := 10 * v_peso + 6.25 * coalesce(p.estatura_cm, 168) - 5 * v_edad
           + case p.sexo when 'hombre' then 5 when 'mujer' then -161 else -78 end;
  v_kcal := v_bmr * case p.actividad when 'baja' then 1.375 when 'alta' then 1.725 else 1.55 end;
  v_kcal := case p.objetivo
              when 'bajar_grasa' then v_kcal - least(v_kcal * 0.15, 500)
              when 'fuerza' then v_kcal * 1.05
              else v_kcal end;
  v_piso := case p.sexo when 'hombre' then (r->>'kcal_piso_hombre')::numeric
                        else (r->>'kcal_piso_mujer')::numeric end;
  v_kcal := greatest(v_kcal, v_piso);

  v_prot := v_peso * case p.objetivo when 'bajar_grasa' then 2.0 when 'fuerza' then 1.8 else 1.4 end;
  v_gras := v_kcal * 0.28 / 9;
  v_carb := greatest((v_kcal - v_prot * 4 - v_gras * 9) / 4, 0);

  insert into evolva.metas_nutricionales (usuario_id, kcal, proteina_g, carbos_g, grasas_g, actualizado_at)
  values (v_uid, round(v_kcal / 10) * 10, round(v_prot), round(v_carb), round(v_gras), now())
  on conflict (usuario_id) do update
    set kcal = excluded.kcal, proteina_g = excluded.proteina_g, carbos_g = excluded.carbos_g,
        grasas_g = excluded.grasas_g, actualizado_at = now()
  returning * into m;
  return m;
end;
$$;

-- ---------------------------------------------------------------
-- Motor de reglas: semáforo semanal y decisión de nivel (determinista)
-- ---------------------------------------------------------------
create or replace function evolva.evaluar_semana(p_usuario uuid, p_semana date)
returns evolva.evaluaciones_semanales
language plpgsql
security definer
set search_path = ''
as $$
declare
  r jsonb;
  v_ver int;
  p evolva.perfiles;
  meta evolva.metas_nutricionales;
  ini date := date_trunc('week', p_semana)::date;
  fin date;
  v_ref date;
  ses_sem numeric;
  v_ventana int;
  inicio_usuario date;
  -- entrenamiento
  n_ses int;
  adh numeric;
  vol_act numeric;
  vol_ant numeric;
  s_prog numeric;
  s_ent numeric;
  -- nutrición
  den int;
  dias_reg int;
  dias_kcal int;
  dias_prot int;
  s_nut numeric;
  semanas_prot_baja int := 0;
  w date;
  ok_w int;
  reg_w int;
  -- cuerpo
  ma_act numeric;
  ma_ant numeric;
  cin_act numeric;
  cin_ant numeric;
  delta numeric;
  s_cue numeric;
  -- total
  total int;
  col text;
  mot text[] := '{}';
  -- progresión
  ventana_ini date;
  adh_v numeric;
  techo numeric;
  rpe_v numeric;
  dolor_v boolean;
  adh_bajas int := 0;
  dec text;
  mot_dec text;
  prog int;
  sig_nivel text;
  ant_nivel text;
  e evolva.evaluaciones_semanales;
begin
  select * into p from evolva.perfiles where id = p_usuario;
  if not found then raise exception 'Usuario sin perfil'; end if;
  select valor, version into r, v_ver from evolva.config where clave = 'reglas';
  select * into meta from evolva.metas_nutricionales where usuario_id = p_usuario;

  fin := ini + 7;
  ses_sem := (r->>'sesiones_semana')::numeric;
  v_ventana := (r->>'ventana_semanas')::int;
  inicio_usuario := date_trunc('week', p.creado_at)::date;
  -- última semana completa (la semana en curso no cuenta para bajar por adherencia)
  v_ref := case when fin > current_date then ini - 7 else ini end;

  -- ===== Entrenamiento (adherencia + progresión de cargas o repeticiones)
  select count(distinct s.id) into n_ses
    from evolva.sesiones s
   where s.usuario_id = p_usuario and s.fecha >= ini and s.fecha < fin
     and exists (select 1 from evolva.series x where x.sesion_id = s.id);
  adh := least(n_ses / ses_sem, 1);

  select coalesce(sum(x.reps * greatest(coalesce(x.carga_kg, 0), 1)), 0) into vol_act
    from evolva.series x join evolva.sesiones s on s.id = x.sesion_id
   where x.usuario_id = p_usuario and s.fecha >= ini and s.fecha < fin;
  select coalesce(sum(x.reps * greatest(coalesce(x.carga_kg, 0), 1)), 0) into vol_ant
    from evolva.series x join evolva.sesiones s on s.id = x.sesion_id
   where x.usuario_id = p_usuario and s.fecha >= ini - 7 and s.fecha < ini;

  s_prog := case
    when vol_act = 0 then 0
    when vol_ant = 0 then 70
    when vol_act >= vol_ant * 1.02 then 100
    when vol_act >= vol_ant * 0.95 then 60
    else 25 end;
  s_ent := adh * 100 * 0.6 + s_prog * 0.4;

  if n_ses = 0 then
    mot := array_append(mot, 'No registraste entrenamientos esta semana');
  elsif adh < (r->>'bajar_adherencia')::numeric then
    mot := array_append(mot, format('Hiciste %s de %s sesiones esta semana', n_ses, ses_sem::int));
  end if;
  if vol_ant > 0 and vol_act > 0 and vol_act < vol_ant * 0.95 then
    mot := array_append(mot, 'Las cargas o repeticiones bajaron frente a la semana anterior');
  end if;

  -- ===== Nutrición (días dentro de la meta calórica y de proteína)
  den := greatest(least(7, current_date - ini + 1), 1);
  if meta.usuario_id is null then
    s_nut := 0;
    mot := array_append(mot, 'Aún no tienes meta nutricional');
  else
    select count(*),
           count(*) filter (where abs(d.kcal - meta.kcal) <= meta.kcal * (r->>'tolerancia_kcal')::numeric),
           count(*) filter (where d.prot >= meta.proteina_g * (r->>'proteina_min')::numeric)
      into dias_reg, dias_kcal, dias_prot
      from (select fecha, sum(kcal) kcal, sum(proteina) prot
              from evolva.registros_alimento
             where usuario_id = p_usuario and fecha >= ini and fecha < fin
             group by fecha) d;
    s_nut := 50.0 * dias_kcal / den + 50.0 * dias_prot / den;
    if dias_reg = 0 then
      mot := array_append(mot, 'No registraste comidas esta semana');
    end if;

    -- proteína bajo la meta varias semanas seguidas
    for w in select generate_series(ini - 14, ini, interval '7 days')::date loop
      select count(*), count(*) filter (where d.prot >= meta.proteina_g * (r->>'proteina_min')::numeric)
        into reg_w, ok_w
        from (select fecha, sum(proteina) prot from evolva.registros_alimento
               where usuario_id = p_usuario and fecha >= w and fecha < w + 7 group by fecha) d;
      if reg_w > 0 and ok_w * 2 < reg_w then
        semanas_prot_baja := semanas_prot_baja + 1;
      else
        semanas_prot_baja := 0;
      end if;
    end loop;
    if semanas_prot_baja >= 2 then
      mot := array_append(mot, format('La proteína quedó bajo la meta %s semanas seguidas', semanas_prot_baja));
    elsif dias_reg > 0 and dias_prot * 2 < dias_reg then
      mot := array_append(mot, 'La proteína quedó bajo la meta la mayoría de los días');
    end if;
  end if;

  -- ===== Cuerpo (promedio móvil de 3 semanas, no un solo pesaje)
  select avg(peso), avg(cintura_cm) into ma_act, cin_act from evolva.mediciones
   where usuario_id = p_usuario and fecha >= ini - 14 and fecha < fin;
  select avg(peso), avg(cintura_cm) into ma_ant, cin_ant from evolva.mediciones
   where usuario_id = p_usuario and fecha >= ini - 21 and fecha < ini;

  if ma_act is null or ma_ant is null then
    s_cue := 50;
    mot := array_append(mot, 'Registra tu peso al menos una vez por semana para medir la tendencia');
  else
    delta := ma_act - ma_ant;
    if p.objetivo = 'bajar_grasa' then
      s_cue := case when delta < -1.0 then 70 when delta <= -0.2 then 100 when delta < 0.2 then 55 else 20 end;
      if cin_act is not null and cin_ant is not null and cin_act < cin_ant then
        s_cue := greatest(s_cue, 80);
      end if;
      if delta < -1.0 then
        mot := array_append(mot, 'Bajas más de 1 kg por semana: revisa que no estés comiendo muy poco');
      elsif delta >= 0.2 then
        mot := array_append(mot, 'El peso promedio de 3 semanas subió');
      elsif delta > -0.2 then
        mot := array_append(mot, 'El peso promedio de 3 semanas está estable');
      end if;
    elsif p.objetivo = 'fuerza' then
      s_cue := case when delta between -0.2 and 0.6 then 100 when delta > 0.6 then 60 else 40 end;
      if delta < -0.2 then mot := array_append(mot, 'Estás bajando de peso: puede frenar tu ganancia de fuerza'); end if;
    else
      s_cue := case when abs(delta) <= 0.5 then 100 else 60 end;
    end if;
  end if;

  total := round((r->>'peso_entreno')::numeric * s_ent
               + (r->>'peso_nutricion')::numeric * s_nut
               + (r->>'peso_cuerpo')::numeric * s_cue);
  col := case when total >= (r->>'verde_min')::int then 'verde'
              when total >= (r->>'amarillo_min')::int then 'amarillo'
              else 'rojo' end;

  -- ===== Progresión de nivel (ventana de 3 semanas)
  ventana_ini := greatest(ini - 7 * (v_ventana - 1), inicio_usuario);
  select count(distinct s.id) into n_ses
    from evolva.sesiones s
   where s.usuario_id = p_usuario and s.fecha >= ini - 7 * (v_ventana - 1) and s.fecha < fin
     and exists (select 1 from evolva.series x where x.sesion_id = s.id);
  adh_v := least(n_ses / (ses_sem * v_ventana), 1);

  -- techo del rango en todas las series de la semana
  select case when count(*) = 0 then 0
              else (count(*) filter (where x.reps >= re.reps_max))::numeric / count(*) end
    into techo
    from evolva.series x
    join evolva.sesiones s on s.id = x.sesion_id
    join evolva.rutina_ejercicios re on re.rutina_id = s.rutina_id and re.ejercicio_id = x.ejercicio_id
   where x.usuario_id = p_usuario and s.fecha >= ini and s.fecha < fin;

  select avg(x.rpe) into rpe_v
    from evolva.series x join evolva.sesiones s on s.id = x.sesion_id
   where x.usuario_id = p_usuario and s.fecha >= ini - 7 * (v_ventana - 1) and s.fecha < fin;

  select coalesce(bool_or(dolor), false) into dolor_v from evolva.sesiones
   where usuario_id = p_usuario and fecha >= ini - 7 * (v_ventana - 1) and fecha < fin;

  for w in select generate_series(v_ref - 7 * ((r->>'bajar_semanas')::int - 1), v_ref, interval '7 days')::date loop
    if w >= inicio_usuario then
      select count(distinct s.id) into n_ses from evolva.sesiones s
       where s.usuario_id = p_usuario and s.fecha >= w and s.fecha < w + 7
         and exists (select 1 from evolva.series x where x.sesion_id = s.id);
      if n_ses / ses_sem < (r->>'bajar_adherencia')::numeric then
        adh_bajas := adh_bajas + 1;
      end if;
    end if;
  end loop;

  sig_nivel := case p.nivel when 'principiante' then 'intermedio' when 'intermedio' then 'avanzado' end;
  ant_nivel := case p.nivel when 'avanzado' then 'intermedio' when 'intermedio' then 'principiante' end;

  if dolor_v then
    dec := 'bajar';
    mot_dec := 'Reportaste dolor: baja la intensidad o usa variantes más fáciles y consulta a un profesional de la salud';
  elsif adh_bajas >= (r->>'bajar_semanas')::int then
    dec := 'bajar';
    mot_dec := format('Tu adherencia estuvo bajo %s%% por %s semanas: conviene una rutina más llevadera',
                      round((r->>'bajar_adherencia')::numeric * 100), adh_bajas);
  elsif adh_v >= (r->>'subir_adherencia')::numeric and techo >= 1
        and coalesce(rpe_v, 99) <= (r->>'subir_rpe_max')::numeric then
    dec := 'subir';
    mot_dec := 'Cumpliste la adherencia, llegaste al techo de repeticiones y el esfuerzo fue moderado';
  else
    dec := 'mantener';
    mot_dec := case
      when adh_v < (r->>'subir_adherencia')::numeric
        then format('Para subir necesitas %s%% de adherencia en 3 semanas (llevas %s%%)',
                    round((r->>'subir_adherencia')::numeric * 100), round(adh_v * 100))
      when techo < 1
        then format('Te falta llegar al techo de repeticiones en todas las series (llevas %s%%)', round(techo * 100))
      else format('Tu esfuerzo percibido promedio es %s; para subir debe ser %s o menos',
                  round(rpe_v, 1), r->>'subir_rpe_max') end;
  end if;

  if dec = 'subir' and sig_nivel is null then
    dec := 'mantener';
    mot_dec := 'Estás en el nivel más alto: sigue progresando cargas o variantes más difíciles';
  elsif dec = 'bajar' and ant_nivel is null then
    mot_dec := mot_dec || '. Ya estás en Principiante: usa las variantes más fáciles'::text;
  end if;

  prog := round(100 * (
            least(adh_v / (r->>'subir_adherencia')::numeric, 1) * 0.4
          + coalesce(techo, 0) * 0.4
          + case when rpe_v is null then 0
                 when rpe_v <= (r->>'subir_rpe_max')::numeric then 1
                 else greatest(0, 1 - (rpe_v - (r->>'subir_rpe_max')::numeric) / 3) end * 0.2));

  insert into evolva.evaluaciones_semanales as ev (
    usuario_id, semana, nivel, puntaje_entreno, puntaje_nutricion, puntaje_cuerpo, puntaje, color,
    adherencia, sesiones, decision, progreso_nivel, motivos, motivo_decision, reglas_version, calculado_at)
  values (
    p_usuario, ini, p.nivel, round(s_ent), round(s_nut), round(s_cue), total, col,
    adh, (select count(distinct s.id) from evolva.sesiones s
           where s.usuario_id = p_usuario and s.fecha >= ini and s.fecha < fin
             and exists (select 1 from evolva.series x where x.sesion_id = s.id)),
    dec, prog, mot, mot_dec, v_ver, now())
  on conflict (usuario_id, semana) do update set
    nivel = excluded.nivel, puntaje_entreno = excluded.puntaje_entreno,
    puntaje_nutricion = excluded.puntaje_nutricion, puntaje_cuerpo = excluded.puntaje_cuerpo,
    puntaje = excluded.puntaje, color = excluded.color, adherencia = excluded.adherencia,
    sesiones = excluded.sesiones, decision = excluded.decision, progreso_nivel = excluded.progreso_nivel,
    motivos = excluded.motivos, motivo_decision = excluded.motivo_decision,
    reglas_version = excluded.reglas_version, calculado_at = now()
  returning * into e;
  return e;
end;
$$;

-- La persona solo puede evaluar su propia semana.
create or replace function evolva.evaluar_mi_semana(p_semana date default current_date)
returns evolva.evaluaciones_semanales
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then raise exception 'Sin sesión'; end if;
  return evolva.evaluar_semana(auth.uid(), coalesce(p_semana, current_date));
end;
$$;

-- Cambio de nivel decidido por la persona (siguiendo o no la recomendación).
create or replace function evolva.cambiar_mi_nivel(p_nivel text, p_motivo text default null)
returns evolva.perfiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  p evolva.perfiles;
begin
  if auth.uid() is null then raise exception 'Sin sesión'; end if;
  if p_nivel not in ('principiante', 'intermedio', 'avanzado') then raise exception 'Nivel no válido'; end if;
  select * into p from evolva.perfiles where id = auth.uid();
  if p.nivel = p_nivel then return p; end if;
  insert into evolva.cambios_nivel (usuario_id, nivel_anterior, nivel_nuevo, motivo)
  values (auth.uid(), p.nivel, p_nivel, p_motivo);
  update evolva.perfiles set nivel = p_nivel where id = auth.uid() returning * into p;
  return p;
end;
$$;

-- Evaluación programada de todas las personas (semana anterior).
create or replace function evolva.evaluar_todos(p_semana date default current_date - 7)
returns int
language plpgsql
security definer
set search_path = ''
as $$
declare
  u uuid;
  n int := 0;
begin
  for u in select id from evolva.perfiles loop
    perform evolva.evaluar_semana(u, p_semana);
    n := n + 1;
  end loop;
  return n;
end;
$$;

-- Eliminar todos los datos de Evolva de la persona (no borra su cuenta de Apps One).
create or replace function evolva.eliminar_mis_datos()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v uuid := auth.uid();
begin
  if v is null then raise exception 'Sin sesión'; end if;
  delete from evolva.series where usuario_id = v;
  delete from evolva.sesiones where usuario_id = v;
  delete from evolva.mediciones where usuario_id = v;
  delete from evolva.registros_alimento where usuario_id = v;
  delete from evolva.alimentos where usuario_id = v;
  delete from evolva.metas_nutricionales where usuario_id = v;
  delete from evolva.evaluaciones_semanales where usuario_id = v;
  delete from evolva.cambios_nivel where usuario_id = v;
  delete from evolva.perfiles where id = v;
end;
$$;

revoke execute on all functions in schema evolva from public, anon;
revoke execute on function evolva.evaluar_semana(uuid, date) from authenticated;
revoke execute on function evolva.evaluar_todos(date) from authenticated;
grant execute on function evolva.calcular_mi_meta() to authenticated;
grant execute on function evolva.evaluar_mi_semana(date) to authenticated;
grant execute on function evolva.cambiar_mi_nivel(text, text) to authenticated;
grant execute on function evolva.eliminar_mis_datos() to authenticated;
