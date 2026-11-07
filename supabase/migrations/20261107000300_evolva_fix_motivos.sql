-- Corrige la concatenación de motivos (text[] || 'literal' fallaba): usa array_append.
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
