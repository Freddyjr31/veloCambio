# VeloCambio

App de calculadora de cambio de monedas para Venezuela, desarrollada en Flutter. Consulta tasas de cambio en tiempo real para USD (tasa oficial BCV + tasa de mercado), EUR y USDT (P2P Binance) a traves de un backend propio de cacheo, y convierte entre monedas o usa una tasa personalizada.

## Caracteristicas

- **Tasas de cambio en tiempo real** obtenidas a traves de un backend FastAPI propio que cachea las tasas
- **Dolar oficial (BCV)** y **dolar paralelo/mercado** con diferencia porcentual
- **Euro** con tasa oficial
- **USDT P2P** -- precio en bolivares desde la API publica de [Binance P2P](https://p2p.binance.com/)
- **Calculadora de conversion** entre USD, USDT, VES (Bolivar), EUR y una tasa personalizada
- **Tasa personalizada** -- el usuario puede definir y guardar su propia tasa de cambio
- **Anuncios con Google AdMob** (banners)
- **Intercambio de monedas** -- alterna la direccion de conversion con un boton
- **Copia al portapapeles** -- copia el resultado de la conversion
- **Estado de carga** con skeleton UI mientras se obtienen las tasas
- **Monitoreo de conectividad** de red
- **Persistencia local** con Hive para historial de conversiones
- **Tema oscuro** por defecto
- **Disclaimer BCV** -- modal informativo sobre las tasas oficiales al iniciar la app
- **Widget de home screen** -- widget nativo de Android que muestra la tasa oficial BCV, con actualizacion automatica cada 30 minutos (WorkManager)

## Capturas de pantalla

<!-- Agrega capturas de pantalla aqui -->
<!-- ![Pantalla principal](screenshots/main.png) -->

## Stack tecnologico

| Componente | Tecnologia |
|---|---|
| Framework | Flutter (SDK ^3.8.1) |
| State Management | Provider |
| HTTP Client | Dio con interceptores personalizados |
| Local Storage | Hive (NoSQL) + SharedPreferences |
| UI | Material Design, Skeletonizer |
| Code Generation | build_runner + hive_generator |
| Ads | Google AdMob (google_mobile_ads) |
| Home widget | home_widget (Android nativo) + WorkManager |
| Backend | FastAPI (cacheo de tasas) |
| API | Backend propio + [dolarapi.com](https://ve.dolarapi.com/) + [Binance P2P](https://p2p.binance.com/) |

## Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ^3.8.1
- [Dart SDK](https://dart.dev/get-dart) (incluido con Flutter)
- IDE recomendado: VS Code con extension Flutter, o Android Studio
- Conexion a internet para obtener tasas de cambio

## Instalacion

```bash
# Clonar el repositorio
git clone https://github.com/Freddyjr31/veloCambio
cd velocambio

# Instalar dependencias
flutter pub get

# Generar adaptadores de Hive (si es necesario)
dart run build_runner build --delete-conflicting-outputs

# Ejecutar la app
flutter run
```

## Ejecutar en plataformas especificas

```bash
flutter run -d windows    # Windows
flutter run -d chrome     # Web
flutter run -d android    # Android
flutter run -d ios        # iOS
```

## Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada, registro de Providers
├── app.dart                     # Configuracion de MaterialApp
├── core/
│   ├── http/
│   │   ├── dio_client.dart      # Cliente Dio para el backend (tasas)
│   │   ├── binance_dio.dart     # Cliente Dio para el backend (USDT P2P)
│   │   └── interceptor/         # Interceptores personalizados (errores agrupados)
│   ├── themes/                  # Tema y estilos
│   └── services/                # Servicio de preferencias + HomeWidgetService (widget BCV)
├── datasource/
│   ├── usd_api.dart             # Llamadas API para tasas USD (oficial + promedio)
│   ├── euro_api.dart            # Llamadas API para tasa EUR
│   ├── binance_api.dart         # Llamadas API para USDT P2P
│   └── services/
│       └── database_hive_services.dart  # Operaciones de lectura/escritura Hive
├── models/
│   ├── usd_model.dart           # Modelos de tasas USD (BCV + Mercado)
│   ├── euro_model.dart          # Modelo de tasa EUR
│   ├── binance_usdt_model.dart  # Modelo de tasa USDT P2P (Binance)
│   ├── rate_api_model.dart      # Modelo de respuesta del backend (tasa + fecha)
│   ├── custom_model.dart        # Modelo de tasa personalizada
│   ├── currency_model.dart      # Enum de monedas (USD, EUR, VES, etc.)
│   ├── currency_history_model.dart  # Modelo de historial
│   ├── exchange_types_model.dart    # Enum de tipos de tasa (oficial, mercado, P2P, etc.)
│   └── adapters/                # TypeAdapters de Hive
├── providers/
│   ├── app_providers.dart       # Configuracion MultiProvider
│   ├── cmm_general_provider.dart # Provider base (estado de carga/error)
│   ├── coin_provider.dart       # Logica de conversion de monedas
│   ├── exchange_rate_provider.dart # Estado de tasas USD
│   ├── euro_provider.dart       # Estado de tasa EUR
│   ├── binance_provider.dart    # Estado de tasa USDT P2P
│   ├── custom_provider.dart     # Estado de tasa personalizada
│   └── conectivity_status_provider.dart  # Conectividad de red
├── screens/
│   └── main_screen.dart         # Pantalla principal (toda la UI)
└── widgets/
    ├── app_bar.dart             # Widget de AppBar personalizado
    ├── calculator.dart          # Calculadora/conversor de monedas
    ├── exchange_rate_container.dart  # Tarjetas de visualizacion de tasas
    ├── invert_coin_button.dart  # Boton para intercambiar monedas origen/destino
    ├── bottom_baner_ad.dart     # Banner de anuncios (AdMob)
    └── bcv_dialog.dart          # Dialogo de disclaimer BCV
```

## Arquitectura

La app sigue un patron **Provider + Datasource**:

```
Widget -> Provider -> Datasource -> Backend FastAPI (cache de tasas)
                ↘ Hive (persistencia local)
```

- **Providers** gestionan el estado y la logica de negocio usando `ChangeNotifier`
- **Datasources** manejan la comunicacion HTTP con la API
- **Models** son clases Dart con anotaciones `@HiveType` para persistencia
- **Widgets** son componentes de UI que consumen providers

## API

La app consume un backend propio (FastAPI) que cachea las tasas de [dolarapi.com](https://ve.dolarapi.com/) y [Binance P2P](https://p2p.binance.com/). No requiere API key.

### Backend (endpoints)

| Endpoint | Descripcion |
|---|---|
| `GET rates/usd_oficial` | Tasa USD oficial (BCV) |
| `GET rates/usd_promedio` | Tasa USD promedio/mercado |
| `GET rates/eur` | Tasa EUR |
| `GET rates/usdt` | Tasa USDT P2P (Binance) |

Todos los endpoints devuelven el mismo formato JSON plano:

```json
{
  "price": 852.987482,
  "source_type_code": "dolar_api",
  "currency_from_code": "USD",
  "currency_to_code": "VES",
  "rate_type_code": "oficial",
  "fetched_at": "2026-07-30T04:00:00Z"
}
```

> **Nota de desarrollo:** en el emulador Android el backend se configura en `http://10.0.2.2:9000/` (`10.0.2.2` es el loopback del host). En un dispositivo fisico o para produccion debe apuntarse a la URL publica del backend.

## Widget de home screen (Tasa BCV)

La app incluye un **widget nativo de Android** que muestra la tasa oficial BCV (bolivar) directamente en el home screen. Es **solo Android**; en iOS no esta implementado.

### Como se agrega el widget

1. Mantener presionado un espacio vacio del home screen.
2. Tocar **Widgets** y buscar **VeloCambio** -> **Tasa BCV**.
3. Arrastrarlo a la pantalla y ajustar su tamano (minimo 3x1).

El widget muestra:
- **BCV OFICIAL** -- etiqueta del widget
- **Tasa** -- ultimo precio oficial del BCV (ej: `1.234,567 VES`), o `--` si aun no hay datos
- **Actualizado: dd/MM HH:mm** -- hora local de la ultima actualizacion
- Al tocar el widget se abre la app

### Arquitectura

```
Flutter (HomeWidgetService)
    │  HomeWidget.saveWidgetData()  →  SharedPreferences "HomeWidgetPreferences"
    │  HomeWidget.updateWidget()
    ▼
Kotlin (BcvRateWidget / RateSyncWorker)
    │  leen "HomeWidgetPreferences" y construyen RemoteViews
    ▼
Home screen (AppWidgetProvider)
```

- `lib/core/services/home_widget_service.dart` -- `HomeWidgetService.syncBcvRateToWidget()` guarda la tasa en las preferencias y dispara la actualizacion del widget. Se invoca desde `ExchangeRateProvider.getUsdExchangeRate()` cuando el backend responde con un precio valido (`price > 0`).
- `android/app/src/main/kotlin/com/velocambio/app/BcvRateWidget.kt` -- `HomeWidgetProvider` que construye las `RemoteViews` del widget al agregarse o actualizarse.
- `android/app/src/main/kotlin/com/velocambio/app/RateSyncWorker.kt` -- `CoroutineWorker` de WorkManager que consulta `GET rates/usd_oficial`, guarda el resultado en las preferencias y actualiza el widget. Reintenta ante fallos.
- `android/app/src/main/kotlin/com/velocambio/app/MainActivity.kt` -- agenda un trabajo periodico unico de 30 minutos (`bcv_rate_widget_sync`) con `ExistingPeriodicWorkPolicy.UPDATE`.
- Recursos de UI del widget en `android/app/src/main/res/`: `layout/bcv_rate_widget.xml`, `drawable/widget_bg.xml` (fondo `#0C0B20`), `xml/bcv_rate_widget_info.xml` (actualizacion cada `updatePeriodMillis=1800000`).

### Claves compartidas (SharedPreferences `HomeWidgetPreferences`)

| Clave | Tipo | Descripcion |
|---|---|---|
| `bcv_rate` | String | Tasa con 3 decimales (`price.toStringAsFixed(3)`) |
| `bcv_date` | String | `Actualizado: HH:mm` |
| `bcv_base_url` | String | Base URL del backend para que el worker consulte la tasa |

> Requiere el plugin [`home_widget`](https://pub.dev/packages/home_widget) (codigo nativo Kotlin). El worker consulta el backend usando la URL guardada en `bcv_base_url` (en emulador `http://10.0.2.2:9000/`); si no hay datos disponibles el widget muestra `--`.

## Construir para produccion

```bash
# Android (APK)
flutter build apk

# Android (App Bundle - Play Store)
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web

# Windows
flutter build windows
```

## Contribuir

1. Haz un fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Haz commit de tus cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

### Convenciones de codigo

- Archivos en **snake_case** (ej: `exchange_rate_provider.dart`)
- Clases en **PascalCase** (ej: `UsdExchangeRateProvider`)
- Usar barrel exports via `index.dart` en cada directorio
- Ejecutar `dart format lib/` antes de commitear
- Ejecutar `flutter analyze` para verificar linting

## Licencia

Este proyecto es privado. Todos los derechos reservados.

## Contacto

- Autor: [Freddy Bernal]
- GitHub: [Freddyjr31](https://github.com/Freddyjr31)
