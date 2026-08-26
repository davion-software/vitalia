# Vitalia

Aplicación móvil de Vitalia, desarrollada con Flutter para Android y iOS.

> Estado actual: el repositorio contiene la base inicial de Flutter y su pantalla de ejemplo. Las funcionalidades del producto todavía no están implementadas.

## Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) 3.47.1 o una versión estable compatible
- Dart 3.13.1 o superior, incluido con Flutter
- Para Android: Android Studio y Android SDK
- Para iOS: macOS, Xcode y CocoaPods

Comprueba la instalación antes de continuar:

```bash
flutter doctor
```

## Configuración local

Clona el repositorio e instala las dependencias:

```bash
git clone git@github.com:davion-software/vitalia.git
cd vitalia
flutter pub get
```

Por ahora el proyecto no requiere variables de entorno. Si se agregan más adelante, documenta cada variable en un archivo `.env.example`; los archivos `.env` locales están excluidos de Git.

## Ejecutar la aplicación

Inicia un emulador o conecta un dispositivo y ejecuta:

```bash
flutter run
```

Puedes listar los dispositivos disponibles con:

```bash
flutter devices
```

## Verificaciones

Antes de abrir un pull request, formatea y valida los cambios:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Estructura

```text
android/             Proyecto nativo de Android
ios/                 Proyecto nativo de iOS
lib/main.dart        Punto de entrada de la aplicación
test/                Pruebas automatizadas
pubspec.yaml         Dependencias y configuración de Flutter
```

## Flujo de trabajo recomendado

1. Crea una rama desde `main`.
2. Implementa y valida el cambio localmente.
3. Usa commits breves que describan una sola intención.
4. Abre un pull request hacia `main`.

## Acceso

Proyecto de uso interno de Davion Software. No distribuyas el código ni sus credenciales sin autorización.
