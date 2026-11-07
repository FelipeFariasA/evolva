-- Evolva por suscripción de Apps One.
-- Sin suscripción vigente (o rol de administrador) no se puede crear ni modificar nada en Evolva.
-- Leer, exportar y eliminar los propios datos sigue permitido: los datos de salud son de la persona.

-- Evolva en el catálogo de Apps One, inactiva y sin plan: el plan, el precio y la categoría
-- se definen en la administración de Apps One antes de activarla.
insert into public.aplicaciones (id, categoria_id, nombre, descripcion, url, activa)
values ('evolva', null, 'Evolva',
        'Rutinas por niveles, alimentación y un semáforo semanal que te dice si estás evolucionando.',
        'https://evolva-phi.vercel.app', false)
on conflict (id) do nothing;

-- ¿La persona conectada puede usar Evolva? Suscripción vigente o administrador de Apps One.
create or replace function evolva.con_acceso()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.tiene_acceso('evolva') or public.es_admin();
$$;
revoke execute on function evolva.con_acceso() from public, anon;
grant execute on function evolva.con_acceso() to authenticated;

-- Políticas: lectura y baja propias siempre; alta y cambio solo con acceso.
drop policy "perfil propio" on evolva.perfiles;
create policy "perfil propio lectura" on evolva.perfiles for select to authenticated
  using (id = (select auth.uid()));
create policy "perfil propio baja" on evolva.perfiles for delete to authenticated
  using (id = (select auth.uid()));
create policy "perfil propio alta" on evolva.perfiles for insert to authenticated
  with check (id = (select auth.uid()) and (select evolva.con_acceso()));
create policy "perfil propio cambio" on evolva.perfiles for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()) and (select evolva.con_acceso()));

drop policy "sesiones propias" on evolva.sesiones;
drop policy "series propias" on evolva.series;
drop policy "mediciones propias" on evolva.mediciones;
drop policy "registros propios" on evolva.registros_alimento;

do $$
declare
  t text;
begin
  foreach t in array array['sesiones', 'series', 'mediciones', 'registros_alimento'] loop
    execute format('create policy "propios lectura" on evolva.%I for select to authenticated using (usuario_id = (select auth.uid()))', t);
    execute format('create policy "propios baja" on evolva.%I for delete to authenticated using (usuario_id = (select auth.uid()))', t);
    execute format('create policy "propios alta" on evolva.%I for insert to authenticated with check (usuario_id = (select auth.uid()) and (select evolva.con_acceso()))', t);
    execute format('create policy "propios cambio" on evolva.%I for update to authenticated using (usuario_id = (select auth.uid())) with check (usuario_id = (select auth.uid()) and (select evolva.con_acceso()))', t);
  end loop;
end $$;

drop policy "alimentos propios alta" on evolva.alimentos;
drop policy "alimentos propios cambio" on evolva.alimentos;
create policy "alimentos propios alta" on evolva.alimentos for insert to authenticated
  with check (usuario_id = (select auth.uid()) and (select evolva.con_acceso()));
create policy "alimentos propios cambio" on evolva.alimentos for update to authenticated
  using (usuario_id = (select auth.uid())) with check (usuario_id = (select auth.uid()) and (select evolva.con_acceso()));

drop policy "cambios propios alta" on evolva.cambios_nivel;
create policy "cambios propios alta" on evolva.cambios_nivel for insert to authenticated
  with check (usuario_id = (select auth.uid()) and (select evolva.con_acceso()));

-- Las funciones que escriben (security definer) también exigen acceso.

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
  if not evolva.con_acceso() then raise exception 'Necesitas una suscripción activa a Evolva en Apps One' using errcode = '42501'; end if;
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

create or replace function evolva.evaluar_mi_semana(p_semana date default current_date)
returns evolva.evaluaciones_semanales
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then raise exception 'Sin sesión'; end if;
  if not evolva.con_acceso() then raise exception 'Necesitas una suscripción activa a Evolva en Apps One' using errcode = '42501'; end if;
  return evolva.evaluar_semana(auth.uid(), coalesce(p_semana, current_date));
end;
$$;

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
  if not evolva.con_acceso() then raise exception 'Necesitas una suscripción activa a Evolva en Apps One' using errcode = '42501'; end if;
  if p_nivel not in ('principiante', 'intermedio', 'avanzado') then raise exception 'Nivel no válido'; end if;
  select * into p from evolva.perfiles where id = auth.uid();
  if p.nivel = p_nivel then return p; end if;
  insert into evolva.cambios_nivel (usuario_id, nivel_anterior, nivel_nuevo, motivo)
  values (auth.uid(), p.nivel, p_nivel, p_motivo);
  update evolva.perfiles set nivel = p_nivel where id = auth.uid() returning * into p;
  return p;
end;
$$;
