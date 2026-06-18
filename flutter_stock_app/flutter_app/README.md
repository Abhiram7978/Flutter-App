# Stock Research App — Flutter Client (Phase 1)

A mobile market-data viewer for the AI Stock Research Platform backend. This is intentionally scoped to what the Phase 1 backend actually supports: stock browsing, search, historical price charts, and a personal watchlist. There is no scoring, recommendation, or technical-indicator UI yet, because the backend doesn't compute any of that yet either — building those screens now would mean displaying functionality that doesn't exist.

## Important: this repository does not contain a compiled APK

Everything in this folder is Flutter/Dart **source code**. No `.apk` file is included, and none was built during code generation, because the environment that generated this code has no Flutter SDK installed and no access to Flutter's package registry (pub.dev). That is a constraint of the generation environment, not a gap in the project — the code itself is complete and should build correctly once you run it through a real Flutter toolchain on your own machine.

## What you need to build the APK yourself

1. **Flutter SDK** (3.19 or newer) — install from [flutter.dev](https://docs.flutter.dev/get-started/install)
2. **Android SDK** — comes with Android Studio, or can be installed standalone via `sdkmanager`
3. Run `flutter doctor` and resolve anything it flags before continuing

## Setup

```bash
# From inside this flutter_app/ directory:

# 1. Get dependencies
flutter pub get

# 2. Configure local Android SDK / Flutter SDK paths
cp android/local.properties.example android/local.properties
# Edit android/local.properties with your actual SDK paths

# 3. Set your backend API key
# Edit lib/core/api/api_config.dart and replace:
#   static const String apiKey = 'REPLACE_WITH_YOUR_API_KEY';
# with the same value as API_KEY in the backend's .env file.

# 4. Build the APK
flutter build apk --release
```

The resulting APK will be at `build/app/outputs/flutter-apk/app-release.apk`. Install it on a connected device or emulator with `flutter install`, or copy the file and install it directly.

## Connecting to the backend

`lib/core/api/api_config.dart` has the base URL:

- **Android emulator**, backend running on the same machine: leave it as `http://10.0.2.2:8000` — this is the special address Android emulators use to reach the host machine's localhost.
- **Physical device** on the same Wi-Fi network as your backend: change it to your computer's LAN IP, e.g. `http://192.168.1.50:8000`.
- **Production / remote backend**: change it to your deployed domain over HTTPS, e.g. `https://api.yourdomain.com`, and also remove `android:usesCleartextTraffic="true"` from `android/app/src/main/AndroidManifest.xml` — that flag exists only to allow plain `http://` during local development and is a real security gap if left in for a production deployment.

## A note on the gradle-wrapper.jar file

This project does not include `android/gradle/wrapper/gradle-wrapper.jar`. That file is a compiled Java binary that Flutter normally generates for you — it isn't something that can be authored as readable source code, and it wasn't fabricated here as a fake placeholder. The fix is one command:

```bash
flutter create --platforms=android .
```

Run this once from inside `flutter_app/` before your first build. It will regenerate the wrapper jar (and a couple of other Gradle housekeeping files) without touching any of the Dart source code already in `lib/`. If it prompts to overwrite files, only accept overwrites under `android/` — never overwrite anything in `lib/` or `test/`.

## Running tests

```bash
flutter test
```

Covers both Blocs (`StockListBloc`, `StockDetailBloc`) using `bloc_test` and `mocktail` — no real network calls, no device required. These tests have not been executed in the environment that generated this code (no Flutter SDK available there), so treat a clean `flutter test` run on your machine as the first real verification this code compiles and behaves as intended.

## What's deliberately not in Phase 1

- **No recommendation/scoring screens** — the backend doesn't compute these yet (see the backend's `docs/ARCHITECTURE_NOTES.md`).
- **No true candlestick chart** — the price chart is a close-price line chart. `fl_chart` has no first-class candlestick widget, and building one well (wicks, gap handling for non-trading days, volume profile) is enough work to deserve its own pass once intraday data exists server-side. The line chart honestly represents what daily-EOD-only data supports.
- **No server-synced watchlist** — watchlist is stored locally on-device via `shared_preferences`. There's no `/api/v1/watchlist` backend endpoint, so nothing syncs across devices yet.
- **No admin/data-quality screen** — deferred per project decision to a separate, smaller internal tool later, since it's an operations surface for you, not an end-user feature.

## Project structure

```
lib/
  core/
    api/          API client, typed exceptions, repository
    storage/       Local watchlist persistence
    theme/         Colors, dark theme, the colorForChange() helper
    utils/         Price/date/volume formatters
  features/
    stock_list/    Browse + search + universe filter
    stock_detail/   Profile + price chart + watchlist toggle
    watchlist/      Locally saved tickers
  shared/
    models/         Stock, Candle — mirror backend JSON shapes exactly
  app.dart           Root widget + bottom nav shell
  main.dart           Entry point
test/                 Bloc tests (no device/network required)
android/               Platform files needed for `flutter build apk`
```
