---
version: 1
slug: "index-html"
primary_target: "index.html"
related_targets: []
---

# Evolva app (index.html)

Scope: toda la app web móvil (ingreso, onboarding, Inicio, Rutina, Comida, Progreso, Perfil, sin suscripción). Modo: Operate.
Audiencia y tarea: clientes de Apps One que entrenan sin asesoría; registran series, comidas y peso en el teléfono y miran cada semana si avanzan.
Restricciones: no verse de gimnasio rudo ni clínico; semáforo legible al instante y nunca solo por color; ilustraciones de ejercicios propias.
Escena: gimnasio con luz fluorescente, el Metro de camino, la casa de noche: shell azul noche por defecto, tema porcelana cuando el sistema pide claro.

## Direction contract

THESIS: El progreso es un viaje en Metro: los niveles son estaciones, la semana es un tramo y el semáforo es el estado del servicio. Rechaza el tablero oscuro de anillos y tarjetas de las apps de fitness.

OWN-WORLD: Esmalte azul noche (#0E1A3A) como suelo y barra, porcelana (#F4F1EA) para la placa de estado, una línea de color por objetivo (Fuerza cobalto, Bajar grasa café, Movilidad turquesa) y los estados verde, ámbar y rojo solo para el servicio. Overpass (herencia de señalética vial) con números tabulares grandes. Rieles de 6 px, estaciones circulares con borde grueso, pictogramas blancos sobre placa de color.

STORY: La persona entiende en un vistazo en qué estación está, cuánto falta para la próxima y si su semana corre normal, con demoras o interrumpida, y por qué; luego aborda la sesión de hoy.

FIRST VIEWPORT: Barra azul noche con EVOLVA y la insignia de línea. Debajo, el diagrama de línea Principiante–Intermedio–Avanzado a todo el ancho con el tren marcando el avance. Luego la placa de porcelana del servicio: puntaje grande, estado en palabras y su motivo. Después los tres ramales (entrenamiento, nutrición, cuerpo) y las estaciones L–D de la semana. Acción principal: Entrenar hoy, al pie del viewport. Navegación inferior estándar.

FORM: Mapa de Metro (challenger competitivo, fuera de la lista propia; fusionado con el plano y el estado de servicio del Metro de Santiago). seed:e776859111122862

SIGNATURE: el diagrama de línea en tres lugares y solo ahí: avance de nivel en Inicio, la ruta de ejercicios en Rutina y el historial de semanas en Progreso. Comida y Perfil usan controles estándar dentro del mismo sistema.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
