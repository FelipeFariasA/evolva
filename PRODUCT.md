# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Clientes de Apps One que contratan Evolva por suscripción: adultos que entrenan por su cuenta, sin entrenador ni nutricionista, y usan la app en el teléfono durante el día (al entrenar, al comer, al pesarse). Su trabajo es saber cuándo subir la dificultad de los ejercicios y ver si su alimentación está acompañando el progreso.

## Product Purpose

Evolva acompaña entrenamiento y alimentación en un solo lugar y le dice a la persona, con evidencia, si está evolucionando o no. Resuelve dos problemas: no saber cuándo subir de nivel y no ver cómo la comida afecta los resultados. El éxito es que la persona entienda cada semana dónde está y qué ajustar, y que las reglas de progresión le sirvan (la hipótesis central que valida el MVP).

## Positioning

Un semáforo de evolución semanal (verde, amarillo, rojo) que cruza entrenamiento (40%), nutrición (30%) y cuerpo (30%) y siempre explica la causa. Las decisiones de nivel (subir, mantener, bajar) las toma un motor de reglas determinista y auditable en la base de datos, no la IA; los umbrales viven en configuración versionada (`evolva.config`), no en el código.

## Operating Context

- Uso en el teléfono, a menudo con prisa: registrar series durante el entrenamiento, comidas a lo largo del día y el peso al menos una vez por semana.
- Funciona sin conexión para el registro de series: se guardan en el teléfono y se sincronizan al volver.
- La evaluación semanal la recalcula un job programado cada lunes; la app también la calcula al abrir Inicio.
- Ingreso con enlace al correo, usando la misma cuenta de Apps One.

## Capabilities and Constraints

- Pantallas: Inicio (semáforo, anillos, avance al siguiente nivel, racha), Rutina (niveles Principiante, Intermedio y Avanzado; días A/B; series con repeticiones, carga y RPE 1–10; reporte de dolor), Comida (metas de calorías y macros, registro por desayuno, almuerzo, colación y cena, base propia más Open Food Facts, sugerencia para la próxima comida), Progreso (mediciones, curvas, historial del semáforo) y Perfil (exportar y eliminar datos).
- Objetivos: fuerza, bajar grasa y movilidad.
- Reglas de progresión (ventana de 3 semanas): subir con adherencia ≥ 85%, techo de repeticiones en todas las series y RPE promedio ≤ 7; bajar con adherencia < 60% por 2 semanas o dolor reportado. Umbrales iniciales, pendientes de calibrar con usuarios reales.
- Datos en Supabase, proyecto `apps-one`, schema `evolva`, con acceso por fila (RLS) por usuario. Publicado en Vercel (proyecto `evolva`).
- Acceso por suscripción de Apps One. **Pendiente:** la app aún no verifica `tiene_acceso('evolva')`; hoy entra cualquier cuenta con sesión.
- Plataforma: web instalable por ahora. **Decisión abierta:** pasar a app nativa (Flutter o React Native) en una fase posterior.
- La IA (Claude) solo redactará sugerencias de comida y el resumen semanal, con datos resumidos; nunca decide niveles ni modifica datos. Aún no implementada.
- Fases posteriores: escaneo de código de barras y consulta de Open Food Facts desde el backend.

## Brand Commitments

- Nombre: Evolva. Idioma: español de Chile.
- Voz directa y alentadora, sin premiar la restricción: explica el porqué de cada color y decisión.
- Aviso visible de que no reemplaza a un profesional de la salud; derivar a médico o nutricionista ante dolor, lesiones o metas extremas.

## Evidence on Hand

- Documento de producto: nota de Obsidian "App de salud: rutinas por niveles y alimentación" (07-11-2026).
- Catálogo inicial en `supabase/migrations/20261107000100_evolva_catalogo.sql`: 39 ejercicios, 18 rutinas A/B y 35 alimentos con valores aproximados.
- No hay usuarios reales, testimonios, métricas de uso ni resultados clínicos: no inventarlos.

## Product Principles

1. Las decisiones de progreso son deterministas y explicables; la persona siempre ve la razón.
2. La salud va primero: piso seguro de calorías, nada de dietas muy restrictivas y derivación a profesionales cuando corresponde.
3. Registrar debe tomar segundos en el teléfono, incluso sin conexión.
4. Los datos de salud son de la persona: consentimiento explícito, acceso solo propio, exportar y eliminar cuando quiera.
5. Los umbrales son supuestos a validar; se ajustan en configuración, sin publicar una versión nueva.

## Accessibility & Inclusion

- Uso móvil con una mano: objetivos táctiles de al menos 44 px.
- El semáforo nunca depende solo del color: siempre lleva puntaje, texto y motivo.
- Respetar el modo de movimiento reducido y los modos claro y oscuro del sistema.
