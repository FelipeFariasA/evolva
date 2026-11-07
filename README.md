# Evolva

App móvil (web instalable) que acompaña entrenamiento y alimentación en un solo lugar y dice, con evidencia, si la persona está evolucionando. Su diferenciador es el **semáforo de evolución** semanal, que cruza entrenamiento, nutrición y medidas corporales.

**Producción:** <https://evolva-phi.vercel.app> (Vercel, proyecto `evolva`; publica automáticamente cada cambio en `main`).

## Pantallas

- **Inicio:** puntaje semanal con semáforo, anillos de entrenamiento, nutrición y cuerpo, barra de avance al siguiente nivel, racha de días y la causa principal del color.
- **Rutina:** selector de nivel y día (A/B), ejercicios con variantes más fácil y más difícil, registro de series (repeticiones, carga, RPE 1–10), reporte de dolor. Funciona sin conexión: la sesión se guarda en el teléfono y se sincroniza al volver.
- **Comida:** calorías y macros con colores de alerta, registro por comida (desayuno, almuerzo, colación, cena), base de alimentos propia más Open Food Facts, y una sugerencia para la próxima comida.
- **Progreso:** mediciones (peso, cintura, % grasa), curva de peso con promedio de 3 semanas, volumen semanal, cargas por ejercicio e historial del semáforo.
- **Perfil:** objetivo, nivel, datos corporales, metas, exportar y eliminar datos.

## Arquitectura

- **`index.html`**: la app completa (HTML, CSS y JS). Usa supabase-js 2.45.4 desde CDN.
- **Supabase** (proyecto `apps-one`, schema `evolva`): Postgres, inicio de sesión con enlace al correo y RLS por usuario.
- La clave de `index.html` es la **clave publicable**: es pública por diseño. Los permisos los aplica la base de datos.

### Motor de reglas (en la base de datos)

Las decisiones son deterministas y auditables, no de IA. Los umbrales viven en `evolva.config` (clave `reglas`), así se calibran sin publicar una nueva versión.

| Función | Qué hace |
|---|---|
| `evaluar_semana(usuario, semana)` | Calcula el puntaje 0–100 (entreno 40%, nutrición 30%, cuerpo 30%), el color y la decisión de nivel (subir, mantener, bajar) con sus motivos. Guarda en `evaluaciones_semanales`. |
| `evaluar_mi_semana(fecha)` | La misma evaluación, solo para la persona con sesión. La app la llama al abrir Inicio. |
| `evaluar_todos(semana)` | Evalúa a todos; la ejecuta un job semanal de `pg_cron` (lunes). |
| `calcular_mi_meta()` | Metas de calorías y macros (Mifflin-St Jeor), con piso seguro de calorías. |
| `cambiar_mi_nivel(nivel, motivo)` | Cambia el nivel y deja registro en `cambios_nivel`. |
| `eliminar_mis_datos()` | Borra todos los datos de Evolva de la persona. |

Reglas de progresión (ventana de 3 semanas):

| Decisión | Condición |
|---|---|
| Subir | Adherencia ≥ 85%, techo del rango de repeticiones en todas las series de la semana y RPE promedio ≤ 7 |
| Mantener | Lo demás |
| Bajar | Adherencia < 60% por 2 semanas completas, o dolor reportado |

Semáforo: verde ≥ 70, amarillo 45–69, rojo < 45. El componente corporal usa el promedio móvil de 3 semanas del peso.

### Base de datos

Migraciones en [`supabase/migrations`](supabase/migrations):

| Tabla | Contenido |
|---|---|
| `perfiles` | Objetivo, nivel, sexo, nacimiento, estatura, peso inicial, actividad, lesiones, consentimiento |
| `ejercicios`, `rutinas`, `rutina_ejercicios` | Catálogo por nivel con variantes y rutinas A/B por objetivo y nivel |
| `sesiones`, `series` | Entrenamientos registrados (reps, carga, RPE, dolor) |
| `mediciones` | Peso, cintura, % grasa |
| `alimentos`, `registros_alimento`, `metas_nutricionales` | Base de alimentos (común y propia), registro diario y metas |
| `evaluaciones_semanales`, `cambios_nivel` | Resultado del motor de reglas y cambios de nivel |
| `config` | Umbrales versionados |

## Puesta en marcha

Ya hecho el 07-11-2026:

1. Migraciones aplicadas en el proyecto `apps-one` (incluye `pg_cron` con el job `evolva-evaluacion-semanal`, lunes 10:00 UTC).
2. Schema `evolva` agregado en **Data API → Exposed schemas**.
3. `https://evolva-phi.vercel.app/**` agregada en **Authentication → URL Configuration → Redirect URLs**.
4. Vercel: proyecto `evolva` conectado a este repositorio, sin build (sitio estático).

## Próximas fases

- Sugerencias de comida y resumen semanal redactados por Claude (solo con datos resumidos; nunca decide niveles).
- Consulta de Open Food Facts desde el backend y escaneo de código de barras.
- Calibrar umbrales con usuarios reales.

> Evolva no reemplaza a un profesional de la salud. Ante dolor, lesiones o metas extremas, deriva a un médico o nutricionista.
