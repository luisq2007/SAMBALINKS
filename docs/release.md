# Proceso de release

Cómo se construye y se publica SambaLinks 1.0 en las tres plataformas
soportadas: **Android, iOS y macOS**. Windows queda fuera de la 1.0 (§15 del
plan) y no se compila.

Todos los comandos se ejecutan desde la raíz del repositorio.

---

## 1. Antes de construir nada

```bash
flutter analyze && flutter test
```

Ambos tienen que salir limpios. No se construye un artefacto sobre una suite
en rojo: los errores que se cuelan aquí reaparecen en la tienda, donde
corregirlos cuesta una revisión completa.

Si `flutter test` falla al descargar la librería nativa de SQLite, no es un
problema del código — está documentado con su solución en
[entorno-desarrollo.md](entorno-desarrollo.md).

La versión se toca en un único sitio, `pubspec.yaml`:

```yaml
version: 1.0.0+1   # <nombre visible>+<build number>
```

El número de build **tiene que subir en cada envío**, aunque el nombre no
cambie. Tanto Play Console como App Store Connect rechazan un build repetido, y
el rechazo llega después de subir el binario entero.

---

## 2. Android

Es la plataforma de referencia: si una comprobación sólo puede hacerse en un
sitio, se hace aquí (§15 del plan).

### APK de prueba

```bash
flutter build apk --release
```

Sale en `build/app/outputs/flutter-apk/app-release.apk`. Sirve para instalar a
mano y para la matriz manual; **no** para Play.

### AAB para Google Play

```bash
flutter build appbundle --release
```

Sale en `build/app/outputs/bundle/release/app-release.aab`. Play sólo acepta
este formato.

### Firma

`android/app/build.gradle.kts` sigue firmando release **con la clave de
depuración**:

```kotlin
release {
    // TODO: Add your own signing config for the release build.
    signingConfig = signingConfigs.getByName("debug")
}
```

Eso permite probar `--release` en local, pero **Play rechaza un binario firmado
con la clave de depuración**. Antes del primer envío hay que crear el keystore,
rellenar `android/key.properties` a partir de `key.properties.example` y
apuntar el `signingConfig` a él. `build_production_apk.sh --release` ya espera
ese archivo.

La clave de subida no se pierde ni se rota a la ligera: sin ella no se puede
volver a publicar la misma aplicación. Copia de seguridad fuera del
repositorio, y **nunca** dentro de él (`key.properties` está en `.gitignore`).

### Restricción heredada de `receive_sharing_intent`

El plugin está anclado a **1.8.1** y `android/build.gradle.kts` lleva un bloque
`subprojects` que unifica el `jvmTarget` a 17. No es decorativo: sin él Gradle
aborta. El motivo completo y las condiciones para quitarlo están en §16 del
plan. Resumen: no se toca hasta que el proyecto suba a AGP 9.x.

---

## 3. iOS

```bash
flutter build ipa --release
```

Requiere Xcode con una cuenta de desarrollador configurada y un perfil de
aprovisionamiento para `app.sambadesk.links`.

**Swift Package Manager queda habilitado** (`flutter config
--enable-swift-package-manager`). Hace falta y no se revierte.

> El *Share Extension* de iOS (Fase 1B) **todavía no está construido**. Cuando
> se haga, sus pasos manuales de Xcode —target, App Group, `Info.plist`,
> bundle IDs— van a `docs/ios-share-extension.md`, porque no son reproducibles
> desde la línea de comandos y hay que poder repetirlos sin volver a
> investigarlos. Hasta entonces, en iOS no existe la ruta "compartir hacia
> SambaLinks"; se guarda a mano desde la propia app.

---

## 4. macOS

```bash
flutter build macos --release
```

Sale en `build/macos/Build/Products/Release/SambaLinks.app`.

Dos cosas propias de esta plataforma:

- **La ventana se configura en Swift, no con un paquete.**
  `macos/Runner/MainFlutterWindow.swift` fija `minSize` y
  `setFrameAutosaveName`. `window_manager` se descartó en la F15 porque arrastra
  `screen_retriever_macos`, que declara macOS 10.14 y rompe la compilación
  contra el mínimo 10.15 de Flutter.
- **No hay ruta de "compartir hacia la app".** `receive_sharing_intent` no
  soporta macOS. La captura en escritorio son las tres vías de la F15: arrastrar
  el enlace a la ventana, la sugerencia del portapapeles al volver a ella, y
  `CMD+N`.

Para distribuir fuera de la Mac App Store hay que firmar y notarizar; para la
tienda, `flutter build macos` y luego archivar desde Xcode.

---

## 5. Rendimiento medido (2026-08-14)

Números reales, no estimaciones. Se repiten cuando cambie algo que los pueda
mover.

| Medida | Resultado | Umbral |
|---|---|---|
| Búsqueda sobre 5.000 enlaces | 0,33 ms | <150 ms (§4.3) |
| Primera página (40 enlaces) | 0,67 ms | <150 ms |
| Página con offset 4.000 | 0,30 ms | <150 ms |
| Consulta de Bandeja | 0,34 ms | <150 ms |
| Contadores por estado | 0,25 ms | <150 ms |
| Importar 5.000 enlaces | 1,8 s | — |

Se reproducen con:

```bash
flutter test test/performance/library_load_test.dart
```

**Arranque en frío:** ~2,9 s en release sobre el emulador de Android, contra el
objetivo de <2 s. Lo importante del dato es lo otro que se midió: con la
biblioteca vacía tarda **lo mismo**, así que las 5.000 tarjetas no cuestan nada
al arrancar — la lista pagina de 40 en 40 y los contadores son agregados
indexados. El número absoluto es del emulador, que no es un teléfono; queda
pendiente medirlo en hardware real antes de darlo por bueno o por malo.

---

## 6. Checklist de envío

- [ ] `flutter analyze` limpio
- [ ] `flutter test` en verde
- [ ] `version:` subido en `pubspec.yaml` (nombre y/o build number)
- [ ] Matriz manual pasada — ver [qa-manual.md](qa-manual.md)
- [ ] Android firmado con la clave de subida real, no con la de depuración
- [ ] Icono, splash y nombre visible correctos en las tres plataformas
- [ ] Copia de seguridad del keystore fuera del repositorio
