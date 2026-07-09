# Task Manager

App anti-procrastinação com Flutter e Isar.

## Pré-requisitos

- Flutter SDK >=3.4.0
- Dart SDK >=3.4.0
- Dispositivo ou emulador Android

## Setup

```bash
flutter pub get
# Aplica patch necessário no pacote alarm (ver seção abaixo)
bash tools/fix_alarm_compile_sdk.sh
```

## Build & Run

```bash
flutter run
```

## Nota sobre o pacote `alarm`

O pacote `alarm` v5.5.0 declara `compileSdkVersion=34` no Android mas depende
de `flutter_fgbg` que exige 35+. O script `tools/fix_alarm_compile_sdk.sh`
faz o patch necessário no cache do pub.

Execute o script **sempre depois de** `flutter pub get`.
