# VeloCambio

App de calculadora de cambio de monedas para Venezuela, desarrollada en Flutter. Consulta tasas de cambio en tiempo real para USD (tasa oficial BCV + tasa de mercado) y EUR, y convierte entre monedas o usa una tasa personalizada.

## Caracteristicas

- **Tasas de cambio en tiempo real** desde [dolarapi.com](https://ve.dolarapi.com/)
- **Dolar oficial (BCV)** y **dolar paralelo/mercado** con diferencia porcentual
- **Euro** con tasa oficial
- **Calculadora de conversion** entre USD, VES (Bolivar), EUR y una tasa personalizada
- **Tasa personalizada** -- el usuario puede definir y guardar su propia tasa de cambio
- **Intercambio de monedas** -- alterna la direccion de conversion con un boton
- **Copia al portapapeles** -- copia el resultado de la conversion
- **Estado de carga** con skeleton UI mientras se obtienen las tasas
- **Monitoreo de conectividad** de red
- **Persistencia local** con Hive para historial de conversiones
- **Tema oscuro** por defecto
- **Disclaimer BCV** -- modal informativo sobre las tasas oficiales al iniciar la app

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
| API | [dolarapi.com](https://ve.dolarapi.com/) |

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
│   ├── http/                    # Cliente Dio e interceptores
│   ├── themes/                  # Tema y estilos
│   └── services/                # Servicio de preferencias (SharedPreferences)
├── datasource/
│   ├── usd_api.dart             # Llamadas API para tasas USD
│   ├── euro_api.dart            # Llamadas API para tasas EUR
│   └── services/
│       └── database_hive_services.dart  # Operaciones de lectura/escritura Hive
├── models/
│   ├── usd_model.dart           # Modelos de tasas USD (BCV + Mercado)
│   ├── euro_model.dart          # Modelo de tasa EUR
│   ├── custom_model.dart        # Modelo de tasa personalizada
│   ├── currency_history_model.dart  # Modelo de historial
│   └── adapters/                # TypeAdapters de Hive
├── providers/
│   ├── app_providers.dart       # Configuracion MultiProvider
│   ├── cmm_general_provider.dart # Provider base (estado de carga/error)
│   ├── coin_provider.dart       # Logica de conversion de monedas
│   ├── exchange_rate_provider.dart # Estado de tasas USD
│   ├── euro_provider.dart       # Estado de tasa EUR
│   ├── custom_provider.dart     # Estado de tasa personalizada
│   └── conectivity_status_provider.dart  # Conectividad de red
├── screens/
│   └── main_screen.dart         # Pantalla principal (toda la UI)
└── widgets/
    ├── appBar.dart              # Widget de AppBar personalizado
    ├── calculator.dart          # Calculadora/conversor de monedas
    ├── exchange_rate_container.dart  # Tarjetas de visualizacion de tasas
    └── bcv_dialog.dart          # Dialogo de disclaimer BCV
```

## Arquitectura

La app sigue un patron **Provider + Datasource**:

```
Widget -> Provider -> Datasource -> API (dolarapi.com)
                ↘ Hive (persistencia local)
```

- **Providers** gestionan el estado y la logica de negocio usando `ChangeNotifier`
- **Datasources** manejan la comunicacion HTTP con la API
- **Models** son clases Dart con anotaciones `@HiveType` para persistencia
- **Widgets** son componentes de UI que consumen providers

## API

La app consume la API publica de [dolarapi.com](https://ve.dolarapi.com/):

| Endpoint | Descripcion |
|---|---|
| `GET v1/dolares` | Tasas de cambio USD (BCV oficial + mercado) |
| `GET v1/euros` | Tasas de cambio EUR |

No se requiere API key para acceder a estos endpoints.

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
