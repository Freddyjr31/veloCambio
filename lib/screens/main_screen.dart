import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/models/adapters/currency_history_adapters.dart'
    as adapters;
import 'package:velocambio/models/adapters/custom_model_adapter.dart';
import 'package:velocambio/models/currency_model.dart';
import 'package:velocambio/models/exchange_types_model.dart';
import 'package:velocambio/providers/custom_provider.dart';
import 'package:velocambio/providers/euro_provider.dart';
import 'package:velocambio/providers/index.dart';
import 'package:velocambio/widgets/bcv_dialog.dart';
import 'package:velocambio/widgets/index.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  //* Variables para calcular el porcentaje de diferencia entre la tasa de cambio actual y la tasa de cambio anterior guardada en la base de datos
  // double percentageDifferenceMarket = 0.0;
  // double percentageDifferenceOficial = 0.0;

  //* Función para verificar si es la primera vez que el usuario abre la aplicación, para mostrar un mensaje de bienvenida y configurar la base de datos.
  // Future<bool> checkFirstTime() async {
  //   bool firstTime = await AppPreferences.isFirstTime();
  //   if (firstTime) {
  //     log("¡Bienvenido por primera vez! Configurando base de datos...");
  //   } else {
  //     log("Bienvenido de nuevo.");
  //   }

  //   return firstTime;
  // }

  Future<void> getExchangeRate(CoinProvider coinProvider, UsdExchangeRateProvider exchangeProvider, EuroProvider euroProvider, BinanceProvider binanceProvider) async {

    //* Provider de tasas de cambio USD
    await exchangeProvider.getUsdExchangeRate();
    await euroProvider.getEurosExchangeRate();
    await binanceProvider.getBinanceP2pRate();

    log('Oficial: ${exchangeProvider.oficialRate}', name: 'MainScreen');
    log('Average: ${exchangeProvider.averageRate}', name: 'MainScreen');
    log('Euro: ${euroProvider.oficialEuroRate}', name: 'MainScreen');
    log('P2P USDT: ${binanceProvider.p2pPrice}', name: 'MainScreen');

    coinProvider.setAmount(exchangeProvider.oficialRate);

    //* moneda seleccionada por defecto
    coinProvider.changeExchangeType(ExchangeType.oficialUsd);
    
    coinProvider.calculatedAmount(
      rateUsdBcv: exchangeProvider.oficialRate,
      rateUsdMarket: exchangeProvider.averageRate,
      rateEUR: euroProvider.oficialEuroRate,
      rateP2P: binanceProvider.p2pPrice,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      //* Provider de tasas de cambio USD
      final exchangeProvider = context.read<UsdExchangeRateProvider>();

      //* Provider de tasas de cambio EUR
      final euroProvider = context.read<EuroProvider>();
      
      //* Provider de historial de Tasas de cambio (BD - SUPABASE)
      final coinProvider = context.read<CoinProvider>();

      //* Provider de Binance P2P
      final binanceProvider = context.read<BinanceProvider>();
      
      //* Dialog de aviso del BCV
      BcvDisclaimerModal.show(context);

      //* Provider de primera vez
      // bool firstTime = await checkFirstTime();

      log('Bienvenido!', name: 'MainScreen');

      await getExchangeRate(coinProvider, exchangeProvider, euroProvider, binanceProvider);

    });
  }


  //* HIVE
  Future<bool> setHiveCurrencyHistory(
    adapters.CurrencyHistoryModel data,
    CoinProvider provider
  ) async {

    final response = await provider.insertCurrencyHistory(data);

    if (response == false) {
      log('Error al insertar', name: 'HIVE - MainScreen');
      return false;
    }

    return response;
  }

  ExchangeType selectedType = ExchangeType.oficialUsd;

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final exchangeProvider = context.watch<UsdExchangeRateProvider>();
    final coinProvider = context.watch<CoinProvider>();
    final euroProvider = context.watch<EuroProvider>();
    final customProvider = context.watch<CustomProvider>();
    final binanceProvider = context.watch<BinanceProvider>();

    void selectedTypeRate(ExchangeType type, double rate, String currencyCode) {

      coinProvider.changeExchangeType(type);
    
      if (coinProvider.inputCurrencyCoin != Currency.ves.code) {
        coinProvider.setInputCurrencyCoin(currencyCode);
      } else {
        coinProvider.setOutputCurrencyCoin(currencyCode);
      }

      setState(() => selectedType = type);

      coinProvider.setAmount(rate);

      coinProvider.calculatedAmount(
        rateUsdBcv: exchangeProvider.oficialRate,
        rateUsdMarket: exchangeProvider.averageRate,
        rateEUR: euroProvider.oficialEuroRate,
        rateP2P: binanceProvider.p2pPrice,
      );
    }

    if(coinProvider.exchangeType == ExchangeType.oficialUsd) {
      //WidgetsBinding.instance.addPostFrameCallback((_) {
        // if (!mounted) return;
        setState(() => selectedType = ExchangeType.oficialUsd);
      //});
    }

    return Scaffold(
      appBar: MainAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              
              SizedBox(height: 5),
              //* Titulo, Boton de actualizar y fecha
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  spacing: 10,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Tasas disponibles',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                    
                        Tooltip(
                          message: 'Actualizar tasas',
                          child: IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            onPressed: () => getExchangeRate(coinProvider, exchangeProvider, euroProvider, binanceProvider),
                          ),
                        )
                      ],
                    ),
                
                    Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),


                  ],
                ),
              ),
          
              // Row(
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                spacing: 10,
                children: [

                  GestureDetector(
                    onTap: () => selectedTypeRate(ExchangeType.oficialUsd, exchangeProvider.oficialRate, Currency.usd.code),
                    child: ExchangeRateContainer(
                      imagePath: Currency.usd.flagPath,
                      type: ExchangeType.oficialUsd,
                      size: size.width * 0.9,
                      value: exchangeProvider.oficialRate,
                      nameType: 'BCV Oficial',
                      upValue: exchangeProvider.oficialRateUpValue,
                      isSelected: selectedType == ExchangeType.oficialUsd,
                      icon: const Icon(Icons.account_balance),
                      percentageDifference: exchangeProvider.oficialRatePercentage,
                    ),
                ),
          
                  GestureDetector(
                    onTap: () => selectedTypeRate(ExchangeType.averageUsd, exchangeProvider.averageRate, Currency.usd.code),
                    child: ExchangeRateContainer(
                      imagePath: Currency.usd.flagPath,
                      type: ExchangeType.averageUsd,
                      size: size.width * 0.9,
                      value: exchangeProvider.averageRate,
                      nameType: 'Promedio',
                      upValue: exchangeProvider.averageRateUpValue,
                      isSelected: selectedType == ExchangeType.averageUsd,
                      icon: const Icon(Icons.currency_exchange),
                      percentageDifference: exchangeProvider.averageRatePercentage,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => selectedTypeRate(ExchangeType.oficialEur, euroProvider.oficialEuroRate, Currency.eur.code),
                    child: ExchangeRateContainer(
                      imagePath: Currency.eur.flagPath,
                      type: ExchangeType.oficialEur,
                      size: size.width * 0.9,
                      value: euroProvider.oficialEuroRate,
                      nameType: 'Euro',
                      upValue: true,
                      // isSelected: selectEuroOficialRate,
                      isSelected: selectedType == ExchangeType.oficialEur,
                      icon: const Icon(Icons.account_balance),
                      percentageDifference: 0,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => selectedTypeRate(ExchangeType.p2pUsdt, binanceProvider.p2pPrice, Currency.usdt.code),
                    child: ExchangeRateContainer(
                      imagePath: Currency.usd.flagPath,
                      type: ExchangeType.p2pUsdt,
                      size: size.width * 0.9,
                      value: binanceProvider.p2pPrice,
                      nameType: 'USDT P2P',
                      upValue: true,
                      // isSelected: selectP2pRate,
                      isSelected: selectedType == ExchangeType.p2pUsdt,
                      icon: const Icon(Icons.currency_bitcoin),
                      percentageDifference: 0,
                    ),
                  ),
                ],
              ),

              if(customProvider.selectedCustomModel != null)...[
                GestureDetector(
                  onTap: () => selectedTypeRate(ExchangeType.custom, customProvider.selectedCustomModel!.value, Currency.custom.code),
                  child: ExchangeRateContainer(
                    imagePath: Currency.usd.flagPath,
                    type: ExchangeType.custom,
                    size: size.width * 0.9,
                    value: customProvider.selectedCustomModel!.value,
                    nameType: 'Personalizada',
                    upValue: true,
                    isSelected: coinProvider.exchangeType == ExchangeType.custom,
                    icon: const Icon(Icons.edit),
                    percentageDifference: 0,
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    //* show button sheet para agregar una tasa personalizada
                    showModalBottomSheet(
                      barrierColor: Colors.black.withValues(alpha: 0.6),
                      backgroundColor: Colors.transparent,
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Padding(
                              padding:EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                            
                                        Form(
                                          key: formKey,
                                          child: TextFormField(
                                            controller: customProvider.customAmountController,
                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.attach_money),
                                              labelText: 'Agregar tasa personalizada',
                                              border: OutlineInputBorder(),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Por favor ingrese una tasa de cambio';
                                              }
                                              if (double.tryParse(value) == null) {
                                                return 'Por favor ingrese un número válido';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                
                                        SizedBox(height: 10,),
                                
                                        SizedBox(
                                          width: double.infinity,
                                          child: TextButton(
                                            onPressed: () {
                                              if (formKey.currentState!.validate()) {
                                                // Handle form submission
                                                double customRate = double.parse(customProvider.customAmountController.text);
                                                log('Custom Rate ingresada: $customRate', name: 'MainScreen - Custom Rate');
                                                customProvider.setCustomModel(
                                                  CustomModel(
                                                    name: 'Tasa personalizada',
                                                    value: customRate,
                                                    fechaActualizacion: DateTime.now(), 
                                                    createdAt: DateTime.now(),
                                                  )
                                                );
                                            
                                                toastification.show(
                                                  context: context,
                                                  type: ToastificationType.success,
                                                  autoCloseDuration: Duration(seconds: 3),
                                                  style: ToastificationStyle.fillColored,
                                                  title: Text('Tasa personalizada agregada'),
                                                );
                                            
                                                Navigator.pop(context);
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                              minimumSize: Size(size.width * 0.9, 40),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              backgroundColor: Colors.grey[50]?.withAlpha(10),
                                              overlayColor: Theme.of(context).colorScheme.primary,
                                            ),
                                            child: Text(
                                              'Guardar',
                                              style: Theme.of(context).textTheme.labelLarge,
                                            ),
                                          )
                                        ),
                                
                                        SizedBox(height: 10,),
                                      ],
                                    ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    maximumSize: Size(size.width * 0.9, 57),
                    minimumSize: Size(size.width * 0.9, 57),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    padding: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                    side: BorderSide(color: primaryColor.withAlpha(20), width: 1),
                  ),
                  child: Text('+ Agregar tasa personalizada', style: Theme.of(context).textTheme.titleMedium),
                ),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  height: 0,
                  thickness: 0.5,
                  color: primaryColor.withAlpha(20),
                ),
              ),
                
              //* Calculadora
              Calculator(),
          
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}