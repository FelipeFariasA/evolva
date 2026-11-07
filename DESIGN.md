---
name: Evolva
description: Rutinas por niveles, alimentación y semáforo de evolución semanal, dibujados como un plano de Metro.
colors:
  noche: "#0e1a3a"
  noche-2: "#16244b"
  noche-3: "#26345f"
  porcelana: "#f4f1ea"
  plate: "#fbfaf7"
  line: "#d5d0c3"
  mut: "#4a5578"
  on-noche-mut: "#aab3cf"
  placa-rule: "#d9d3c4"
  placa-ink-2: "#3b4669"
  linea-fuerza: "#2f6fe4"
  linea-bajar-grasa: "#c0601e"
  linea-movilidad: "#0f8f9e"
  on-linea: "#ffffff"
  verde: "#1f9d5c"
  amarillo: "#f2b200"
  rojo: "#d93025"
  on-verde: "#ffffff"
  on-amarillo: "#0e1a3a"
  on-rojo: "#ffffff"
  line-dark: "#2b3a68"
  linea-fuerza-dark: "#5b8ff0"
  linea-bajar-grasa-dark: "#e08a4a"
  linea-movilidad-dark: "#2fc1d0"
  on-linea-dark: "#08112a"
  ring-fuerza-dark: "#9dbaf6"
  ring-bajar-grasa-dark: "#f0b58a"
  ring-movilidad-dark: "#8fe2ea"
  verde-dark: "#34c37a"
  amarillo-dark: "#ffc629"
  rojo-dark: "#ff6a5c"
  on-verde-dark: "#06210f"
  on-amarillo-dark: "#1c1500"
  on-rojo-dark: "#2a0606"
typography:
  display:
    fontFamily: "SepFix, Overpass, system-ui, sans-serif"
    fontSize: "48px"
    fontWeight: 900
    lineHeight: 0.9
    fontFeature: "tnum"
  display-login:
    fontFamily: "SepFix, Overpass, system-ui, sans-serif"
    fontSize: "40px"
    fontWeight: 900
    lineHeight: 1
  headline:
    fontFamily: "SepFix, Overpass, system-ui, sans-serif"
    fontSize: "28px"
    fontWeight: 800
    lineHeight: 1.1
    letterSpacing: "-0.01em"
  estado:
    fontFamily: "SepFix, Overpass, system-ui, sans-serif"
    fontSize: "26px"
    fontWeight: 900
    lineHeight: 1.05
    letterSpacing: "-0.01em"
  title:
    fontFamily: "SepFix, Overpass, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 800
    lineHeight: 1.1
    letterSpacing: "-0.01em"
  title-sm:
    fontFamily: "SepFix, Overpass, system-ui, sans-serif"
    fontSize: "18px"
    fontWeight: 700
    lineHeight: 1.1
  numeral:
    fontFamily: "SepFix, Overpass, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 900
    lineHeight: 1
    fontFeature: "tnum"
  body:
    fontFamily: "SepFix, Overpass, system-ui, -apple-system, Segoe UI, Roboto, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.5
    fontFeature: "tnum"
  label:
    fontFamily: "SepFix, Overpass, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.5
  caption:
    fontFamily: "SepFix, Overpass, system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 700
    lineHeight: 1.2
  wordmark:
    fontFamily: "SepFix, Overpass, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 900
    letterSpacing: "0.06em"
rounded:
  rail: "3px"
  tag: "4px"
  sm: "6px"
  md: "8px"
  lg: "10px"
  light: "12px"
  dialog: "14px"
  pill: "999px"
spacing:
  xxs: "4px"
  xs: "6px"
  sm: "8px"
  sm-plus: "10px"
  md: "12px"
  md-plus: "14px"
  gutter: "16px"
  lg: "20px"
  rail: "6px"
  column: "560px"
components:
  button-primary:
    backgroundColor: "{colors.linea-fuerza}"
    textColor: "{colors.on-linea}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: "12px 18px"
    height: "48px"
  button-secondary:
    backgroundColor: "color-mix(in srgb, #2f6fe4 14%, #fbfaf7)"
    textColor: "{colors.noche}"
    rounded: "{rounded.md}"
    padding: "12px 18px"
    height: "48px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.noche}"
    rounded: "{rounded.md}"
    padding: "12px 18px"
    height: "48px"
  button-danger:
    backgroundColor: "{colors.rojo}"
    textColor: "{colors.on-rojo}"
    rounded: "{rounded.md}"
    padding: "12px 18px"
    height: "48px"
  chip:
    backgroundColor: "{colors.plate}"
    textColor: "{colors.noche}"
    rounded: "{rounded.pill}"
    padding: "8px 14px"
    height: "44px"
  chip-on:
    backgroundColor: "{colors.linea-fuerza}"
    textColor: "{colors.on-linea}"
    rounded: "{rounded.pill}"
  input:
    backgroundColor: "{colors.plate}"
    textColor: "{colors.noche}"
    rounded: "{rounded.md}"
    padding: "11px 14px"
    height: "48px"
  top-bar:
    backgroundColor: "{colors.noche}"
    textColor: "{colors.porcelana}"
    padding: "12px 16px"
  tab-bar:
    backgroundColor: "{colors.noche}"
    textColor: "{colors.on-noche-mut}"
    height: "58px"
  placa:
    backgroundColor: "{colors.porcelana}"
    textColor: "{colors.noche}"
    rounded: "{rounded.lg}"
    padding: "16px"
  light-verde:
    backgroundColor: "{colors.verde}"
    textColor: "{colors.on-verde}"
    rounded: "{rounded.light}"
    size: "92px"
  light-amarillo:
    backgroundColor: "{colors.amarillo}"
    textColor: "{colors.on-amarillo}"
    rounded: "{rounded.light}"
    size: "92px"
  light-rojo:
    backgroundColor: "{colors.rojo}"
    textColor: "{colors.on-rojo}"
    rounded: "{rounded.light}"
    size: "92px"
  letrero:
    backgroundColor: "{colors.noche}"
    textColor: "{colors.porcelana}"
    rounded: "{rounded.lg}"
    padding: "14px 16px"
  picto:
    backgroundColor: "{colors.linea-fuerza}"
    textColor: "{colors.on-linea}"
    rounded: "{rounded.lg}"
    size: "48px"
  card:
    backgroundColor: "{colors.plate}"
    textColor: "{colors.noche}"
    rounded: "{rounded.lg}"
    padding: "18px 16px"
  dialog:
    backgroundColor: "{colors.plate}"
    textColor: "{colors.noche}"
    rounded: "{rounded.dialog}"
  toast:
    backgroundColor: "{colors.porcelana}"
    textColor: "{colors.noche}"
    rounded: "{rounded.md}"
    padding: "12px 18px"
---

# Design System: Evolva

## Overview

**Creative North Star: "Mapa de Metro"**

El progreso es un viaje en Metro. Los niveles (Principiante, Intermedio, Avanzado) son estaciones, la semana es un tramo y el semáforo de evolución es el estado del servicio: normal, con demoras o interrumpido. El sistema toma su vocabulario del plano y la señalética del Metro de Santiago: esmalte azul noche como suelo y barra, una placa de porcelana para el aviso de servicio, rieles de 6 px con estaciones circulares de borde grueso y una sola línea de color que identifica el objetivo de la persona. Rechaza a propósito el tablero oscuro de anillos y tarjetas de las apps de fitness, y también el tono de gimnasio rudo o de ficha clínica.

La densidad es de pantalla de teléfono usada con prisa y con una mano: una columna de 560 px como máximo, secciones separadas por filetes en vez de tarjetas apiladas, números grandes y tabulares, objetivos táctiles de 44 a 48 px. El shell (barra superior, diagrama de línea y navegación inferior) es siempre azul noche; el suelo cambia con el sistema: porcelana en modo claro, azul noche en modo oscuro. La placa de servicio se queda de porcelana en ambos modos: es el letrero fijo de la estación.

El color de estado (verde, ámbar, rojo) pertenece solo al servicio. Todo lo demás se dibuja con la línea del objetivo y con tinta neutra. El movimiento es corto y con freno suave, como un tren que llega al andén, y desaparece por completo cuando el sistema pide movimiento reducido.

**Key Characteristics:**
- Shell azul noche de borde a borde, también en escritorio, aunque la columna mida 560 px.
- Una línea de color por objetivo: Fuerza cobalto, Bajar grasa café, Movilidad turquesa.
- Verde, ámbar y rojo reservados al estado del servicio, siempre con puntaje, palabras y motivo.
- Overpass en pesos 800–900 para títulos y cifras, con números tabulares en toda la app.
- Rieles de 6 px y estaciones circulares con borde grueso como gramática gráfica recurrente.
- Plano, con sombra solo en la placa de servicio, el toast y las tarjetas del modo claro.

## Colors

Esmalte azul noche y porcelana como pareja fija, una sola línea de color por objetivo y tres colores de servicio que no se usan para nada más.

### Primary
- **Línea Fuerza, cobalto** (linea-fuerza): la línea por defecto (objetivo fuerza). Riel recorrido, estación actual, botón principal, chip activo, placa de pictograma, día entrenado, indicador de pestaña activa, cursor, `accent-color` y anillo de foco. En modo oscuro sube a un cobalto más claro (linea-fuerza-dark) con texto casi negro encima (on-linea-dark) y anillo de foco pálido (ring-fuerza-dark).
- **Línea Bajar grasa, café** (linea-bajar-grasa): reemplaza a la línea cobalto en todo el sistema cuando `data-obj="bajar_grasa"`; versión oscura linea-bajar-grasa-dark con anillo ring-bajar-grasa-dark.
- **Línea Movilidad, turquesa** (linea-movilidad): igual, con `data-obj="movilidad"`; versión oscura linea-movilidad-dark con anillo ring-movilidad-dark.

La línea vive en una sola variable de CSS (`--linea`, con `--on-linea` y `--ring`). Ningún componente nombra un color de objetivo directamente: todos leen `--linea`, y el objetivo de la persona la cambia en `:root[data-obj]`.

### Secondary
- **Verde servicio** (verde, texto on-verde): "Servicio normal". Solo en la luz del semáforo, la estación del historial, el letrero cuando toca subir y la alerta positiva.
- **Ámbar servicio** (amarillo, texto on-amarillo en azul noche): "Servicio con demoras". Luz del semáforo, estación del historial y alerta de aviso.
- **Rojo servicio** (rojo, texto on-rojo): "Servicio interrumpido". Luz del semáforo, estación del historial, letrero cuando toca bajar, alerta de error, botón de eliminar y el hover de quitar un alimento.

En modo oscuro los tres suben de luminosidad (verde-dark, amarillo-dark, rojo-dark) y su texto pasa a un tono muy oscuro del mismo matiz (on-verde-dark, on-amarillo-dark, on-rojo-dark).

### Neutral
- **Azul noche esmalte** (noche): barra superior, diagrama de línea, navegación inferior, letrero de próxima estación, cabecera de diálogos, pantalla de ingreso; también la tinta del texto en modo claro y el suelo en modo oscuro.
- **Azul noche medio** (noche-2): superficie de placas y diálogos en modo oscuro, y fondo del letrero en ese modo.
- **Azul noche riel** (noche-3): el riel sin recorrer, el borde de estaciones futuras y los botones secundarios sobre azul noche.
- **Porcelana** (porcelana): la placa de servicio en ambos modos, el suelo en modo claro, el texto sobre azul noche, el centro de las estaciones, el banderín del tren y el toast.
- **Porcelana clara** (plate): superficie de campos, chips, tarjetas y diálogos en modo claro.
- **Filete arena** (line): rieles de la semana, la ruta y el historial, filetes entre secciones, bordes de campos y chips, pista de barras. En modo oscuro, line-dark.
- **Tinta tenue** (mut): texto secundario, etiquetas, ejes de gráficos, pesajes sueltos. En modo oscuro y sobre azul noche se usa on-noche-mut.
- **Filete y tinta de placa** (placa-rule, placa-ink-2): el borde y el filete interior de la placa de servicio y el texto de sus motivos secundarios. Son fijos porque la placa es porcelana en ambos modos.

### Named Rules
**The Service Color Rule.** Verde, ámbar y rojo significan el estado del servicio y nada más. No se usan para decorar, para identificar ramales ni para pintar series de datos.

**The One Line Rule.** Hay una sola línea de color en pantalla: la del objetivo de la persona. Los ramales, las macros y la cintura se dibujan con tinta neutra (`--tx`); los pesajes sueltos con tinta tenue; la línea del objetivo queda para el avance, el promedio y el volumen.

**The Porcelain Plaque Rule.** La placa de servicio es porcelana con texto azul noche en modo claro y en modo oscuro. Es lo único que no se invierte.

## Typography

**Display Font:** Overpass (con system-ui)
**Body Font:** Overpass (con system-ui, -apple-system, Segoe UI, Roboto)
**Label/Mono Font:** la misma Overpass; no hay monoespaciada.

**Character:** una sola familia heredera de la señalética vial, trabajada en pesos 800 y 900 para títulos y cifras y en 400–700 para el texto. Se lee como un letrero de andén, no como una revista.

### Hierarchy
- **Display** (900, 48px, 0.9): el puntaje dentro de la luz del semáforo; en Comida, las calorías del día a 44px. Bajo 370 px de ancho, el puntaje baja a 40px.
- **Display ingreso** (900, 40px, 1): el titular de la pantalla de ingreso, con una palabra en el color de la línea; 34px bajo 370 px.
- **Headline** (800, 28px, 1.1, -0.01em): h1 de pantalla.
- **Estado** (900, 26px, 1.05, -0.01em): el estado del semáforo en palabras dentro de la placa ("Estancado"); 22px bajo 370 px.
- **Title** (800, 22px, 1.1): h2 de sección ("Ramales", "Esta semana", "Ruta de hoy").
- **Title pequeño** (700, 18px, 1.1): h3, nombre de cada ejercicio en la ruta, nombre de cada comida.
- **Numeral** (900, 22–26px, 1): cifras de ramales, KPI y puntaje del historial.
- **Body** (400, 16px, 1.5): texto corrido. Todos los campos usan 16px para que el teléfono no haga zoom.
- **Label** (600, 14px): etiquetas de campo en tinta tenue; metadatos de ejercicio y de ramal.
- **Caption** (700, 12px): nombres de estación bajo el riel, días L–D, cabeceras de la tabla de series (estas en mayúsculas con 0.06em), banderín del tren, etiquetas de pestaña (600, 800 la activa).
- **Wordmark** (900, 22px, 0.06em): EVOLVA en la barra; 20px y 0.08em en el ingreso.

### Named Rules
**The Tabular Numbers Rule.** `font-variant-numeric: tabular-nums` se aplica en `body` y lo hereda toda la app: puntajes, series, kilos y calorías se alinean como un horario.

**The SepFix Rule.** El punto medio "·" de Overpass queda pegado al texto siguiente, así que cada pila de fuentes empieza con "SepFix", una `@font-face` local (Segoe UI, Arial, Helvetica Neue o Roboto) limitada a U+00B7. El punto medio es el separador de la casa ("Entrenamiento · 40%", "· actual"); no se reemplaza por guiones ni barras.

## Layout

Una sola columna de 560 px como máximo, centrada, con 16px de margen lateral (20px desde 600 px de ancho). La barra superior y el diagrama de línea son bandas azul noche que llegan a ambos bordes de la ventana aunque la columna sea angosta (sombra de 100vmax recortada con `clip-path`). La navegación inferior es fija, con altura mínima de 58px por botón y respeta las zonas seguras (`env(safe-area-inset-*)`); el contenido reserva 92px más esa zona al pie.

El ritmo vertical se arma con secciones (20px arriba, 4px abajo) separadas por un filete de 1px en el color `line`, no con tarjetas. Los espacios recurrentes son 4, 6, 8, 10, 12, 14, 16 y 20px. Los rieles miden 6px de grosor en todos sus usos (línea de nivel, ramales, semana, ruta, historial y barras de calorías y macros). Los objetivos táctiles miden 44px como mínimo (chips, botones de ícono, quitar alimento, celdas de series) y 48px los botones y campos principales.

El primer viewport de Inicio sigue este orden: barra, diagrama de línea a todo el ancho, placa de servicio montada 12px sobre el diagrama, ramales, estaciones L–D de la semana, letrero de próxima estación y la acción principal ("Entrenar hoy") al pie.

## Elevation & Depth

Sistema plano con tres excepciones con función. La profundidad se logra con el contraste entre azul noche y porcelana, no con capas de sombra. La placa de servicio es el único objeto que "flota": se monta sobre el borde inferior del diagrama de línea con una sombra marcada. En modo oscuro la sombra de tarjeta (`--sh`) es `none`.

### Shadow Vocabulary
- **Tarjeta, solo modo claro** (`box-shadow: 0 1px 0 rgba(14,26,58,.06), 0 6px 18px rgba(14,26,58,.07)`): tarjetas de Perfil, onboarding y estados vacíos o de error.
- **Placa de servicio** (`box-shadow: 0 10px 28px rgba(14,26,58,.22)`): solo la placa montada sobre el diagrama.
- **Toast** (`box-shadow: 0 12px 30px rgba(8,14,34,.35)`): el aviso flotante de porcelana sobre la navegación.
- **Recorte de andén** (`box-shadow: 0 0 0 4px <suelo>`): anillo sólido del color del suelo alrededor de la estación actual, del pictograma y del número de ejercicio, para que "corten" el riel. No es sombra; es un recorte.

### Named Rules
**The Single Floating Plaque Rule.** Solo la placa de servicio se levanta sobre el resto. Comida y Progreso se componen con secciones y filetes; no apilan tarjetas con sombra suave.

## Shapes

Esquinas apenas redondeadas y círculos plenos. Los radios son pequeños y graduales: 6px (botón de quitar), 8px (botones, campos, alertas, toast), 10px (tarjetas, placa, letrero, pictogramas), 12px (la luz del semáforo) y 14px (diálogos). Los rieles terminan en 3px de radio y el banderín del tren y las etiquetas en 4px. Chips y estaciones son píldoras o círculos completos.

La silueta recurrente es la estación: un círculo de porcelana (o del suelo) con un borde grueso de 5 a 7px en el color de la línea, o en el riel sin recorrer cuando aún no se llega. Las estaciones se ensartan en rieles de 6px, horizontales (nivel, semana) o verticales (ruta de ejercicios, historial). Los bordes de campos y chips miden 1.5px.

## Components

### Buttons
Directos y llenos, con la línea del objetivo como único color.
- **Shape:** esquinas de 8px; alto mínimo 48px; texto 16px en peso 800.
- **Primary:** fondo de la línea (button-primary), texto on-linea.
- **Secondary:** la línea al 14% sobre la superficie, texto en tinta. Sobre azul noche (letrero) pasa a noche-3 con texto porcelana.
- **Ghost:** transparente con borde de 1.5px en `line`; sobre azul noche, borde noche-3 y texto porcelana.
- **Danger:** rojo de servicio con texto on-rojo; solo para eliminar.
- **Hover / Focus:** en dispositivos con hover, brillo 1.08 en 140ms; al presionar, escala 0.97 en 110ms. Foco visible con contorno de 3px en `--ring` y 2px de separación. Deshabilitado al 45% de opacidad. Mientras carga muestra un giro de 16px antes del texto.

### Chips
- **Style:** píldora con fondo plate, borde de 1.5px en `line`, 15px peso 600, alto 44px.
- **State:** activo con fondo y borde de la línea y texto on-linea en 800. El nivel actual de la persona agrega "· actual" detrás. Hover: el borde toma la línea.

### Cards / Containers
- **Corner Style:** 10px.
- **Background:** plate (noche-2 en modo oscuro).
- **Shadow Strategy:** sombra de tarjeta solo en modo claro (ver Elevation & Depth).
- **Border:** ninguno.
- **Internal Padding:** 18px 16px.
- Uso: Perfil, onboarding, formulario de ingreso (porcelana y sin sombra sobre azul noche) y estados vacíos. Inicio, Rutina, Comida y Progreso se componen con secciones y filetes.

### Inputs / Fields
- **Style:** fondo plate, borde de 1.5px en `line`, 8px de radio, 48px de alto, 16px de texto; placeholder en tinta tenue y cursiva.
- **Focus:** el borde toma la línea y aparece un halo de 3px de la línea al 28%, en 140ms.
- **Series:** en la tabla de series los campos se centran, con 8px de relleno y 44px de alto.

### Navigation
- **Barra superior:** banda azul noche con el logo de 30px, EVOLVA en wordmark y, a la derecha, la insignia de línea (estación de porcelana con borde de la línea + nivel en mayúsculas 800) y "Línea <objetivo>" en on-noche-mut.
- **Navegación inferior:** fija, azul noche, cinco pestañas (Inicio, Rutina, Comida, Progreso, Perfil) con ícono de 24px y etiqueta de 12px. Inactiva en on-noche-mut; activa en porcelana y 800, con una barra de 4px de la línea que crece desde el centro en la parte superior (260ms).

### Diagrama de línea (lineaNivel)
La firma del sistema. Banda azul noche a todo el ancho con un riel de 6px en noche-3; el tramo recorrido es la línea del objetivo y entra deslizándose desde la izquierda (900ms). Tres estaciones de 22px (Principiante, Intermedio, Avanzado) con borde de 5px; las pasadas toman la línea, la actual mide 30px con borde de 7px y recorte azul noche, y su nombre va en porcelana 800. Un banderín de porcelana ("tren", 12px 800) marca el porcentaje del tramo hacia la siguiente estación. Lleva `role="img"` con una etiqueta que dice la estación y el avance.

**The Three Places Rule.** El diagrama de línea aparece solo en Inicio (avance de nivel), Rutina (sobre la ruta de hoy) y Progreso (el historial de semanas como línea vertical), además del ingreso como ilustración del producto. Comida y Perfil usan controles estándar dentro del mismo sistema, sin rieles de firma.

### Placa de servicio (.placa)
Placa de porcelana con borde de 1.5px en placa-rule y la sombra de placa, montada 12px sobre el diagrama. A la izquierda, la luz del semáforo: un cuadrado de 92px y 12px de radio en verde, ámbar o rojo con el puntaje en display y "de 100" debajo. A la derecha, el estado en palabras (estado, 26px 900) y la línea de servicio (14px 700) con un ícono de tendencia (sube, igual, baja), "Servicio normal / con demoras / interrumpido" y la semana. Debajo, tras un filete, el motivo principal en negrita y los motivos secundarios en lista.

**The Never By Color Alone Rule.** El semáforo siempre lleva cuatro señales: el color, el puntaje numérico, el estado en palabras y el motivo, más un ícono de tendencia. En el historial, la estación de color va acompañada del estado escrito y el puntaje.

### Ramales (.ramal)
Tres filas (Entrenamiento · 40%, Nutrición · 30%, Cuerpo · 30%) con etiqueta en tinta tenue, cifra numeral a la derecha y una pista de 6px en `line` cuyo relleno se dibuja en tinta neutra y crece en 600ms. No llevan color de servicio ni de objetivo.

### Semana (.semana / .dia)
Siete estaciones L–D de 30px ensartadas en un riel de 6px. Día entrenado: estación llena de la línea. Día pendiente: centro del suelo con borde `line`. Hoy: borde de la línea, letra en 900 y la palabra "hoy" encima en la línea. Cada día es un `listitem` con etiqueta accesible.

### Letrero de próxima estación (.letrero)
Señal de andén, no alerta genérica: placa azul noche (noche-2 en modo oscuro) de 10px de radio, título "Próxima estación: <nivel>" precedido por una estación de 10px con borde de 5px en la línea (verde si toca subir, rojo si toca bajar), la decisión en negrita y su razón en porcelana, y un botón secundario sobre noche-3 cuando hay acción.

### Ruta de la sesión (.ruta / .ex)
La rutina como recorrido vertical: un riel de 6px en `line` a la izquierda, y en cada parada el pictograma del grupo muscular en una placa de 48px de la línea (radio 10px, glifo de 34px en on-linea, recorte del color del suelo) con un número de orden en una pastilla azul noche de 22px. A la derecha, nombre (18px), metadatos, variantes más fácil y más difícil, la última marca precedida por un punto de la línea y la tabla de series (número, repeticiones o segundos, kg si aplica, esfuerzo 1–10).

### Historial de la línea (.historial / .hist)
Progreso muestra las semanas evaluadas como estaciones de 32px con borde de 6px del color de servicio de esa semana, ensartadas en un riel vertical de 6px. Cada parada lleva la fecha, el puntaje en numeral, el estado en palabras con el nivel y los tres subpuntajes.

### Pictogramas (PICTO_EJ / pictogramaEj() y PICTO / pictograma())
Un pictograma propio por cada uno de los 39 ejercicios del catálogo (`PICTO_EJ`, por nombre del ejercicio), más once por grupo muscular (`PICTO`: Piernas, Pecho, Espalda, Glúteos, Core, Hombros, Isquiotibiales, Cadena posterior, Cardio, Movilidad y Cuerpo completo) como respaldo para ejercicios nuevos. Figura de palitos en caja de 24×24 con trazo de 2.2, extremos y uniones redondeadas, cabeza como círculo lleno de radio 2 y, cuando corresponde, una línea de suelo (`M2.5 21h19`). El aparato aparece solo si el ejercicio lo usa: caja o banco como rectángulo de borde redondeado, banda elástica punteada, barra como línea con disco de perfil (rectángulo lleno, nunca un círculo que se confunda con una cabeza), mancuerna como trazo corto. Siempre en blanco (on-linea) sobre una placa del color de la línea. Orden de respaldo: ejercicio → grupo muscular → mancuerna (el glifo de la pestaña Rutina). Un ejercicio nuevo en el catálogo debe recibir su pictograma en `PICTO_EJ`.

### Alertas, diálogos y toast
- **Alertas:** 8px de radio, fondo del color al 10–14% sobre la superficie y borde del mismo color al 30–45%; neutras con la línea, de aviso con ámbar, de error con rojo, positivas con verde. Siempre con texto que dice qué pasó.
- **Diálogo:** 14px de radio, cabecera azul noche fija con botón de cerrar de 44px, fondo oscurecido al 62%, entra subiendo 14px en 260ms.
- **Toast:** porcelana con texto azul noche 700, sobre la navegación inferior, entra subiendo 10px en 260ms.

## Do's and Don'ts

### Do:
- **Do** leer siempre la línea desde `--linea` / `--on-linea` / `--ring` y dejar que `:root[data-obj]` y el tema la cambien; nunca escribir el cobalto, el café o el turquesa dentro de un componente.
- **Do** mantener el shell en azul noche en ambos modos y la placa de servicio en porcelana en ambos modos.
- **Do** dibujar rieles de 6px con estaciones circulares de borde grueso (5–7px) cuando algo es un recorrido: niveles, semana, ruta, historial.
- **Do** acompañar cada color de servicio con puntaje, estado en palabras, motivo e ícono de tendencia.
- **Do** dibujar series y subpuntajes en tinta neutra (`--tx`), los datos crudos en tinta tenue y solo la tendencia principal en la línea.
- **Do** usar Overpass 800–900 con números tabulares para cifras, y el punto medio "·" (vía SepFix) como separador.
- **Do** usar las duraciones de la casa: 140ms para estados, 260ms para entradas y la pestaña activa, `cubic-bezier(.16,1,.3,1)` como curva, escala 0.97 al presionar.
- **Do** respetar `prefers-reduced-motion`: animaciones y transiciones a 0.01ms; solo el indicador de carga sigue girando, más lento (1.6s).
- **Do** mantener objetivos táctiles de 44px como mínimo y 48px en botones y campos principales.

### Don't:
- **Don't** usar verde, ámbar o rojo para algo que no sea el estado del servicio (ramales, decoración, categorías, series).
- **Don't** mostrar el semáforo solo por color.
- **Don't** poner el diagrama de línea fuera de Inicio, Rutina y Progreso (y la ilustración del ingreso).
- **Don't** apilar tarjetas con sombra suave en Comida ni en Progreso; se componen con secciones y filetes.
- **Don't** poner un antetítulo (eyebrow o kicker) sobre los títulos.
- **Don't** usar franjas laterales de acento (bordes izquierdos de color) en alertas, toasts o tarjetas.
- **Don't** introducir una segunda línea de color en la misma pantalla ni volver al tablero oscuro de anillos y tarjetas de las apps de fitness.
- **Don't** reemplazar los pictogramas propios por íconos de librería o fotos de ejercicios.
