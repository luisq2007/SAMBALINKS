# Prompt de continuación — SambaLinks, Fase 5

Copia todo lo que hay debajo de la línea en la ventana nueva.

---

Trabajo en `/Users/luisquintero/Documents/SAMBALINKS`, una app Flutter llamada
SambaLinks: un gestor personal de enlaces, local-first, sin cuentas, **con toda
la interfaz en español**.

**Antes de escribir código, lee estos dos ficheros enteros:**

1. `PLAN_IMPLEMENTACION.md` — el plan por fases. Tiene el estado de cada fase,
   las decisiones ya tomadas y por qué. Presta atención a §2 (riesgos), §4
   (ajustes al PRD), §15 (decisiones cerradas) y §16 (la historia del plugin de
   compartir).
2. `docs/entorno-desarrollo.md` — incidencias de esta máquina. **No las
   descubras por tu cuenta, están todas ahí.**

## Estado actual

Fases 0, 1A, 2, 3 y 4 completadas. 120 tests en verde y `flutter analyze` sin
issues. La app corre en emulador Android y recibe enlaces compartidos.

- Flutter 3.41.6 · Dart 3.11.4 · macOS arm64
- Bundle ID en las 3 plataformas: `app.sambadesk.links`
- Plataformas soportadas en 1.0: **Android (prioridad), iOS, macOS**. Windows no.
- Rama `master`, con trabajo sin commitear. Pregunta antes de commitear.

Lo que ya existe:

| Capa | Dónde |
|---|---|
| Base de datos (Drift) | `lib/core/database/` — tablas, DAOs, migraciones, semilla |
| Dominio | `lib/features/*/domain/` — entidades freezed, interfaces de repositorio |
| Datos | `lib/features/*/data/` — mapeadores e implementaciones sobre Drift |
| Estado | `lib/core/providers.dart` — providers de Riverpod, declarados a mano |
| Pipeline de URL | `lib/features/links/domain/` — extractor, normalizador, detector |
| Design system | `lib/core/theme/` — `tokens.dart` y `app_theme.dart` |
| Textos | `lib/core/l10n/app_es.arb` |

## Tu tarea: Fase 5 — Servicio de metadata

Está descrita en el plan (busca "Fase 5"), con el detalle de diseño en §8.
Resumen de lo que hay que construir:

- `MetadataProvider` como interfaz + `DirectMetadataProvider` con tres
  estrategias encadenadas: oEmbed → HTML (Open Graph / Twitter Cards) →
  fallback que **nunca falla**.
- Cliente Dio: timeout 8 s, límite de 512 KB de descarga, máximo 5 redirects.
- La prioridad exacta de título, descripción e imagen está en §9 del PRD y
  copiada en §8.2 del plan.
- Descarga y persistencia local de imágenes (riesgo R5: las URLs firmadas de
  Instagram y Facebook caducan y vaciarían la biblioteca en semanas).
- Cola con concurrencia máxima de 3.
- Resolución de acortadores y **segunda comprobación de duplicado** tras seguir
  la redirección (riesgo R4). El normalizador ya marca estos casos con
  `needsNetworkResolution`.

Lo más importante de esta fase no es el camino feliz: **Instagram, X, Facebook
y LinkedIn van a caer al fallback casi siempre** (muro de login). La tabla de
expectativas por plataforma está en §8.3 del plan. El estado `partial` no es un
error, es el resultado normal, y la tarjeta tiene que verse bien en ese estado.

Los tests van con **fixtures HTML locales, no contra la red**: OG completo,
sólo Twitter Cards, sólo `<title>`, muro de login de Instagram, HTML malformado,
redirect 301, respuesta 403 y una respuesta de 5 MB que debe cortarse a 512 KB.

## Restricciones del entorno que NO debes intentar "arreglar"

Cada una está documentada con su causa. Cambiarlas rompe la compilación.

1. **`receive_sharing_intent` está anclado a 1.8.1.** La 1.9.0 exige AGP 9.x y
   este proyecto usa el AGP 8.11.1 que genera Flutter 3.41.6. Ya se intentó
   subir y falla en tres sitios encadenados. El bloque `subprojects` de
   `android/build.gradle.kts` existe por eso y no se toca.
2. **No uses `riverpod_generator`.** Exige `analyzer ^12` y `drift_dev` exige
   `^13`; el `meta 1.17.0` del SDK de Flutter cierra cualquier combinación. Los
   providers se declaran a mano. `freezed` sí funciona.
3. **`sqlite3` descarga sus librerías nativas desde GitHub y en esta red llegan
   corruptas o vacías.** Si `flutter test` o `flutter build apk` fallan con
   `Bad state: Hash of downloaded file...` o `Building native assets failed`,
   ejecuta el script de la sección 1 de `docs/entorno-desarrollo.md`. Hay que
   repetirlo tras cada `flutter clean`.
4. **Espacio en disco.** La máquina va justa. Si algo falla con
   `No space left on device`, borra `build/` (regenerable). **No uses
   `flutter clean`**: se lleva por delante `.dart_tool` y con él la caché del
   punto 3.

## Reglas que hacen cumplir los tests

`test/architecture/layering_test.dart` falla si las rompes:

- `features/*/domain/` no puede alcanzar Flutter, Drift ni Riverpod, **ni
  siquiera de forma transitiva**. El test sigue la clausura de imports.
- Ningún widget importa Drift ni `app_database`.
- Ningún fichero bajo `lib/features/` o `lib/shared/` declara un `Color(0x...)`
  literal. Todo color sale de `lib/core/theme/tokens.dart`.

## Convenciones

- **Todo el texto visible va en `lib/core/l10n/app_es.arb`.** Nada de strings
  incrustados en widgets. Regenera con `flutter gen-l10n`.
- Glosario fijado: `pending`→Pendiente, `active`→Activo, `done`→Atendido,
  Inbox→**Bandeja**. Está en §10 del plan.
- Enums a base de datos como **texto**, nunca como índice ordinal.
- Comentarios en español, y sólo donde expliquen un *porqué* que no se deduce
  del código.
- Código generado (`*.g.dart`, `*.freezed.dart`, `app_localizations*.dart`) **se
  versiona a propósito**. Regenera con
  `dart run build_runner build --delete-conflicting-outputs`.

## Cómo verificar

```bash
flutter analyze          # debe salir sin issues
flutter test             # 120 tests antes de tu trabajo
flutter build apk --debug
```

Para probar el flujo de compartir en el emulador sin usar la hoja del sistema:

```bash
adb shell "am start -a android.intent.action.SEND -t text/plain --es android.intent.extra.TEXT 'Mira esto https://instagram.com/p/ABC123/' -n app.sambadesk.links/.MainActivity"
```

El entrecomillado importa: sin las comillas simples internas el shell del
dispositivo parte el texto por los espacios.

Hay un emulador y un móvil físico (`R5CWC31VDDX`) que pueden estar conectados a
la vez. Si `adb` se queja de "more than one device", usa
`export ANDROID_SERIAL=emulator-5554`.

## Cómo quiero que trabajes

- Verifica ejecutando, no sólo compilando. Cuando algo debe verse, hazle una
  captura y míralo.
- Si un test pasa, comprueba que también sabe fallar antes de darlo por bueno.
- Al terminar la fase, márcala como completada en `PLAN_IMPLEMENTACION.md` con
  la fecha y lo que se verificó, igual que están las anteriores. Si te desvías
  del plan, anota la desviación y el porqué.
- Si una incidencia de entorno se resuelve con un truco, documéntalo en
  `docs/entorno-desarrollo.md`.
- Dime lo que no funcionó tal cual, sin suavizarlo.
