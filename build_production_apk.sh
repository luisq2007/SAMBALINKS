#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$ROOT_DIR"
ANDROID_DIR="$APP_DIR/android"
KEY_PROPERTIES_FILE="$ANDROID_DIR/key.properties"
KEY_PROPERTIES_EXAMPLE="$ANDROID_DIR/key.properties.example"
SYMBOLS_DIR="$APP_DIR/build/app/outputs/symbols"

CLEAN_BUILD=true
BUILD_MODE="debug"
SPLIT_PER_ABI=false
OBFUSCATE=false
ANALYZE_SIZE=false

usage() {
  cat <<'EOF'
Uso: ./build_production_apk.sh [opciones]

Opciones:
  --no-clean         Omite flutter clean.
  --release          Genera APK release firmado.
  --split-per-abi    Genera APKs separados por ABI.
  --obfuscate        Activa obfuscation y split-debug-info.
  --analyze-size     Genera reporte de tamano del build.
  -h, --help         Muestra esta ayuda.

Notas:
  - Por defecto genera un APK debug universal.
  - APP/android/key.properties solo es obligatorio para release.
  - Para Google Play debes subir un AAB, no un APK.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --no-clean)
      CLEAN_BUILD=false
      ;;
    --release)
      BUILD_MODE="release"
      ;;
    --split-per-abi)
      SPLIT_PER_ABI=true
      ;;
    --obfuscate)
      OBFUSCATE=true
      ;;
    --analyze-size)
      ANALYZE_SIZE=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: opcion no reconocida: $arg" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: flutter no esta instalado o no esta en el PATH." >&2
  exit 1
fi

if [[ ! -d "$APP_DIR" ]]; then
  echo "Error: no se encontro la carpeta APP en $APP_DIR." >&2
  exit 1
fi

if [[ ! -f "$APP_DIR/pubspec.yaml" ]]; then
  echo "Error: no se encontro APP/pubspec.yaml." >&2
  exit 1
fi

if [[ "$BUILD_MODE" == "release" && ! -f "$KEY_PROPERTIES_FILE" ]]; then
  echo "Error: falta APP/android/key.properties para firmar el APK release." >&2
  if [[ -f "$KEY_PROPERTIES_EXAMPLE" ]]; then
    echo "Crea APP/android/key.properties a partir de APP/android/key.properties.example y completa los datos del keystore." >&2
  fi
  exit 1
fi

cd "$APP_DIR"

if [[ "$CLEAN_BUILD" == true ]]; then
  echo "[1/4] Limpiando build anterior..."
  flutter clean
else
  echo "[1/4] Omitiendo flutter clean."
fi

echo "[2/4] Descargando dependencias..."
flutter pub get

BUILD_CMD=(flutter build apk --"$BUILD_MODE")

if [[ "$SPLIT_PER_ABI" == true ]]; then
  BUILD_CMD+=(--split-per-abi)
fi

if [[ "$OBFUSCATE" == true ]]; then
  mkdir -p "$SYMBOLS_DIR"
  BUILD_CMD+=(--obfuscate --split-debug-info="$SYMBOLS_DIR")
fi

if [[ "$ANALYZE_SIZE" == true ]]; then
  BUILD_CMD+=(--analyze-size)
fi

echo "[3/4] Compilando APK release..."
printf 'Comando: '
printf '%q ' "${BUILD_CMD[@]}"
printf '\n'
"${BUILD_CMD[@]}"

echo "[4/4] APKs generados:"

if [[ "$SPLIT_PER_ABI" == true ]]; then
  find "$APP_DIR/build/app/outputs/flutter-apk" -maxdepth 1 -type f -name "app-*-$BUILD_MODE.apk" -print | sort
else
  find "$APP_DIR/build/app/outputs/flutter-apk" -maxdepth 1 -type f -name "app-$BUILD_MODE.apk" -print | sort
fi

if [[ "$OBFUSCATE" == true ]]; then
  echo
  echo "Simbolos de depuracion guardados en:"
  echo "$SYMBOLS_DIR"
fi

echo
echo "Build release completado."