# Matriz de QA manual

Lo que **no** puede comprobar la suite automática y hay que ejecutar a mano
antes de publicar. 262 pruebas cubren lógica, consultas, widgets y
accesibilidad; nada de eso demuestra que compartir desde Instagram abra la app,
porque eso vive fuera del proceso.

Marcar fecha y versión en cada pasada. Una casilla sin fecha es una casilla sin
comprobar.

| Plataforma | Última pasada | Versión |
|---|---|---|
| Android (dispositivo físico) | — | — |
| iOS (dispositivo físico) | — | — |
| macOS | 2026-08-14 (parcial, ver §4) | 1.0.0+1 |

---

## 1. Captura — la razón de existir del producto

Compartir hacia SambaLinks es el paso 1 de los criterios de aceptación y el
único flujo que no se puede simular: el sistema operativo es quien decide si la
app aparece en la hoja de compartir.

**Android (físico)**

- [ ] Compartir un enlace desde Instagram → se abre Quick Save con la URL
- [ ] Lo mismo desde X, YouTube y Chrome
- [ ] Con la app **cerrada del todo** (ruta `getInitialMedia`)
- [ ] Con la app **en segundo plano** (ruta `getMediaStream`)
- [ ] Texto con la URL embebida ("Mira esto https://…") → guarda sólo la URL y
      conserva el texto íntegro
- [ ] Compartir dos veces el mismo post con parámetros de seguimiento distintos
      → sale el aviso de duplicado, no una segunda tarjeta

**iOS (físico)** — *pendiente de la Fase 1B; hoy no existe esta ruta*

- [ ] Compartir desde Safari, Instagram y X
- [ ] En frío y en segundo plano

> El simulador de iOS no expone hojas de compartir de terceros de forma
> fiable. Esta sección exige un iPhone de verdad.

---

## 2. Escritorio (macOS)

- [ ] `CMD+K` enfoca la búsqueda
- [ ] `CMD+F` enfoca la búsqueda (no abre filtros — §4.5 del plan)
- [ ] `CMD+SHIFT+F` abre el panel de filtros
- [ ] `CMD+N` abre la hoja de añadir enlace
- [ ] Arrastrar un enlace desde Chrome hasta la ventana → crea la tarjeta
- [ ] Copiar una URL en el navegador y volver a la ventana → aparece la
      sugerencia; "Ahora no" la descarta y no vuelve
- [ ] Redimensionar de 400 a 1600 px → móvil, tablet, escritorio y escritorio
      ancho sin pérdida de estado
- [ ] Cerrar y reabrir → la ventana recuerda tamaño y posición

---

## 3. Accesibilidad con lector de pantalla

Las guías automáticas cubren tamaño de objetivo (≥44 px), etiqueta y
contraste. Lo que no cubren es el **orden de lectura**, que sólo se juzga
escuchándolo.

- [ ] **VoiceOver** (macOS): recorrer lista, detalle y ajustes sin ratón
- [ ] **TalkBack** (Android): recorrer lista, Kanban y categorías
- [ ] Cada tarjeta se anuncia con su título, no como "botón"
- [ ] El cambio de estado es alcanzable **sin arrastrar** (menú de la tarjeta)
- [ ] Recorrido completo con sólo teclado, sin ratón

---

## 4. Estado actual de macOS

Comprobado el 2026-08-14: la app arranca, y con una URL en el portapapeles la
sugerencia aparece en la esquina con el enlace correcto.

**Sin comprobar:** los cuatro atajos y el arrastre desde el navegador. Inyectar
pulsaciones de teclado desde una terminal exige permisos de Accesibilidad y
Grabación de Pantalla del sistema, que no se conceden por línea de comandos.
Los cuatro atajos tienen prueba unitaria; el arrastre desde un navegador real
no es automatizable.

---

## 5. Portabilidad

- [ ] Exportar → compartir el archivo → **desinstalar la app** → reinstalar →
      importar → la biblioteca vuelve completa
- [ ] Las categorías con acentos vuelven bien (`Inspiración`, no
      `InspiraciÃ³n`)
- [ ] Importar en modo Reemplazar avisa de cuántos enlaces se van a perder
- [ ] Importar un JSON corrupto no deja la base a medias

---

## 6. Ciclo de vida

- [ ] Mover una tarjeta entre columnas del Kanban → **cerrar y reabrir la
      app** → el estado persiste
- [ ] Elegir tema Oscuro → cerrar y reabrir → sigue en oscuro
- [ ] Con el tema en "Sistema", cambiar el tema del sistema con la app abierta
      → cambia en vivo
- [ ] Splash: en claro fondo `#F4F7F8`, en oscuro `#061E29`, sin destello
      blanco al arrancar en oscuro
- [ ] Icono y nombre "SambaLinks" correctos en el lanzador
