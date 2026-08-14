# AGENTS.md

> Instructions for AI agents working on this repository.

## Project Overview

**VeloCambio** is a Flutter currency exchange calculator app focused on Venezuelan Bolivar (VES) conversions. It fetches real-time exchange rates for USD (BCV official + market) and EUR from the public API [dolarapi.com](https://ve.dolarapi.com/), USDT/VES rates from [Binance P2P](https://p2p.binance.com/) (best SELL price), and lets users convert between currencies or set a custom exchange rate.

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
│   ├── http/
│   │   ├── dio_client.dart      # Dio client for dolarapi.com
│   │   ├── binance_dio.dart     # Dio client for Binance P2P
│   │   └── interceptor/         # Custom interceptors
│   ├── config/
│   │   └── app_config.dart      # Env loading per flavor (flutter_dotenv)
│   ├── themes/                  # Theme data and styles
│   ├── utils/operations.dart    # Pure math helpers (% / add / subtract)
│   └── services/                # App preferences (SharedPreferences)
├── datasource/
│   ├── usd_api.dart             # USD exchange rate API calls
│   ├── euro_api.dart            # EUR exchange rate API calls
│   ├── binance_api.dart         # Binance P2P USDT/VES API calls
│   ├── bcv_history_api.dart     # GET rates/historico/bcv (paginated history)
│   ├── rates_stats_api.dart     # GET rates/brecha + rates/variaciones
│   ├── database_datasource.dart # (Legacy - commented out, Supabase)
│   └── services/
│       └── database_hive_services.dart  # Hive read/write operations
├── models/
│   ├── usd_model.dart           # USD rate models (BCV + Market)
│   ├── euro_model.dart          # EUR rate model
│   ├── binance_usdt_model.dart  # USDT P2P rate model (Binance)
│   ├── custom_model.dart        # Custom exchange rate model
│   ├── currency_history_model.dart  # History record model
│   ├── bcv_history_model.dart   # BCV history response + item (no Hive)
│   ├── multi_item_model.dart    # Multi-items calculator item (no Hive)
│   └── adapters/                # Hive TypeAdapters (generated + manual)
├── providers/
│   ├── app_providers.dart       # MultiProvider setup
│   ├── cmm_general_provider.dart # Base provider (loading/error state)
│   ├── coin_provider.dart       # Currency conversion logic
│   ├── exchange_rate_provider.dart # USD exchange rate state
│   ├── euro_provider.dart       # EUR exchange rate state
│   ├── binance_provider.dart    # USDT P2P exchange rate state
│   ├── custom_provider.dart     # Custom rate state
│   ├── bcv_history_provider.dart # BCV history + lazy pagination
│   ├── multi_items_provider.dart # Multi-items calculator state
│   └── conectivity_status_provider.dart  # Network connectivity
├── screens/
│   ├── main_screen.dart         # Shell: Scaffold + NavigationBar + IndexedStack
│   ├── home_tab.dart            # Tab 1: rates + custom rate + calculator
│   ├── multi_items_tab.dart     # Tab 2: evaluate several amounts at once
│   ├── history_tab.dart         # Tab 3: BCV history table (lazy loading)
│   └── splash_screen.dart       # Splash screen
└── widgets/
    ├── appBar.dart              # Custom AppBar widget
    ├── calculator.dart          # Currency calculator/converter
    ├── exchange_rate_container.dart  # Rate display cards
    ├── operations_modal.dart    # % / add / subtract bottom sheet modal
    ├── invert_coin_button.dart  # Swap origin/destination button
    └── bcv_dialog.dart          # BCV disclaimer dialog
```

## Commands

### Run the app
```bash
flutter run --flavor dev          # Entorno de desarrollo (backend local 10.0.2.2:9000)
flutter run --flavor prod         # Entorno de produccion (velocambio-back.onrender.com)
```

> Con flavors definidos, Flutter exige `--flavor`. Sin `--flavor`, falla.

### Run on specific platform
```bash
flutter run -d windows --flavor dev
flutter run -d chrome --flavor dev
flutter run -d android --flavor dev
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
flutter build apk --flavor prod          # Android
flutter build appbundle --flavor prod    # Android (Play Store)
flutter build ios --flavor prod          # iOS
flutter build web --flavor prod          # Web
flutter build windows --flavor prod      # Windows
```

### Generate app icons
```bash
dart run flutter_launcher_icons
```

## Environments (flavors)

- Flavor `dev`: backend local `http://10.0.2.2:9000/`, app id `com.velocambio.app.dev`, name "VeloCambio Dev".
- Flavor `prod`: backend `https://velocambio-back.onrender.com/`, app id `com.velocambio.app`, name "VeloCambio".
- Env files: `assets/env/.env.dev` and `assets/env/.env.prod` (gitignored). Templates `assets/env/*.example` are tracked.
- To build an APK, the real `.env.dev`/`.env.prod` must exist: `cp assets/env/.env.dev.example assets/env/.env.dev` and same for prod.
- `lib/core/config/app_config.dart` selects the env via `String.fromEnvironment('FLUTTER_APP_FLAVOR')` (default `dev`) and loads `assets/env/.env.$appEnvironment` with `flutter_dotenv` (`isOptional: true`).
- `lib/main.dart` assigns `dio.options.baseUrl` and `binanceDio.options.baseUrl` from `AppConfig.baseUrl` at startup. Dio clients are created with `baseUrl: ''`.
- The home-screen widget worker reads `bcv_base_url` (SharedPreferences), filled from `dio.options.baseUrl`.

## Code Conventions

- **File naming:** snake_case (e.g., `exchange_rate_provider.dart`)
- **Class naming:** PascalCase (e.g., `UsdExchangeRateProvider`)
- **Barrel exports:** Each directory uses `index.dart` for re-exports
- **Provider pattern:** Extend `ChangeNotifier` or `CmmGeneralProvider` for state
- **Hive models:** Place model in `models/`, adapter in `models/adapters/`, run `build_runner` after changes
- **API calls:** Use the corresponding Dio instance (`dio` from `core/http/dio_client.dart` for dolarapi, `binanceDio` from `core/http/binance_dio.dart` for Binance P2P) -- do not create raw Dio instances
- **Error handling:** Use the `CustomInterceptors` toast pattern for user-facing errors
- **Theme:** Dark theme is default; theme data lives in `core/themes/`

## Architecture Rules

1. **Providers** manage state and business logic. Never do API calls directly in widgets.
2. **Datasources** handle raw API communication. They extend `CmmGeneralProvider` for loading/error state.
3. **Models** are plain Dart classes with Hive `@HiveType` annotations. Non-persisted DTOs (e.g. `bcv_history_model.dart`, `multi_item_model.dart`) don't use Hive.
4. **Single screen + tabs:** `MainScreen` is a shell (`Scaffold` + `NavigationBar` + `IndexedStack`). New views must be added as a new tab widget (e.g. `home_tab.dart`, `multi_items_tab.dart`, `history_tab.dart`) registered in the `IndexedStack` — do NOT use `Navigator.push` for main tabs. Use bottom sheets (`showModalBottomSheet`) for transient tools (e.g. `OperationsModal`, custom rate form).
5. **No secrets in code.** Environment-specific values go in `.env` files (gitignored).
6. **Clean Arquithecture.**

## Utilities / Tabs overview

- **Operaciones (modal):** opened from the Calculator header (`%` icon). Calculates percentages, gets the `%` of an amount (`X% de`), or adds/subtracts a fixed value on top of the current conversion result. Pure logic lives in `core/utils/operations.dart`.
- **Multi-items (tab 2):** evaluates several amounts at once. Each item uses the global selected rate by default (editable per item; the `sync` icon restores the global rate). State lives only in memory (`MultiItemsProvider`), not persisted. Result is always VES.
- **Histórico (tab 3):** BCV official rate history table. Fetches `GET /rates/historico/bcv?page=X&page_size=50` via `BcvHistoryApi` with lazy pagination in `BcvHistoryProvider` (`fetchHistory` = page 1, `loadMore` = next page). The API already returns each page **descending** (most-recent-first, `page=1` = newest), so no reversal is applied. `page_size` is fixed to 50.

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
- **Application ID** is `com.velocambio.app`
- **iOS display name** shows "Payment Calculator" instead of "VeloCambio" in `Info.plist`.
