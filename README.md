# CalcNova

<img src="screenshot.jpg" alt="CalcNova navigation and calculator interface" width="420">

CalcNova is an all-in-one calculator application designed to make everyday calculations and unit conversions simple, quick, and convenient. It brings essential mathematical tools into one clean interface, including basic and scientific calculations and a range of common unit converters. The app is designed to work offline, with a focus on usability, accuracy, and a lightweight experience.

## Highlights

- Basic calculator with operator precedence, percentages, decimals, repeated calculations, clear, and backspace.
- Scientific calculator with trigonometric functions, logarithms, powers, roots, factorials, constants, and degree/radian support.
- Offline converters for length, area, volume, mass, temperature, speed, pressure, and power.
- Dark, light, and system theme options.
- Responsive layouts for phones, tablets, portrait, and landscape orientations.
- Local preferences with no account, database, analytics, advertising, or calculation backend.
- Consistent typography, animated mode transitions, accessible controls, and responsive touch targets.

## Download

Download the latest release APK:

[Download CalcNova v0.0.01](https://github.com/mahinexe/CalcNova/releases/latest/download/calcnova_v0.0.01.apk)

Android may require permission to install an APK downloaded outside Google Play. Enable installation from the relevant source only when you trust the APK.

## Install the APK

1. Download the APK from the release link above.
2. Open the downloaded APK and review the Google Play Protect warning.
3. Tap **More details**, then tap **Install anyway** to continue.

The warning can appear because the APK is distributed outside Google Play and Play Protect has not seen an app from this developer before. Only install the APK when it came from the official CalcNova release link and you trust the source.

<p>
  <img src="install_steps.jpg" alt="Steps to install CalcNova when Google Play Protect displays a warning" width="700">
</p>

## Requirements

- Flutter 3.47.7 or a compatible stable release
- Dart 3.13.5 or compatible SDK
- Android SDK for Android builds
- Linux GTK development dependencies for Linux desktop builds

## Run locally

```bash
flutter pub get
flutter run
```

To run the Linux desktop build:

```bash
flutter run -d linux
```

## Validate and build

```bash
flutter analyze
flutter test
flutter build apk --release
flutter build linux --release
```

The Android release output is generated under `build/app/outputs/flutter-apk/`. The Linux bundle is generated under `build/linux/x64/release/bundle/`. Configure release signing before publishing to Google Play.

## Project structure

```text
lib/
├── core/
│   ├── theme/
│   └── utils/
├── features/
│   ├── about/
│   ├── basic_calculator/
│   ├── converters/
│   ├── scientific_calculator/
│   ├── settings/
│   └── shared/
├── app.dart
└── main.dart
```

## Privacy

Calculations, conversions, and preferences run locally on the device. Internet access is used only when a user deliberately opens an external link from the About page.

## Author

CalcNova is developed by [Mohammodullah Al Mahin](https://github.com/mahinexe).
