# AGENTS.md

> Instructions for AI agents working on this repository.

## Project Overview

**VeloCambio** is a Flutter currency exchange calculator app focused on Venezuelan Bolivar (VES) conversions. It fetches real-time exchange rates for USD (BCV official + market) and EUR from the public API [dolarapi.com](https://ve.dolarapi.com/), and lets users convert between currencies or set a custom exchange rate.

## Tech Stack

- **Flutter** (SDK ^3.8.1)
- **State Management:** Provider (ChangeNotifier pattern)
- **HTTP Client:** Dio with custom interceptors
- **Local Storage:** Hive (NoSQL) for currency history, SharedPreferences for preferences
- **UI:** Material Design with dark theme, skeleton loading states
- **Code Generation:** build_runner + hive_generator for Hive adapters

## Project Structure

```
lib/
├── main.dart                    # App entry point, Provider registration
├── app.dart                     # MaterialApp configuration
├── core/
│   ├── http/                    # Dio client and interceptors
│   ├── themes/                  # Theme data and styles
│   └── services/                # App preferences (SharedPreferences)
├── datasource/
│   ├── usd_api.dart             # USD exchange rate API calls
│   ├── euro_api.dart            # EUR exchange rate API calls
│   ├── database_datasource.dart # (Legacy - commented out, Supabase)
│   └── services/
│       └── database_hive_services.dart  # Hive read/write operations
├── models/
│   ├── usd_model.dart           # USD rate models (BCV + Market)
│   ├── euro_model.dart          # EUR rate model
│   ├── custom_model.dart        # Custom exchange rate model
│   ├── currency_history_model.dart  # History record model
│   └── adapters/                # Hive TypeAdapters (generated + manual)
├── providers/
│   ├── app_providers.dart       # MultiProvider setup
│   ├── cmm_general_provider.dart # Base provider (loading/error state)
│   ├── coin_provider.dart       # Currency conversion logic
│   ├── exchange_rate_provider.dart # USD exchange rate state
│   ├── euro_provider.dart       # EUR exchange rate state
│   ├── custom_provider.dart     # Custom rate state
│   └── conectivity_status_provider.dart  # Network connectivity
├── screens/
│   └── main_screen.dart         # Single screen (all UI)
└── widgets/
    ├── appBar.dart              # Custom AppBar widget
    ├── calculator.dart          # Currency calculator/converter
    ├── exchange_rate_container.dart  # Rate display cards
    └── bcv_dialog.dart          # BCV disclaimer dialog
```

## Commands

### Run the app
```bash
flutter run
```

### Run on specific platform
```bash
flutter run -d windows
flutter run -d chrome
flutter run -d android
```

### Generate Hive adapters (after model changes)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Lint and analyze
```bash
flutter analyze
flutter lint
```

### Format code
```bash
dart format lib/
```

### Run tests
```bash
flutter test
```

### Build release
```bash
flutter build apk          # Android
flutter build appbundle    # Android (Play Store)
flutter build ios          # iOS
flutter build web          # Web
flutter build windows      # Windows
```

### Generate app icons
```bash
dart run flutter_launcher_icons
```

## Code Conventions

- **File naming:** snake_case (e.g., `exchange_rate_provider.dart`)
- **Class naming:** PascalCase (e.g., `UsdExchangeRateProvider`)
- **Barrel exports:** Each directory uses `index.dart` for re-exports
- **Provider pattern:** Extend `ChangeNotifier` or `CmmGeneralProvider` for state
- **Hive models:** Place model in `models/`, adapter in `models/adapters/`, run `build_runner` after changes
- **API calls:** Use `DioClient` from `core/http/dio_client.dart` -- do not create raw Dio instances
- **Error handling:** Use the `CustomInterceptors` toast pattern for user-facing errors
- **Theme:** Dark theme is default; theme data lives in `core/themes/`

## Architecture Rules

1. **Providers** manage state and business logic. Never do API calls directly in widgets.
2. **Datasources** handle raw API communication. They extend `CmmGeneralProvider` for loading/error state.
3. **Models** are plain Dart classes with Hive `@HiveType` annotations.
4. **Single screen:** The app currently uses only `MainScreen`. If adding screens, use `Navigator.push` or add a routing package.
5. **No secrets in code.** Environment-specific values go in `.env` files (gitignored).

## Common Tasks

### Adding a new provider
1. Create `lib/providers/your_provider.dart`
2. Extend `CmmGeneralProvider`
3. Register in `lib/providers/app_providers.dart` in the `MultiProvider`
4. Create barrel export in `lib/providers/index.dart`

### Adding a new API endpoint
1. Add the method in the relevant datasource (`lib/datasource/`)
2. Use `DioClient` for the HTTP call
3. Create/update the model in `lib/models/`
4. Call the datasource from a provider

### Adding a new Hive model
1. Create the model class with `@HiveType` and `@HiveField` annotations in `lib/models/`
2. Create the adapter manually in `lib/models/adapters/` (following existing patterns)
3. Register the adapter in `main.dart` inside `initHive()`
4. Run `dart run build_runner build --delete-conflicting-outputs`

### Adding a new widget
1. Create the widget file in `lib/widgets/`
2. Add barrel export in `lib/widgets/index.dart`
3. Keep widgets stateless when possible; use providers for state

## Known Issues

- **No tests exist.** The `test/` directory is empty.
- **Commented-out code** is present throughout (legacy Supabase integration, old features). Do not uncomment without verification.
- **`database_datasource.dart`** is entirely commented out -- Supabase was abandoned.
- **Application ID** is `com.example.velocambio` -- needs changing for production.
- **iOS display name** shows "Payment Calculator" instead of "VeloCambio" in `Info.plist`.
