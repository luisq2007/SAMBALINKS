# SambaLinks — Plan de Implementación MVP 1.0

**Fecha:** 2026-08-10
**Base:** PRD SambaLinks MVP 1.0
**Entorno verificado:** Flutter 3.41.6 (stable) · Dart 3.11.4 · macOS arm64
**Idioma de la aplicación:** Español

---

## 1. Resumen ejecutivo

El PRD está bien definido y es implementable tal cual, con tres salvedades técnicas que conviene resolver **antes** de escribir código de producto, no después:

1. **El Share Extension de iOS no es código Flutter.** Es un target nativo en Swift con App Group. Es el mayor riesgo del proyecto y a la vez el paso 1–4 de los criterios de aceptación. Va a un spike en la Fase 1, no al final.
2. **La metadata de redes sociales fallará en la mayoría de los casos**, y eso es correcto según §10 del PRD, pero conviene fijar expectativas realistas por plataforma desde el inicio para que el diseño del fallback no sea un parche.
3. **macOS no tiene ruta de "compartir hacia la app".** `receive_sharing_intent` cubre sólo iOS y Android. En escritorio el punto de entrada tiene que ser otro (portapapeles, drag & drop). El PRD no lo cubre y hay que definirlo.

**Plataformas soportadas en 1.0: iOS, Android y macOS.** Windows queda fuera (decisión confirmada, §15).

Estimación total: **~38 días-desarrollador efectivos** (≈9 semanas con buffer del 20%), un solo desarrollador, sin contar diseño visual externo.

**Estado:** las 4 decisiones abiertas quedaron confirmadas el 2026-08-10 (ver §15). No hay nada pendiente que bloquee la ejecución.

---

## 2. Riesgos críticos (ordenados por impacto)

| # | Riesgo | Impacto | Mitigación | Fase |
|---|--------|---------|------------|------|
| R1 | Share Extension iOS requiere target Swift + App Group + configuración en Xcode que no se puede automatizar desde CLI | Bloquea el flujo principal del producto | Spike aislado antes de construir UI. Si falla, el MVP iOS se degrada a "pegar URL manualmente" | F1 |
| R2 | Instagram / X / TikTok / Facebook / LinkedIn devuelven muro de login o bloquean el user-agent | Cards sin preview en las plataformas más usadas | Cadena de estrategias con fallback garantizado + card con identidad visual de plataforma | F5 |
| R3 | `receive_sharing_intent` no soporta macOS | Ruta de captura inexistente en escritorio | Definir entrada alterna: pegar desde portapapeles, drag & drop de URL, atajo global | F15 |
| R4 | Deduplicación depende de normalización de URL; los short-links (`vm.tiktok.com`, `pin.it`, `youtu.be`) sólo se resuelven tras la petición de red | Duplicados silenciosos | Chequeo de duplicado en dos momentos: al guardar y tras resolver redirects | F4/F5 |
| R5 | Imágenes de preview apuntan a CDNs con URLs firmadas que expiran (Instagram, Facebook) | La biblioteca se "vacía" visualmente en semanas | Descarga y persistencia local desde el MVP (§44 del PRD), no caché evictable | F5 |
| R6 | Web como target futuro: CORS impide leer metadata desde el navegador | Bloquearía Web sin un proxy | Fuera del MVP. La abstracción `MetadataProvider` (§49) ya lo prevé | — |
| R7 | `receive_sharing_intent` 1.9.0 sólo admite Swift Package Manager, y sin habilitarlo Flutter aborta **también la compilación de Android** | Bloqueo total del proyecto | Anclado a 1.8.1 + parche de `jvmTarget` en Gradle. Decisión pendiente, ver §16 | F1A |

### Nota de privacidad no contemplada en el PRD

La obtención de metadata **directa desde el dispositivo** expone la IP del usuario a cada sitio que guarda. Es coherente con "Privacy First" (no hay servidor intermedio), pero conviene documentarlo. Existen proxies de terceros (`fxtwitter`, `vxtwitter`) que arreglarían R2 para X/Twitter, pero implican enviar las URLs del usuario a un tercero: **contradicen el principio de privacidad y quedan fuera del MVP**. Si se adoptan después, deben ser opt-in explícito en Ajustes.

---

## 3. Stack técnico (versiones verificadas en pub.dev, 2026-08-10)

| Área | Paquete | Versión | Notas |
|------|---------|---------|-------|
| Base de datos | `drift` | ^2.34.3 | + `drift_dev` ^2.34.5, `build_runner` ^2.16.0 |
| | `drift_flutter` | ^0.3.1 | Configura rutas y libs nativas multiplataforma |
| | `sqlite3` | ^3.5.1 | Desde 3.x incluye los binarios; `sqlite3_flutter_libs` está EOL |
| Estado | `flutter_riverpod` | ^3.4.2 | + `riverpod_annotation` ^4.0.6, `riverpod_generator` ^4.0.8 |
| Navegación | `go_router` | ^17.5.0 | `StatefulShellRoute` para shell persistente |
| Compartir (entrada) | `receive_sharing_intent` | ^1.9.0 | Mantenido (última publicación 2026-06-24) |
| Compartir (salida) | `share_plus` | ^13.3.0 | Cubre iOS, Android y macOS — las 3 plataformas de 1.0 |
| Red | `dio` | ^5.11.0 | Timeouts, límite de bytes, control de redirects |
| Parsing HTML | `html` | ^0.15.6 | |
| IDs | `uuid` | ^4.6.0 | **UUID v7** (ordenable por tiempo) |
| Imágenes | `cached_network_image` | ^3.4.1 | Sólo para thumbnails remotos; la persistencia es propia |
| Archivos | `path_provider` ^2.1.6, `file_picker` ^11.0.3 | | |
| Preferencias | `shared_preferences` | ^2.5.5 | Sólo bootstrap (tema). El resto en tabla `settings` |
| Modelos | `freezed` ^3.2.5, `json_serializable` ^6.14.1 | | |
| Utilidades | `url_launcher` ^6.3.2, `intl` **^0.20.2**, `collection` ^1.19.1 | | `intl` lo fija `flutter_localizations` del SDK: exige 0.20.2 exacto, no 0.20.3 (verificado en F0) |
| Desktop | `desktop_drop` ^0.7.1, `window_manager` ^0.5.2 | | Sólo Fase 15 |
| Tests | `mocktail` ^1.0.5 | | |

**Descartado:** `metadata_fetch` (última publicación 2024-09, sin mantenimiento) y `any_link_preview`. La cadena de prioridad de §9 del PRD es específica y requiere control total; el extractor propio son ~180 líneas totalmente testeables y elimina una dependencia de riesgo.

---

## 4. Ajustes propuestos al PRD

Cada uno con su justificación. Ninguno cambia el alcance funcional.

### 4.1 Localización con ARB desde el día 1 (aunque sólo haya español)

Coste: ~1 hora de setup. Beneficio: ningún string queda incrustado en 60 widgets. Deshacer strings hardcodeados después es de las refactorizaciones más caras que existen, y el PRD contempla una fase comercial. Se configura `flutter_localizations` + `app_es.arb` con `es` como único locale.

### 4.2 No añadir `deletedAt` / `syncVersion` / `deviceId` todavía

El PRD (§50) los menciona como futuros. Añadir columnas nullable en Drift después es una migración de 3 líneas. Lo que **sí** hay que hacer ahora es dejar la infraestructura de migraciones montada y probada (`schemaVersion`, `MigrationStrategy`, tests de migración), que es la parte que sí duele si se improvisa.

**Advertencia asociada:** cuando se añada `deletedAt`, el índice `UNIQUE` sobre `canonical_url` deberá convertirse en índice parcial (`WHERE deleted_at IS NULL`) mediante `customStatement` en la migración. Queda anotado para no descubrirlo tarde.

### 4.3 Búsqueda con `LIKE` + índices en el MVP, no FTS5

Para el volumen declarado (cientos a miles de links) `LIKE '%term%'` con debounce de 250 ms responde por debajo de 50 ms. FTS5 exige tabla virtual, triggers de sincronización y complica el import/export. **Umbral definido para migrar a FTS5: >15.000 cards o búsqueda >150 ms medida.** El repositorio se diseña con la búsqueda tras una interfaz (`CardSearchSource`) para que el cambio no toque la UI.

### 4.4 Quick Save vive en Flutter, no dentro del Share Extension

Hay dos arquitecturas posibles:

- **A (elegida):** el Share Extension recibe la URL y abre SambaLinks, que muestra Quick Save. Coste: un cambio de app (~1 s). Todo el código es Flutter.
- **B:** UI nativa dentro del Share Extension escribiendo en un SQLite compartido vía App Group. El usuario no sale de Instagram, pero exige reimplementar Quick Save en Swift **y** en Kotlin, más lógica de concurrencia sobre la base de datos.

B multiplica el trabajo por tres para ganar un segundo. Se elige A para el MVP; B es una optimización posterior perfectamente compatible con este diseño.

### 4.5 Atajo `CMD/CTRL + F` — CONFIRMADO

El PRD lo asigna a "Filter". En prácticamente toda aplicación de escritorio, `CMD+F` es buscar. Queda fijado así:

- `CMD/CTRL + F` → buscar (junto a `CMD/CTRL + K`, que abre la paleta global)
- `CMD/CTRL + SHIFT + F` → panel de filtros

Sustituye a la asignación de §40 del PRD.

### 4.6 UUID v7 explícito

El ejemplo del PRD (`018f7b73-...`) ya es un UUID v7 (prefijo de timestamp). Se confirma como estándar: `const Uuid().v7()`. Ventaja concreta: los IDs son monótonos en el tiempo, lo que mejora la localidad del índice y sirve como desempate estable en ordenamientos por fecha.

---

## 5. Estructura de carpetas

Sigue §47 del PRD con dos precisiones:

```
lib/
  main.dart
  app.dart                          # MaterialApp.router + ProviderScope

  core/
    database/
      app_database.dart             # @DriftDatabase
      tables/                       # cards, categories, card_categories, settings
      daos/
      migrations/
      converters/                   # enums <-> texto
    network/
      http_client.dart              # Dio configurado: timeouts, límite de bytes, UA
    routing/
      app_router.dart
      routes.dart
    theme/
      tokens.dart                   # colores, espaciado, radios, duraciones
      app_theme.dart                # ThemeData claro / oscuro
      typography.dart
    utils/
      url_normalizer.dart
      platform_detector.dart
      result.dart                   # Result<T, E>
    l10n/
      app_es.arb

  features/
    links/        { data/ domain/ presentation/ }
    categories/   { data/ domain/ presentation/ }
    kanban/       { presentation/ }
    sharing/      { data/ domain/ presentation/ }
    metadata/     { data/ domain/ }
    backup/       { data/ domain/ presentation/ }
    settings/     { data/ domain/ presentation/ }
    search/       { domain/ presentation/ }

  shared/
    widgets/                        # LinkCard, StatusPill, CategoryChip, EmptyState...
    layout/                         # Breakpoints, AdaptiveScaffold
    extensions/
```

**Regla de dependencias, verificable:** `domain/` no importa Flutter ni Drift. `presentation/` no importa `data/` directamente, sólo a través de providers. Se valida con un test de arquitectura que analiza imports.

---

## 6. Modelo de datos

### 6.1 Tablas (Drift — ilustrativo, no final)

```dart
@TableIndex(name: 'idx_cards_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_cards_updated_at', columns: {#updatedAt})
@TableIndex(name: 'idx_cards_status',     columns: {#status})
@TableIndex(name: 'idx_cards_platform',   columns: {#platform})
@TableIndex(name: 'idx_cards_domain',     columns: {#domain})
class Cards extends Table {
  TextColumn get id => text()();                                  // UUID v7
  TextColumn get url => text()();                                 // original, tal cual llegó
  TextColumn get canonicalUrl => text()();                        // normalizada, base de dedup
  TextColumn get domain => text()();

  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();

  TextColumn get imageUrl => text().nullable()();                 // remota
  TextColumn get localImage => text().nullable()();               // ruta relativa en app dir
  TextColumn get faviconUrl => text().nullable()();

  TextColumn get siteName => text().nullable()();
  TextColumn get platform => textEnum<LinkPlatform>()();
  TextColumn get status => textEnum<CardStatus>()
      .withDefault(const Constant('pending'))();

  TextColumn get notes => text().nullable()();
  TextColumn get originalSharedText => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get metadataFetchedAt => dateTime().nullable()();
  TextColumn get metadataStatus => textEnum<MetadataStatus>()
      .withDefault(const Constant('pending'))();

  @override Set<Column> get primaryKey => {id};
  @override List<Set<Column>> get uniqueKeys => [{canonicalUrl}];
}
```

```dart
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get color => text().nullable()();      // hex "#0D4C5C"
  TextColumn get icon => text().nullable()();       // clave de un catálogo propio, no codePoint
  IntColumn  get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override Set<Column> get primaryKey => {id};
  @override List<Set<Column>> get uniqueKeys => [{name}];
}

@TableIndex(name: 'idx_cc_card',     columns: {#cardId})
@TableIndex(name: 'idx_cc_category', columns: {#categoryId})
class CardCategories extends Table {
  TextColumn get cardId => text().references(Cards, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId => text().references(Categories, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime()();

  @override Set<Column> get primaryKey => {cardId, categoryId};
}

class SettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();                 // JSON serializado
  @override Set<Column> get primaryKey => {key};
}
```

**Notas de implementación:**

- `PRAGMA foreign_keys = ON` en `beforeOpen`. Drift **no** lo activa por defecto y sin esto el `CASCADE` es decorativo.
- `icon` guarda una clave textual (`"lightbulb"`, `"code"`) mapeada a un catálogo propio, **no** un `codePoint` de `IconData`. Los codePoints rompen con tree-shaking de iconos y no son portables entre versiones de Flutter — problema real al exportar/importar JSON.
- `metadataStatus`: `pending | ok | partial | failed | unsupported`. `partial` es el caso de §10 (sólo dominio y plataforma).
- El **Inbox no es una categoría**. Es la consulta `cards LEFT JOIN card_categories WHERE card_categories.card_id IS NULL`. Materializarlo como categoría real obligaría a mantener la invariante en cada asignación, lo cual es una fuente segura de bugs.

### 6.2 Enums

```dart
enum CardStatus { pending, active, done }              // UI: Pendiente / Activo / Atendido
enum MetadataStatus { pending, ok, partial, failed, unsupported }
enum LinkPlatform {
  instagram, x, threads, pinterest, facebook, tiktok,
  youtube, linkedin, reddit, web, other
}
```

Se persisten como **texto**, nunca como índice ordinal: reordenar el enum no puede corromper la base de datos, y el JSON exportado es legible.

Para "estados personalizados posteriores" (§12), `status` es `TEXT` sin constraint `CHECK`; el enum vive en Dart con un fallback tolerante para valores desconocidos.

---

## 7. Normalización y canonicalización de URLs

Es el componente del que depende la deduplicación (§27). Dart puro, sin I/O, 100% testeable.

### Pipeline general

1. Trim, añadir `https://` si falta esquema
2. Esquema y host a minúsculas
3. Eliminar `www.`, `m.`, `mobile.`
4. Eliminar fragmento (`#...`)
5. Eliminar parámetros de tracking: `utm_*`, `fbclid`, `gclid`, `igshid`, `igsh`, `ref`, `ref_src`, `ref_url`, `si`, `feature`, `mc_cid`, `mc_eid`, `_branch_match_id`, `share_id`, `source`
6. Ordenar alfabéticamente los parámetros restantes
7. Eliminar barra final (salvo raíz)

### Reglas por plataforma

| Plataforma | Regla |
|-----------|-------|
| YouTube | `youtu.be/{id}`, `/shorts/{id}`, `/embed/{id}` → `youtube.com/watch?v={id}` |
| X / Twitter | `twitter.com` → `x.com`; recortar sufijos `/photo/1`, `/video/1` |
| Instagram | `instagram.com/{user}/p/{code}` → `instagram.com/p/{code}`; conservar `/p/`, `/reel/`, `/tv/` |
| Reddit | `/r/{sub}/comments/{id}/{slug}` → `/r/{sub}/comments/{id}` |
| TikTok | `vm.tiktok.com/{x}` y `vt.tiktok.com/{x}` requieren resolución de red |
| Pinterest | `pin.it/{x}` requiere resolución de red |
| Facebook | eliminar `fbclid`; `web.facebook.com` → `facebook.com` |
| LinkedIn | conservar `/posts/{slug}`, `/pulse/{slug}` |

### Extracción de URL desde texto compartido (§6)

Otras apps comparten `"Mira esto https://instagram.com/p/xxxx"`. Se extrae con regex la **primera** URL http/https, se conserva el texto íntegro en `originalSharedText`. Si hay varias URLs, en el MVP se toma la primera y se registra la decisión (mejora futura: ofrecer elegir).

### Riesgo R4 — flujo de doble verificación

```
URL entrante
  → normalizar          → canonicalTentativa
  → ¿duplicado?         → si sí: diálogo §27, fin
  → guardar card
  → fetch metadata (sigue redirects)
  → URL final ≠ tentativa?
      → renormalizar → ¿ahora sí es duplicado?
          → sí: ofrecer fusionar (mantener el más antiguo, unir categorías y notas)
          → no: actualizar canonicalUrl
```

La fusión es el único caso donde se borra un card automáticamente, y **siempre con confirmación del usuario**.

---

## 8. Servicio de metadata

### 8.1 Contrato

```dart
abstract interface class MetadataProvider {
  Future<MetadataResult> fetch(Uri url);
}

class MetadataResult {
  final String? title, description, imageUrl, faviconUrl, siteName;
  final Uri? resolvedUrl;            // tras redirects
  final MetadataStatus status;
}
```

`DirectMetadataProvider` hoy; `CloudMetadataProvider` mañana (§49). La UI nunca conoce la implementación.

### 8.2 Cadena de estrategias

Se ejecutan en orden hasta que una devuelve algo utilizable:

1. **`OEmbedStrategy`** — endpoints públicos sin autenticación: YouTube (`youtube.com/oembed`), Vimeo, Reddit, TikTok (best-effort), Flickr. Es la vía más fiable donde existe.
2. **`HtmlMetaStrategy`** — `GET` con `User-Agent` de navegador de escritorio, `Accept-Language: es-ES,es`, timeout 8 s, **límite de 512 KB** de descarga (evita descargar vídeos por un `Content-Type` mal declarado), máximo 5 redirects. Parseo con `html`, aplicando la prioridad exacta de §9.
3. **`FallbackStrategy`** — nunca falla. Devuelve `siteName` = nombre de la plataforma, `title` = dominio, `status: partial`. **Garantiza que ningún link se pierda** (§10).

### 8.3 Expectativa realista por plataforma

Esto no es pesimismo: es el criterio para diseñar el fallback como algo intencional y no como un error.

| Plataforma | Resultado esperado |
|-----------|--------------------|
| Blogs, noticias, web genérica | ✅ OG completo |
| YouTube | ✅ oEmbed + OG, excelente |
| Reddit | ✅ OG bueno |
| Pinterest | ⚠️ parcial |
| Threads | ⚠️ variable |
| TikTok | ⚠️ oEmbed a veces responde |
| Instagram | ❌ muro de login en la mayoría de casos |
| X / Twitter | ❌ bloqueado sin autenticación |
| Facebook | ❌ bloqueado |
| LinkedIn | ❌ posts requieren login; artículos públicos a veces sí |

**Consecuencia de diseño:** el card en estado `partial` debe verse *bien*, no roto. Fondo con el color de marca de la plataforma, su icono, dominio y fecha. Un usuario que guarda 20 posts de Instagram debe ver una cuadrícula elegante, no 20 huecos grises.

### 8.4 Persistencia de imágenes (R5)

`cached_network_image` mantiene un caché **evictable** por el sistema: no resuelve §44. Implementación:

1. Descargar `imageUrl` a `{appSupportDir}/images/{cardId}.{ext}`
2. Guardar la ruta **relativa** en `local_image` (la ruta absoluta del contenedor de iOS cambia entre instalaciones — error clásico)
3. Techo de 2 MB por imagen; si excede, guardar sólo la URL remota
4. Al mostrar: local primero, remota como respaldo, placeholder de plataforma al final
5. Limpieza de huérfanos al arrancar (archivos sin card asociado), con tope de tiempo para no bloquear el inicio

Las imágenes **no** se incluyen en el JSON de exportación (lo haría inmanejable). Al importar en otro dispositivo se conservan las URLs remotas y se re-descarga lo que siga vivo. Debe decirse en la UI de importación.

---

## 9. Design System

### 9.1 Tokens de color (contrastes WCAG ya calculados)

**Tema oscuro**

| Token | Hex | Uso | Contraste |
|-------|-----|-----|-----------|
| `bg` | `#061E29` (Raven) | Fondo de aplicación | — |
| `surface` | `#18343F` (Charcoal) | Cards, paneles | — |
| `surfaceElevated` | `#0D4C5C` (Lagoon) | Hover, seleccionado, sidebar activo | — |
| `accent` | `#B9ECFA` (Arctic) | Primario, focus | 10.26:1 sobre surface ✅ AAA |
| `textPrimary` | `#FFFFFF` | | 13.11:1 sobre surface ✅ AAA |
| `textSecondary` | `#A9BFC9` | | 6.86:1 sobre surface ✅ AA |
| `border` | `#FFFFFF` @ 10% | Según §34 | — |

**Tema claro**

| Token | Hex | Uso | Contraste |
|-------|-----|-----|-----------|
| `bg` | `#F4F7F8` | Fondo (no blanco puro, §35) | — |
| `surface` | `#FFFFFF` | Cards | — |
| `accent` | `#0D4C5C` (Lagoon) | Primario | 9.52:1 sobre surface ✅ AAA |
| `textPrimary` | `#061E29` (Raven) | | 17.14:1 ✅ AAA |
| `textSecondary` | `#18343F` (Charcoal) @ 70% | | ✅ AA |
| `accentSurfaces` | Arctic / Mint / Sand | Chips de categoría, destacados | 13–15:1 con Raven ✅ AAA |

**Colores de estado** (consistentes en ambos temas, ajustando luminosidad):

| Estado | Claro | Oscuro |
|--------|-------|--------|
| Pendiente | `#B98900` sobre Sand `#FFF0BD` | `#FFD666` |
| Activo | `#0D4C5C` sobre Arctic `#B9ECFA` | `#6FD8F0` |
| Atendido | `#12795A` sobre Mint `#B9F7D8` | `#5FDCA4` |

Todos los pares verificados. La paleta del PRD tiene contraste excelente; el único ajuste necesario es que **Lagoon no funciona como acento en tema oscuro** (9.52:1 contra blanco, pero apenas 1.6:1 contra Charcoal) — por eso el acento oscuro es Arctic, no Lagoon.

### 9.2 Resto de tokens

- **Espaciado:** escala de 4 → `4, 8, 12, 16, 24, 32, 48`
- **Radios:** `8` (chips), `12` (cards), `16` (sheets/paneles)
- **Elevación:** sombras suaves en claro; en oscuro, elevación por color de superficie + borde al 10% (las sombras no se ven sobre fondo oscuro)
- **Tipografía:** una familia geométrica sans (Inter o similar vía `google_fonts`). Escala: `Display 28/34 · Title 20/26 · Body 15/22 · Caption 13/18 · Label 12/16`
- **Movimiento:** `120 ms` micro-interacciones, `220 ms` transiciones, `320 ms` paneles. Curva `easeOutCubic`. Respetar `MediaQuery.disableAnimations`

### 9.3 Requisito de §32 — no parecer un CRUD

Traducido a reglas concretas y verificables:

- Ningún `DataTable`, ningún `ListTile` por defecto, ningún `AlertDialog` sin estilizar
- Densidad: card de lista con 88–96 px de alto en móvil, no 56
- Todo estado vacío tiene ilustración/icono + texto guía + acción primaria (§41)
- Ninguna acción destructiva sin `undo` mediante SnackBar (borrar card, quitar de categoría)
- Feedback inmediato: guardar un link muestra el card al instante en estado "cargando preview", nunca un spinner bloqueante

---

## 10. Glosario español (definir antes de escribir UI)

| Interno | UI en español |
|---------|---------------|
| `pending` | Pendiente |
| `active` | Activo |
| `done` | Atendido |
| Inbox | **Bandeja** |
| All links | Todos los enlaces |
| Card | Enlace / Tarjeta (usar "enlace" en textos, "tarjeta" sólo en ayuda visual) |
| Category | Categoría |
| Filters / Clear filters | Filtros / Limpiar filtros |
| Sort | Ordenar |
| Newest / Oldest | Más recientes / Más antiguos |
| Recently updated | Actualizados recientemente |
| Refresh metadata | Actualizar vista previa |
| Export / Import library | Exportar / Importar biblioteca |
| Merge / Replace | Combinar / Reemplazar |
| Settings → Appearance | Ajustes → Apariencia |
| System / Light / Dark | Sistema / Claro / Oscuro |

Se materializa en `app_es.arb` en la Fase 0. **Nada de strings incrustados en widgets.**

---

## 11. Plan por fases

Cada fase declara objetivo, entregables y **verificación** — el criterio objetivo que determina si está terminada.

### HITO A — Cimientos y reducción de riesgo (F0–F5) · ~10 días

---

#### Fase 0 — Andamiaje y herramientas · 0.5 d — ✅ COMPLETADA (2026-08-11)

Bundle ID: **`app.sambadesk.links`** en las 3 plataformas. Verificada en ejecución sobre emulador Android, simulador de iPhone 17 Pro (iOS 26.4) y macOS.

**Entregables**
- `flutter create --platforms=ios,android,macos`. Sin carpeta `windows/`: no se mantiene código que nadie compila ni ejecuta (§15). Bundle ID `app.sambadesk.links` — `flutter create` no puede generarlo directamente (el nombre del paquete Dart no coincide con el último segmento), así que se reescribe en los 4 archivos nativos y se mueve `MainActivity.kt` a `android/app/src/main/kotlin/app/sambadesk/links/`
- Estructura de carpetas de §5 con `.gitkeep`
- `analysis_options.yaml` estricto: `strict-casts`, `strict-raw-types`, `prefer_final_locals`, `always_declare_return_types`
- `flutter_localizations` + `app_es.arb` + `l10n.yaml`
- Git inicializado, `.gitignore` con `*.g.dart`/`*.freezed.dart` **no** ignorados (facilita revisar diffs generados)

**Verificación:** `flutter analyze` sin issues · `flutter test` verde · la app arranca en iOS, Android y macOS mostrando un texto desde el ARB.

---

#### Fase 1 — SPIKE: Share Sheet (riesgo R1) · 1.5–2 d

Se hace **ahora**, con una pantalla que sólo imprime la URL recibida. Nada de UI de producto.

Se parte en dos por la decisión de priorizar Android (§15): **1A entrega valor por sí sola**; 1B puede esperar sin bloquear nada.

##### Fase 1A — Android · 0.5 d — ✅ COMPLETADA (2026-08-12)

- `intent-filter` con `ACTION_SEND` / `text/plain` y `ACTION_VIEW` para `http`/`https`
- `android:launchMode="singleTask"` en la Activity
- Verificar recepción con app en frío y app en segundo plano (rutas distintas del plugin: `getInitialMedia()` vs `getMediaStream()`)

**Verificación:** ✅ en emulador Android, compartir a SambaLinks abre la app y muestra la URL extraída, tanto en frío como en segundo plano. Probado con texto que lleva la URL embebida ("Mira esta publicación https://…"), que es el formato real de Instagram y X.

**Añadido durante la fase** (a petición del producto, adelanta trabajo de F6 y F16):
- `core/theme/tokens.dart` + `app_theme.dart` con la paleta de marca cableada a tema claro y oscuro
- `core/utils/url_extractor.dart` con 10 tests — base del `SharedTextParser` de la F4
- Iconos de lanzador generados desde el logo en Android, iOS y macOS

##### Fase 1B — iOS · 1–1.5 d

La parte cara: es un target nativo en Swift, no código Flutter.

- Nuevo target *Share Extension* en Xcode
- App Group `group.app.sambadesk.links` habilitado en **ambos** targets
- `Info.plist` del extension: `NSExtensionActivationSupportsWebURLWithMaxCount = 1` y `NSExtensionActivationSupportsText = true`
- URL scheme personalizado `ShareMedia-app.sambadesk.links`
- Bundle IDs: app `app.sambadesk.links`, extension `app.sambadesk.links.Share`

**Verificación:** desde Safari, Instagram y X en un **iPhone físico** (el simulador no expone hojas de compartir de terceros de forma fiable), compartir a SambaLinks abre la app y muestra la URL. Se documenta cada paso manual de Xcode en `docs/ios-share-extension.md` — no es reproducible desde CLI y hay que poder repetirlo.

**Si 1B falla:** no bloquea el desarrollo, porque Android ya está resuelto. Pero hay que saberlo ahora y no en la semana 8: ese es el propósito de no aplazarlo más allá de la Fase 1.

---

#### Fase 2 — Capa de datos · 2 d

**Entregables**
- Tablas de §6 en Drift + generación
- `PRAGMA foreign_keys = ON` en `beforeOpen`
- `MigrationStrategy` con `schemaVersion = 1` + `drift_dev schema dump` para snapshots
- DAOs: `CardsDao`, `CategoriesDao`, `CardCategoriesDao`, `SettingsDao`
- Consultas base: lista con filtros combinados, contadores por estado y categoría, consulta Bandeja
- Datos semilla: 3 categorías de ejemplo en primer arranque

**Verificación:** suite de tests de DAO sobre `NativeDatabase.memory()`, cubriendo: inserción con UUID v7, `UNIQUE` en `canonical_url` rechaza duplicados, `CASCADE` borra relaciones al borrar card y al borrar categoría, un card en dos categorías aparece una sola vez, la consulta Bandeja excluye cards con categoría. Test de migración 1→1 (no-op) para dejar el arnés montado.

---

#### Fase 3 — Dominio, repositorios y providers · 1.5 d

**Entregables**
- Entidades `freezed`: `LinkCard`, `Category`, `AppSettings` (sin dependencia de Flutter ni Drift)
- Mapeadores Drift ↔ dominio
- `LinkRepository`, `CategoryRepository`, `SettingsRepository` (interfaces en `domain/`, implementación en `data/`)
- Providers Riverpod con `riverpod_generator`; streams reactivos desde Drift (`watch`) para que la UI se actualice sola
- `Result<T, AppFailure>` para errores esperables

**Verificación:** test de arquitectura que falla si `domain/` importa `package:flutter` o `package:drift`. Tests de repositorio con base en memoria.

---

#### Fase 4 — Normalización de URL y detección de plataforma · 1.5 d

**Entregables**
- `UrlNormalizer` con todo el pipeline y las reglas por plataforma de §7
- `PlatformDetector` (host → `LinkPlatform`)
- `SharedTextParser` (extracción de URL desde texto libre)

**Verificación:** tests tabulados con **mínimo 40 casos**, incluyendo: `youtu.be` vs `/watch?v=` vs `/shorts/` → misma canónica; `twitter.com` y `x.com` → misma canónica; Instagram con y sin usuario en la ruta → misma canónica; URLs con `utm_*` e `igshid` → misma canónica que sin ellos; texto con emoji y URL mezclados; URL sin esquema; URL malformada no lanza excepción.

---

#### Fase 5 — Servicio de metadata · 3 d

**Entregables**
- `MetadataProvider` + `DirectMetadataProvider` con las 3 estrategias de §8
- Cliente Dio: timeout 8 s, límite 512 KB, 5 redirects, UA configurable
- Prioridad exacta de §9 para título, descripción e imagen
- Descarga y persistencia local de imágenes + limpieza de huérfanos
- Cola con concurrencia limitada (máx. 3 simultáneas) para no saturar al importar en lote
- Resolución de short-links + reverificación de duplicado (R4)

**Verificación:** tests con **fixtures HTML locales** (no red): página con OG completo, sólo Twitter Cards, sólo `<title>`, muro de login de Instagram, HTML malformado, redirect 301, respuesta 403, respuesta de 5 MB (debe cortarse en 512 KB). Test de integración opcional marcado `@Tags(['network'])`, excluido del CI por defecto.

---

### HITO B — Producto usable localmente (F6–F11) · ~16 días

---

#### Fase 6 — Design System · 2.5 d

**Entregables**
- `tokens.dart` con la paleta de §9 y todos los tokens
- `ThemeData` claro y oscuro construidos desde los tokens (no colores sueltos en widgets)
- Componentes base: `SambaButton`, `SambaTextField`, `StatusPill`, `CategoryChip`, `SambaCard`, `EmptyState`, `SambaSheet`, `SambaMenu`
- Pantalla interna `/dev/gallery` que muestra todos los componentes en ambos temas

**Verificación:** la galería se ve correcta en claro y oscuro, móvil y escritorio. Test que falla si algún widget usa `Color(0x...)` literal fuera de `tokens.dart`.

---

#### Fase 7 — Shell responsive y navegación · 2 d

**Entregables**
- `go_router` con `StatefulShellRoute` (el shell no se reconstruye al cambiar de sección)
- `Breakpoints`: <600 móvil, 600–1024 tablet, >1024 escritorio
- Móvil: `BottomNavigationBar` (Inicio, Kanban, Categorías, Ajustes) + FAB
- Tablet: `NavigationRail`
- Escritorio: sidebar colapsable con contadores en vivo (§37)
- Escritorio ancho (>1400): tercera columna de detalle (§39)

**Verificación:** redimensionar la ventana de macOS de 400 a 1600 px transita entre los tres modos sin pérdida de estado ni excepciones de overflow. Rotación en móvil correcta.

---

#### Fase 8 — Vista Lista · 4 d

**Entregables**
- `LinkCard` en tres densidades (móvil, escritorio, compacta)
- Lista virtualizada con paginación por lotes (`limit`/`offset`) — no cargar 5.000 cards de golpe
- Pestañas Todos / Pendiente / Activo / Atendido
- Ordenamiento (§18): 7 opciones, persistidas en tabla `settings`
- Filtros (§19): categoría, estado, plataforma, fecha, con imagen / sin imagen, con notas, sin categoría + "Limpiar filtros"
- Búsqueda (§20) con debounce 250 ms sobre título, descripción, dominio, URL, notas, categoría, plataforma
- Estados vacíos diferenciados (§41): biblioteca vacía ≠ filtro sin resultados ≠ búsqueda sin resultados
- *(P1)* Selección múltiple con acciones en lote (§26)

**Verificación:** con 2.000 cards semilla, el scroll se mantiene fluido y la búsqueda responde en <150 ms (medido). Filtros combinados producen el conteo correcto contra una consulta SQL de referencia.

---

#### Fase 9 — Detalle de card y acciones · 2.5 d

**Entregables**
- Escritorio: panel lateral derecho (§24). Móvil: bottom sheet expandible a pantalla completa
- Edición en línea de título, descripción y notas con autoguardado (debounce 800 ms)
- Menú `⋮` con las 11 acciones de §25
- "Actualizar vista previa": refresca título, descripción, imagen, siteName, favicon; **nunca** categorías, estado, notas ni `createdAt` (§43)
- Error de metadata amigable, sin jerga técnica (§42)
- Borrado con `undo`

**Verificación:** test de widget que confirma que tras "Actualizar vista previa" las notas, el estado, las categorías y `createdAt` permanecen idénticos. `url_launcher` abre el original en iOS, Android y macOS.

---

#### Fase 10 — Categorías y Bandeja · 2 d

**Entregables**
- CRUD de categorías con selector de color e icono
- Reordenamiento por arrastre (`sortOrder`)
- Asignar / quitar categorías desde el card (multi-selección)
- Vista de categoría con sus cards
- Bandeja como consulta (§16), con contador en vivo
- Al borrar una categoría: se borran las relaciones, **nunca los cards** (aviso explícito)

**Verificación:** criterios 7–9 de §55 — crear "Ideas", añadir el card, añadir el mismo card a "Trivali", confirmar mediante consulta SQL que existe **un** registro en `cards` y **dos** en `card_categories`.

---

#### Fase 11 — Kanban · 3 d

**Entregables**
- Tres columnas con contadores (§21)
- Drag & drop entre columnas actualizando `status` (`Draggable`/`DragTarget`; en escritorio, cursor y feedback visual adecuados)
- Auto-scroll al arrastrar cerca del borde
- Móvil: columnas deslizables horizontalmente, con alternativa accesible de cambio de estado por menú (arrastrar en móvil es incómodo y poco accesible)
- Kanban dentro de una categoría (§22)

**Verificación:** criterios 10–11 de §55. Mover un card entre columnas persiste el estado tras reiniciar la app. `updatedAt` cambia; `createdAt` no.

---

### HITO C — Captura (F12) · ~4 días

---

#### Fase 12 — Share to SambaLinks completo · 4 d

Aprovecha el spike de F1, ahora con producto real.

**Entregables**
- Recepción de `text/plain`, `text/uri-list` y URL (§6), en frío y en segundo plano
- Pantalla Quick Save (§7): preview, estado, categorías, nota, botón Guardar. **Ningún campo obligatorio**
- Guardado inmediato → el card existe antes de que termine el fetch de metadata (Capture First)
- Categoría por defecto: ninguna → cae en Bandeja
- Detección de duplicados (§27) con el diálogo especificado: fecha de guardado, categorías actuales, "Abrir card", "Añadir a otra categoría"
- Añadir URL manualmente: FAB en móvil, `CMD/CTRL+N` en escritorio, con detección automática de URL en el portapapeles

**Verificación:** criterios 1–6 de §55 en dispositivo físico iOS y Android, desde Instagram, X, YouTube y Safari/Chrome. Compartir dos veces el mismo post con parámetros de tracking distintos dispara el diálogo de duplicado.

---

### HITO D — Portabilidad y pulido (F13–F16) · ~8 días

---

#### Fase 13 — Exportación e importación JSON · 2.5 d

**Entregables**
- Exportación al formato de §29 (detalle completo en §12 de este plan)
- Compartir tras exportar (§31): `share_plus` en las 3 plataformas. En macOS, además, "Guardar en…" con diálogo nativo (`file_picker`), que es lo que espera un usuario de escritorio para un backup
- Importación con las opciones de §30: Combinar / Reemplazar, y política de duplicados (Mantener existente / Reemplazar con importado / Mantener el más reciente)
- Confirmación obligatoria y explícita antes de Reemplazar, con el conteo de lo que se va a perder
- Validación de `schemaVersion` con mensaje claro si el archivo es de una versión futura
- Importación transaccional: o entra todo, o no entra nada
- Aviso de que las imágenes locales no viajan en el JSON

**Verificación:** test de ida y vuelta — biblioteca con 200 cards, 12 categorías, 400 relaciones, notas con acentos/emoji/comillas → exportar → borrar todo → importar → comparación profunda idéntica, incluyendo `createdAt` con precisión de milisegundos. Test de las 3 políticas de duplicados. Test de importación de un JSON corrupto (no debe dejar la base a medias).

---

#### Fase 14 — Ajustes y tema · 1.5 d

**Entregables**
- Selector de apariencia: Sistema / Claro / Oscuro (§36), por defecto Sistema
- Preferencias persistidas: vista por defecto, orden por defecto, último filtro
- Sección Datos con exportar/importar
- Acerca de + versión + política de privacidad local ("tus datos nunca salen de este dispositivo")
- *(Recomendado)* "Borrar toda la biblioteca" con doble confirmación

**Verificación:** el tema persiste tras reiniciar. Cambiar el tema del sistema con la app abierta y modo "Sistema" activo la actualiza en vivo.

---

#### Fase 15 — Escritorio y accesibilidad · 2.5 d

**Entregables**
- Atajos de §40 (con el ajuste de §4.5 de este plan)
- Navegación con flechas entre cards + `Enter` para abrir
- Drag & drop de URLs desde el navegador hacia la ventana (`desktop_drop`) — **la ruta de captura en escritorio (R3)**
- Detección de URL en el portapapeles al enfocar la ventana, con sugerencia no intrusiva
- Tamaño y posición de ventana persistidos (`window_manager`)
- Paso de accesibilidad: etiquetas semánticas, orden de foco, objetivos táctiles ≥44 px, verificación con TalkBack/VoiceOver

**Verificación:** recorrido completo con sólo teclado, sin ratón. Arrastrar una URL desde Chrome crea el card.

---

#### Fase 16 — QA contra criterios de aceptación · 1.5 d

**Entregables**
- Test de integración que ejecuta los 20 pasos de §55 de principio a fin
- Prueba de carga: importar 5.000 cards y medir arranque, scroll y búsqueda
- Matriz manual: iOS físico, Android físico, macOS
- Iconos de app, splash, nombre visible "SambaLinks"
- `docs/` con el proceso de release y los pasos manuales de Xcode

**Verificación:** los 20 criterios pasan. Arranque en frío <2 s con 5.000 cards.

---

## 12. Formato JSON de exportación (completo)

El PRD deja los arrays vacíos. Propuesta concreta:

```json
{
  "schemaVersion": 1,
  "application": "SambaLinks",
  "appVersion": "1.0.0",
  "exportedAt": "2026-08-10T18:00:00Z",
  "counts": { "cards": 245, "categories": 12, "cardCategories": 388 },
  "settings": {
    "theme": "system",
    "defaultView": "list",
    "defaultSort": "newest"
  },
  "categories": [
    {
      "id": "018f7b73-0000-7000-8000-000000000001",
      "name": "Inspiración",
      "color": "#B9ECFA",
      "icon": "lightbulb",
      "sortOrder": 0,
      "createdAt": "2026-07-01T10:00:00Z",
      "updatedAt": "2026-07-01T10:00:00Z"
    }
  ],
  "cards": [
    {
      "id": "018f7b73-0000-7000-8000-00000000000a",
      "url": "https://www.instagram.com/p/ABC123/?igshid=xyz",
      "canonicalUrl": "https://instagram.com/p/ABC123",
      "domain": "instagram.com",
      "title": "Cómo mejorar el onboarding de tu app",
      "description": "Una recopilación de ideas para...",
      "imageUrl": "https://scontent.cdninstagram.com/...",
      "faviconUrl": "https://instagram.com/favicon.ico",
      "siteName": "Instagram",
      "platform": "instagram",
      "status": "pending",
      "notes": "Revisar para Trivali",
      "originalSharedText": "Mira esto https://instagram.com/p/ABC123/",
      "createdAt": "2026-08-08T14:22:31.482Z",
      "updatedAt": "2026-08-09T09:11:02.104Z",
      "metadataFetchedAt": "2026-08-08T14:22:33.900Z",
      "metadataStatus": "partial"
    }
  ],
  "cardCategories": [
    {
      "cardId": "018f7b73-0000-7000-8000-00000000000a",
      "categoryId": "018f7b73-0000-7000-8000-000000000001",
      "createdAt": "2026-08-08T14:25:00Z"
    }
  ]
}
```

**Reglas fijadas ahora para no romper compatibilidad después:**

- `localImage` **no** se exporta (ruta específica del dispositivo, sin valor fuera de él)
- Todas las fechas en ISO-8601 UTC con milisegundos
- Enums como texto en minúsculas
- Un importador debe **ignorar campos desconocidos** en lugar de fallar — es lo que permite que la v1 lea archivos de la v2
- `counts` permite detectar truncamiento antes de empezar a importar

---

## 13. Estrategia de pruebas

| Nivel | Alcance | Herramienta |
|-------|---------|-------------|
| Unitario | `UrlNormalizer` (40+ casos), extractor de metadata (fixtures HTML), mapeadores, serialización JSON | `flutter_test` |
| DAO | Todas las consultas, `CASCADE`, `UNIQUE`, migraciones | `NativeDatabase.memory()` |
| Widget | LinkCard en sus 3 estados de metadata, filtros, estados vacíos, Quick Save | `flutter_test` |
| Integración | Los 20 criterios de §55 | `integration_test` |
| Arquitectura | `domain/` sin Flutter/Drift; sin colores literales fuera de `tokens.dart` | test propio sobre imports |
| Manual | Share Sheet en dispositivo físico (no automatizable) | checklist en `docs/` |

**Objetivo de cobertura:** >80% en `core/` y `domain/`. La UI no se persigue por porcentaje.

---

## 14. Estimación

| Hito | Fases | Días |
|------|-------|------|
| A — Cimientos y de-risking | F0–F5 | 10 |
| B — Producto usable local | F6–F11 | 16 |
| C — Captura | F12 | 4 |
| D — Portabilidad y pulido | F13–F16 | 8 |
| **Total efectivo** | | **38** |
| **Con buffer 20%** | | **~46 días** (≈9 semanas) |

### Priorización si hay que recortar

Los 20 criterios de aceptación de §55 **no exigen** lo siguiente. Son candidatos a P1 (post-MVP) sin comprometer la definición de "terminado" del propio PRD:

- Selección múltiple y acciones en lote (§26) — ~2 d
- Kanban dentro de categoría (§22) — ~0.5 d
- Atajos de teclado (§40) — ~1 d
- Caché local de imágenes (§44) — ~1 d *(recomiendo **no** recortar: es el riesgo R5, y recuperarlo después no rescata las imágenes ya perdidas)*
- Drag & drop en escritorio (§15 de este plan) — ~1 d

Recorte máximo razonable: **~4.5 días**.

---

## 15. Decisiones confirmadas (2026-08-10)

| # | Decisión | Resolución |
|---|----------|------------|
| 1 | Alcance de plataformas del MVP | **Android es la prioridad.** Después iOS, después macOS. Windows NO soportado en 1.0. La Fase 0 genera sólo `ios/`, `android/` y `macos/` |
| 5 | Identidad de la aplicación | Bundle ID / applicationId **`app.sambadesk.links`** en las 3 plataformas. Nombre visible **SambaLinks** |
| 2 | Terminología de "Inbox" | **"Bandeja"** |
| 3 | `CMD+F` | **Buscar.** Filtros a `CMD+SHIFT+F` (ver §4.5) |
| 4 | iPhone físico para el spike de F1 | **Disponible.** El plan mantiene su orden original y el riesgo R1 se resuelve en la Fase 1 |

Con esto no queda ninguna decisión abierta que bloquee la ejecución. El plan está listo para arrancar en la Fase 0.

### Implicación de la decisión 1 sobre el orden de trabajo

Android es la plataforma de referencia. Concretamente:

- **Android es la que decide si una fase está terminada.** Cuando una verificación exija ejecutar en un dispositivo, se ejecuta en Android; iOS y macOS se comprueban después, no antes.
- **F1 se parte en 1A (Android) y 1B (iOS).** 1A va primero y desbloquea el flujo principal del producto sin depender de Xcode ni de un iPhone.
- **F0–F6:** el código es agnóstico de plataforma (datos, dominio, URL, metadata, design system). Se compila para las 3; se prueba en Android.
- **F7 en adelante:** el shell responsive obliga a levantar macOS para validar los breakpoints de tablet y escritorio, así que desde ahí macOS entra en la rutina de pruebas.
- **F15** concentra el trabajo específico de escritorio (atajos, drag & drop, ventana).
- **Orden de publicación:** Android primero. iOS y macOS pueden salir después sin re-trabajo, porque toda la lógica vive en Dart compartido.

**Toda plataforma soportada se ejecuta en hardware real durante el desarrollo.** No se publica nada que no se haya corrido.

**Lo que la prioridad de Android NO cambia:** ninguna decisión de arquitectura. La única parte del plan realmente específica de plataforma es F1B (el Share Extension de iOS). Todo lo demás — Drift, repositorios, normalización de URL, metadata, design system, Kanban, import/export — es idéntico en las 3 plataformas.

### Consecuencias de excluir Windows

Lo que hay que sostener a lo largo del proyecto para que la decisión no se deshaga sola:

- **Nada de `windows/` en el repositorio.** Una carpeta generada "por si acaso" acumula deuda invisible y acaba publicándose sin haberse ejecutado nunca.
- **Ninguna dependencia se descarta por Windows.** Se elige el paquete por su calidad en iOS/Android/macOS. Esto amplía las opciones en F15 (`window_manager`, `desktop_drop`).
- **Reversibilidad:** añadir Windows más tarde es `flutter create --platforms=windows .` sobre el proyecto existente, más el QA correspondiente. La arquitectura no lo impide en ningún punto — las 3 decisiones estructurales del PRD (SQLite, JSON versionado, UUID) son agnósticas de plataforma. Coste estimado de reincorporarlo después: ~3 días, casi todo QA.
- **Comunicación:** los materiales de la 1.0 deben decir "iOS, Android y macOS", no "multiplataforma".

---

## Anexo — Comprobaciones ya realizadas para este plan

- Versiones de los 28 paquetes consultadas en la API de pub.dev el 2026-08-10
- Confirmado que `sqlite3_flutter_libs` está EOL y que `sqlite3` 3.5.1 ya incluye los binarios nativos
- Confirmado que `receive_sharing_intent` sigue mantenido (1.9.0, publicado 2026-06-24)
- Descartado `metadata_fetch` por abandono (última publicación 2024-09)
- Contrastes WCAG calculados para los 17 pares de color relevantes de la paleta del PRD

---

## 16. Decisión abierta: Swift Package Manager (R7)

Descubierto al ejecutar la Fase 1A el 2026-08-12.

`receive_sharing_intent` **1.9.0** declara soporte únicamente para Swift Package Manager en sus plataformas Apple. La consecuencia no es que iOS falle: es que `flutter pub get`, `flutter analyze`, `flutter test` y **`flutter build apk`** salen todos con código 1. Un requisito de iOS bloquea Android por completo.

### Estado actual: anclado a 1.8.1

Para desbloquear Android hoy, el proyecto usa `receive_sharing_intent: 1.8.1` (octubre 2024). Esa versión trae su propio peaje: declara `jvmTarget 1.8` mientras el proyecto compila con 21, y Gradle aborta por la incoherencia. Está parcheado en `android/build.gradle.kts` con un bloque `subprojects` que unifica a JVM 17, **marcado como provisional**.

La API que usamos (`instance`, `getInitialMedia`, `getMediaStream`, `reset`, `setMockValues`) es idéntica en ambas versiones, así que el código Dart no cambia con ninguna de las dos opciones.

### Opción A — Habilitar SPM y volver a 1.9.0 (recomendada)

```bash
flutter config --enable-swift-package-manager
```

- ✅ Plugin mantenido (última publicación junio 2026)
- ✅ Se borra el parche de Gradle
- ✅ SPM es la dirección oficial de Flutter; el problema no reaparece
- ⚠️ Es un ajuste **global** de la instalación de Flutter, no del proyecto. Los demás proyectos Flutter de la máquina (SambaPets, Samba Domus) recibirán integración SPM en su Xcode project la próxima vez que se compilen para iOS. CocoaPods y SPM conviven, así que el riesgo es bajo, pero el cambio es visible en el diff de esos repositorios
- ⚠️ Reversible con `flutter config --no-enable-swift-package-manager`

### Opción B — Mantener 1.8.1

- ✅ No toca nada fuera de este proyecto
- ⚠️ Dependencia congelada en octubre 2024
- ⚠️ Hay que mantener el parche de `jvmTarget` y arrastrarlo a cada actualización de Gradle o Kotlin
- ⚠️ El problema reaparece en F1B: es la versión que documenta el flujo de Share Extension moderno

**Recomendación:** Opción A, ejecutada por ti en un momento en que puedas recompilar los otros proyectos para iOS y confirmar que siguen bien. No es una decisión que deba tomarse dentro de este proyecto sin avisar, porque su efecto está fuera de él.
