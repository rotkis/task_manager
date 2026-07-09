#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Fix: o pacote `alarm` v5.5.0 declara compileSdkVersion=34 no Android, mas
# depende de `flutter_fgbg` que exige 35+. Isto corrige o build editando
# o build.gradle do alarm no cache do pub.
#
# Uso: bash tools/fix_alarm_compile_sdk.sh
# Execute sempre depois de `flutter pub get`.
# ---------------------------------------------------------------------------
set -euo pipefail

ALARM_BUILD_FILE="$HOME/.pub-cache/hosted/pub.dev/alarm-5.5.0/android/build.gradle"

if [ ! -f "$ALARM_BUILD_FILE" ]; then
	echo "Arquivo não encontrado: $ALARM_BUILD_FILE"
	echo "Execute 'flutter pub get' primeiro."
	exit 1
fi

# Faz o patch: compileSdkVersion 34 → 36
sed -i 's/compileSdkVersion 34/compileSdkVersion 36/' "$ALARM_BUILD_FILE"

echo "✓ Alarme compileSdkVersion corrigido para 36 em:"
echo "  $ALARM_BUILD_FILE"
