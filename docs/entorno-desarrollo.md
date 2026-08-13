# Entorno de desarrollo

Incidencias específicas de esta máquina y de las versiones fijadas. Cada una
tiene su causa y su solución para no volver a investigarlas.

---

## 1. `flutter test` falla al descargar la librería nativa de SQLite

**Síntoma**

```
By default, this package downloads a pre-compiled SQLite library.
This failed (attepted to download https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.5.1/libsqlite3.arm64.macos.dylib).
Original cause: HttpException: Connection closed before full header was received
```

**Causa**

`sqlite3` 3.5.1 descarga un binario precompilado mediante un build hook al
ejecutar tests en el host. El cliente HTTP de Dart falla en esta red; `curl`
contra la misma URL funciona sin problema.

El mismo problema aparece al **compilar para Android**, con otra cara: ahí la
descarga no falla, llega corrupta.

```
Bad state: Hash of downloaded file libsqlite3.arm.android.so is 8394...,
expected a42f...
```

**Solución**

El hook cachea cada binario en un directorio nombrado con los 8 primeros
caracteres de su SHA256, y lo valida por hash antes de reutilizarlo. Basta con
dejarlos ahí a mano. Este script cubre el host y las tres ABI de Android:

```bash
BASE="https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.5.1"
SHARED=".dart_tool/hooks_runner/shared/sqlite3/build"
mkdir -p "$SHARED"; find "$SHARED" -name "*.tmp" -delete

# macOS (tests en el host)
curl -fsSL -o /tmp/lib.dylib "$BASE/libsqlite3.arm64.macos.dylib"
sha=$(shasum -a 256 /tmp/lib.dylib | cut -d' ' -f1)
mkdir -p "$SHARED/download-${sha:0:8}"
cp /tmp/lib.dylib "$SHARED/download-${sha:0:8}/libsqlite3.dylib"

# Android (ojo: la ABI de 64 bits se llama x64, no x86_64)
for abi in arm arm64 x64; do
  curl -fsSL -o "/tmp/$abi.so" "$BASE/libsqlite3.$abi.android.so"
  sha=$(shasum -a 256 "/tmp/$abi.so" | cut -d' ' -f1)
  mkdir -p "$SHARED/download-${sha:0:8}"
  cp "/tmp/$abi.so" "$SHARED/download-${sha:0:8}/libsqlite3.so"
done
```

Si `curl` devuelve un fichero de 0 bytes, reintenta: la caída es intermitente.
El `-f` evita que un error HTTP se guarde como si fuera el binario.

**Cuándo se repite:** tras `flutter clean` o al borrar `.dart_tool`.

---

## 1b. Sin `riverpod_generator`

`riverpod_generator` exige `analyzer ^12` y `drift_dev` exige `^13`; el
`meta 1.17.0` que fija el SDK de Flutter 3.41.6 impide cualquier combinación.
No es un problema de rangos que se arregle aflojando una restricción.

Los providers se declaran a mano en `lib/core/providers.dart`. La API es
equivalente; sólo se pierde el azúcar sintáctico de las anotaciones.

`freezed` sí convive sin problema y se usa para las entidades de dominio.

---

## 2. `receive_sharing_intent` anclado a 1.8.1

**Por qué no usamos 1.9.0:** su `build.gradle` de Android da por supuesto
AGP 9.x. Con el AGP 8.11.1 que genera Flutter 3.41.6 falla de tres formas
encadenadas (bloque `kotlin {}` sin plugin aplicado, `compileSdk 37` con
nomenclatura `major.minor`, y fuentes Kotlin sin compilar). Ver §16 del plan
de implementación.

**Consecuencia:** `android/build.gradle.kts` lleva un bloque `subprojects` que
unifica `jvmTarget` a 17, porque 1.8.1 declara 1.8 y el proyecto compila con 21.

**Cuándo quitarlo:** cuando el proyecto suba a AGP 9. Entonces: subir el plugin
a `^1.9.0`, borrar el bloque `subprojects`, y reejecutar la verificación de la
Fase 1A.

**Swift Package Manager** está habilitado en la máquina
(`flutter config --enable-swift-package-manager`). Hace falta para la Fase 1B
(Share Extension de iOS) y no se revierte.

---

## 3. Bundle ID

`app.sambadesk.links` en Android, iOS y macOS.

`flutter create` no puede generarlo directamente, porque el último segmento
(`links`) no coincide con el nombre del paquete Dart (`sambalinks`). Si alguna
vez hay que regenerar una plataforma, después toca reescribirlo en los cuatro
archivos de configuración nativa y mover `MainActivity.kt` a
`android/app/src/main/kotlin/app/sambadesk/links/`.

---

## 4. Verificación en Android sin salir de la terminal

Simular un "compartir" desde otra aplicación:

```bash
adb shell "am start -a android.intent.action.SEND -t text/plain --es android.intent.extra.TEXT 'Mira esto https://instagram.com/p/ABC123/' -n app.sambadesk.links/.MainActivity"
```

El entrecomillado importa: sin las comillas simples internas, el shell del
dispositivo parte el texto por los espacios y el intent no resuelve.
