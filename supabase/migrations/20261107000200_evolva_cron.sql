-- Evaluación semanal programada: cada lunes 10:00 UTC (7:00 en Chile) evalúa la semana anterior.
create extension if not exists pg_cron;

select cron.schedule(
  'evolva-evaluacion-semanal',
  '0 10 * * 1',
  $$select evolva.evaluar_todos(current_date - 7)$$
);
