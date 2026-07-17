import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:velocambio/core/services/app_preferences_services.dart';
import 'package:velocambio/models/adapters/currency_history_adapters.dart'
    as adapters;
import 'package:velocambio/models/adapters/custom_model_adapter.dart';
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
  double percentageDifferenceMarket = 0.0;
  double percentageDifferenceOficial = 0.0;

  //* Función para verificar si es la primera vez que el usuario abre la aplicación, para mostrar un mensaje de bienvenida y configurar la base de datos.
  Future<bool> checkFirstTime() async {
    bool firstTime = await AppPreferences.isFirstTime();
    if (firstTime) {
      log("¡Bienvenido por primera vez! Configurando base de datos...");
    } else {
      log("Bienvenido de nuevo.");
    }

    return firstTime;
  }

  //* para guardar la version
  late Future<PackageInfo> _packageInfoFuture;

  Future<void> getExchangeRate(CoinProvider coinProvider, UsdExchangeRateProvider exchangeProvider, EuroProvider euroProvider, BinanceProvider binanceProvider) async {

    //* Provider de tasas de cambio USD
    await exchangeProvider.getUsdExchangeRate();
    await euroProvider.getEurosExchangeRate();
    await binanceProvider.getBinanceP2pRate();

    log('Oficial: ${exchangeProvider.oficialRate}', name: 'MainScreen');
    log('Average: ${exchangeProvider.averageRate}', name: 'MainScreen');
    log('Euro: ${euroProvider.oficialEuroRate}', name: 'MainScreen');
    log('P2P USDT: ${binanceProvider.p2pPrice}', name: 'MainScreen');

    double amout = exchangeProvider.oficialRate;
    coinProvider.setAmount(amout);

    //* moneda seleccionada por defecto
    coinProvider.changeExchangeType(ExchangeType.oficialUsd);
    // coinProvider.calculatedAmount(coinProvider.destinationCurrency);
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

    _packageInfoFuture = PackageInfo.fromPlatform();

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
      // List<adapters.CurrencyHistoryModel> history = await exchangeProvider.getUsdExchangeRateHistory();
 
      //* moneda seleccionada por defecto
      // coinProvider.changeExchangeType(ExchangeType.oficialUsd);
      // coinProvider.calculatedAmount(coinProvider.destinationCurrency);

      // //* Provider de tasas de cambio USD
      // await exchangeProvider.getUsdExchangeRate();
      // await euroProvider.getEurosExchangeRate();

      // log('Oficial: ${exchangeProvider.oficialRate}', name: 'MainScreen');
      // log('Average: ${exchangeProvider.averageRate}', name: 'MainScreen');
      // log('Euro: ${euroProvider.oficialEuroRate}', name: 'MainScreen');

      // double amout = exchangeProvider.oficialRate;
      // coinProvider.setAmount(amout);

       await getExchangeRate(coinProvider, exchangeProvider, euroProvider, binanceProvider);

       //* Provider de historial de Tasas de cambio (HIVE)

      // if (firstTime) {
      
      //   log(history.toString(), name: 'MainScreen - HISTORY');
      //   * insertar cada dato en la base de datos
      //   for (var item in history) {
      //     await coinProvider.insertCurrencyHistory(item);
      //   }

      // } else {

      //   * Provider de tasas de cambio USD
      //   await exchangeProvider.getUsdExchangeRate();
      //   await euroProvider.getEurosExchangeRate();

      //   log('Oficial: ${exchangeProvider.oficialRate}', name: 'MainScreen');
      //   log('Average: ${exchangeProvider.averageRate}', name: 'MainScreen');
      //   log('Euro: ${euroProvider.oficialEuroRate}', name: 'MainScreen');

      //   double amout = exchangeProvider.oficialRate;
      //   exchangeProvider.setAmount(amout);

      //   bool setCurrencyHistoryData = false;

      //   //* Provider de historial de Tasas de cambio (HIVE)
      //   final historyHive = coinProvider.getCurrencyHiveHistory();

      //   historyHive.then((value) async {

      //     if (value.isEmpty) {

      //       log('No hay historial de tasas de cambio',name: 'CoinProvider - MainScreen',);
            
      //       setCurrencyHistoryData = await setHiveCurrencyHistory(
      //         adapters.CurrencyHistoryModel(
      //           createdAt: DateTime.now(),
      //           previusValue: exchangeProvider.oficialRate,
      //           value: exchangeProvider.oficialRate,
      //           incrementValue: false,
      //           percentageDifference: 0,
      //           marketUsdPreviusValue: exchangeProvider.averageRate,
      //           marketUsdValue: exchangeProvider.averageRate,
      //           marketUsdIncrementValue: false,
      //           marketUsdPercentageDifference: 0,
      //           euroPreviusValue: exchangeProvider.amount,
      //           euroValue: exchangeProvider.amount,
      //           euroIncrementValue: false,
      //           euroPercentageDifference: 0,
      //           averageRateUpdateDate: exchangeProvider.averageRateUpdateDate,
      //           oficialRateUpdateDate: exchangeProvider.oficialRateUpdateDate,
      //         ),
      //         //* provider
      //         coinProvider,
      //       );

      //       if (setCurrencyHistoryData == false) {
      //         log('Error al insertar', name: 'CoinProvider - MainScreen');
      //         return;
      //       }

      //       log('Insertado correctamente', name: 'CoinProvider - MainScreen');

      //       return;

      //     } else {

      //       var data = value.first;
      //       //* debugPrint del ultimo dato de la BD
      //       data.toJson().forEach((key, value) => debugPrint('$key: $value'));

      //       //* Obtengo las fechas de actualizacion de cada tasa de la BD 
      //       var historyDateAvergageRate = DateTime.tryParse(data.averageRateUpdateDate.toString());
      //       var historyDateOficialRate = DateTime.tryParse(data.oficialRateUpdateDate.toString());

      //       if (historyDateAvergageRate != null && historyDateOficialRate != null) {

      //         //* Si la fecha de la BD es menor a la de la API, es que cambio el valor de la tasa de cambio de la API
      //         if (historyDateAvergageRate.isBefore(exchangeProvider.oficialRateUpdateDate) ||
      //             historyDateOficialRate.isBefore(exchangeProvider.averageRateUpdateDate)) {

      //           //* Ordenamos el historial de la fecha más nueva a la más antigua (Descendente)
      //           // Esto nos garantiza que el primer registro que coincida será el más cercano a hoy.
      //           final sortedHistory = List<adapters.CurrencyHistoryModel>.from(history);
      //           sortedHistory.sort((a, b) => b.averageRateUpdateDate!.compareTo(a.oficialRateUpdateDate!));
                
      //           List<adapters.CurrencyHistoryModel> lastDatebeforeToday = [];
                
      //           //* Recorremos el historial de la BD, para buscar el valor más cercano a la fecha de hoy, pero que sea menor a la fecha de hoy.
      //           for (var element in sortedHistory) {

      //             if (element.averageRateUpdateDate!.isBefore(exchangeProvider.averageRateUpdateDate) && element.oficialRateUpdateDate!.isBefore(exchangeProvider.oficialRateUpdateDate)) {
                    
      //               debugPrint('fecha BD: ${element.averageRateUpdateDate} - fecha API: ${exchangeProvider.averageRateUpdateDate}');
      //               debugPrint('fecha BD: ${element.oficialRateUpdateDate} - fecha API: ${exchangeProvider.oficialRateUpdateDate}');
      //               debugPrint('valor BD: ${element.marketUsdValue} - valor API: ${exchangeProvider.averageRate}');
      //               debugPrint('valor BD: ${element.value} - valor API: ${exchangeProvider.oficialRate}');

      //               //* Guardamos el valor encontrado en una lista, para luego comparar con la tasa de cambio actual de la API y calcular el porcentaje de diferencia.
      //               lastDatebeforeToday.add(element);
      //               break;
      //             }
      //           }

      //           log('La fecha de la BD es menor a la de la API',name: 'CoinProvider - MainScreen');
      //           log('La tasa de cambio ha cambiado',name: 'CoinProvider - MainScreen');

      //           bool upValueMarket = false;
      //           bool upValueOficial = false;

      //           //* calculo si subio o bajo la tasa de cambio USD
      //           if (exchangeProvider.averageRate > /*value.first.marketUsdValue!*/ lastDatebeforeToday[0].marketUsdValue!) {
      //             log('La tasa de cambio promedio ha subido', name: 'CoinProvider - MainScreen');
      //             upValueMarket = true;
      //             exchangeProvider.setAverageRateUpValue(true);
      //           } else {
      //             log('La tasa de cambio promedio ha bajado',name: 'CoinProvider - MainScreen');
      //             upValueMarket = false;
      //             exchangeProvider.setAverageRateUpValue(false);
      //           }

      //           if (exchangeProvider.oficialRate > /*value.first.value!*/ lastDatebeforeToday[0].value!) {
      //             log('La tasa de cambio oficial ha subido', name: 'CoinProvider - MainScreen');
      //             upValueOficial = true;
      //             exchangeProvider.setOficialRateUpValue(true);
      //           } else {
      //             log('La tasa de cambio oficial ha bajado', name: 'CoinProvider - MainScreen');
      //             upValueOficial = false;
      //             exchangeProvider.setOficialRateUpValue(false);
      //           }

      //           setState(() {
      //             percentageDifferenceMarket = ((exchangeProvider.averageRate - lastDatebeforeToday[0].marketUsdValue!) / lastDatebeforeToday[0].marketUsdValue!) * 100;
      //             percentageDifferenceOficial = ((exchangeProvider.oficialRate - lastDatebeforeToday[0].value!) / lastDatebeforeToday[0].value!) * 100;
      //           });

      //           exchangeProvider.setAverageRatePercentage(percentageDifferenceMarket,);
      //           exchangeProvider.setOficialRatePercentage(percentageDifferenceOficial,);

      //           log('Porcentaje de diferencia market: $percentageDifferenceMarket', name: 'PORCENTAJE - CoinProvider - MainScreen');
      //           log('Porcentaje de diferencia oficial: $percentageDifferenceOficial', name: 'PORCENTAJE - CoinProvider - MainScreen');

      //           setCurrencyHistoryData = await setHiveCurrencyHistory(
      //             adapters.CurrencyHistoryModel(
      //               createdAt: DateTime.now(),
      //               previusValue: data.value,
      //               value: exchangeProvider.oficialRate,
      //               incrementValue: upValueOficial,
      //               percentageDifference: percentageDifferenceOficial,
      //               marketUsdPreviusValue: exchangeProvider.amount,
      //               marketUsdValue: exchangeProvider.averageRate,
      //               marketUsdIncrementValue: upValueMarket,
      //               marketUsdPercentageDifference: percentageDifferenceMarket,
      //               euroPreviusValue: exchangeProvider.amount,
      //               euroValue: exchangeProvider.amount,
      //               euroIncrementValue: false,
      //               euroPercentageDifference: 0,
      //               averageRateUpdateDate: exchangeProvider.averageRateUpdateDate,
      //               oficialRateUpdateDate: exchangeProvider.oficialRateUpdateDate,
      //             ),
      //             //* provider
      //             coinProvider,
      //           );

      //           if (setCurrencyHistoryData == false) {
      //             log('Error al insertar', name: 'CoinProvider - MainScreen');
      //             return;
      //           }

      //           log('Insertado correctamente', name: 'CoinProvider - MainScreen');
      //           return;
      //         }
      //       }
      //     }
      //   });
      // }

    });
  }

  //* SUPABASE
  // Future<bool> setCurrencyHistory(CurrencyHistoryModel data) async {
  //   final coinProvider = context.read<CoinProvider>();
  //   return coinProvider.insertPayment(data);
  // }

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

  bool selectOficialRate = true;
  bool selectAverageRate = false;
  bool selectEuroOficialRate = false;
  bool selectP2pRate = false;

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

    if(coinProvider.exchangeType == ExchangeType.oficialUsd) {
      selectOficialRate = true;
      selectAverageRate = false;
      selectEuroOficialRate = false;
      selectP2pRate = false;
    }

    //* amount a mostrar en la calculadora, dependiendo de la tasa de cambio seleccionada
    double amount = coinProvider.amount;
    log('Amount en MainScreen: $amount', name: 'MainScreen - build');

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<PackageInfo>(
          future: _packageInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('VeloCambio');
            } else if (snapshot.hasError) {
              return Text('VeloCambio');
            } else {
              final version = snapshot.data?.version ?? '1.0.0';
              final buildNumber = snapshot.data?.buildNumber ?? '000';
              return  Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/app_icon-removebg_small.PNG',
                    width: size.width * 0.5,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'v$version+$buildNumber',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ),
                ],
              );
            }
          },
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              
              SizedBox(height: 5),
          
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  spacing: 10,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Tasas disponibles',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                      //* fecha de hoy
                      DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                    onTap: () {
                      coinProvider.changeExchangeType(ExchangeType.oficialUsd);

                      if(coinProvider.inputCurrencyCoin != Currency.ves.code) {
                        coinProvider.setInputCurrencyCoin(Currency.usd.code);
                      } else {
                        coinProvider.setOutputCurrencyCoin(Currency.usd.code);
                      }

                      setState(() {
                        selectOficialRate = true;
                        selectAverageRate = false;
                        selectEuroOficialRate = false;
                      });

                      double amout = exchangeProvider.oficialRate;
                      log('Selected Oficial Rate: $amout', name: 'MainScreen - onTap Oficial Rate');
                      coinProvider.setAmount(amout);
                      // coinProvider.calculatedAmount(coinProvider.destinationCurrency);
                      coinProvider.calculatedAmount(
                          rateUsdBcv: exchangeProvider.oficialRate,
                          rateUsdMarket: exchangeProvider.averageRate,
                          rateEUR: euroProvider.oficialEuroRate,
                          rateP2P: binanceProvider.p2pPrice,
                        );
                      },
                    child: ExchangeRateContainer(
                      imagePath: Currency.usd.flagPath,
                      type: ExchangeType.oficialUsd,
                      size: size.width * 0.9,
                      value: exchangeProvider.oficialRate,
                      nameType: 'BCV Oficial',
                      upValue: exchangeProvider.oficialRateUpValue,
                      isSelected: selectOficialRate,
                      icon: const Icon(Icons.account_balance),
                      percentageDifference: exchangeProvider.oficialRatePercentage,
                    ),
                ),
          
                  GestureDetector(
                    onTap: () {

                      coinProvider.changeExchangeType(ExchangeType.averageUsd);

                      if(coinProvider.inputCurrencyCoin != Currency.ves.code) {
                        coinProvider.setInputCurrencyCoin(Currency.usd.code);
                      } else {
                        coinProvider.setOutputCurrencyCoin(Currency.usd.code);
                      }

                      setState(() {
                        selectAverageRate = true;
                        selectOficialRate = false;
                        selectEuroOficialRate = false;
                      });

                      double amout = exchangeProvider.averageRate;
                      log('Selected Average Rate: $amout', name: 'MainScreen - onTap Average Rate');
                      coinProvider.setAmount(amout);
                      // coinProvider.calculatedAmount(coinProvider.destinationCurrency);

                      coinProvider.calculatedAmount(
                          rateUsdBcv: exchangeProvider.oficialRate,
                          rateUsdMarket: exchangeProvider.averageRate,
                          rateEUR: euroProvider.oficialEuroRate,
                          rateP2P: binanceProvider.p2pPrice,
                        );
                      },

                    child: ExchangeRateContainer(
                      imagePath: Currency.usd.flagPath,
                      type: ExchangeType.averageUsd,
                      size: size.width * 0.9,
                      value: exchangeProvider.averageRate,
                      nameType: 'Promedio',
                      upValue: exchangeProvider.averageRateUpValue,
                      isSelected: selectAverageRate,
                      icon: const Icon(Icons.currency_exchange),
                      percentageDifference: exchangeProvider.averageRatePercentage,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {

                      coinProvider.changeExchangeType(ExchangeType.oficialEur);

                      if(coinProvider.inputCurrencyCoin != Currency.ves.code) {
                        coinProvider.setInputCurrencyCoin(Currency.eur.code);
                      } else {
                        coinProvider.setOutputCurrencyCoin(Currency.eur.code);
                      }

                      setState(() {
                        selectAverageRate = false;
                        selectOficialRate = false;
                        selectEuroOficialRate = true;
                        selectP2pRate = false;
                      });

                      double amout = euroProvider.oficialEuroRate;
                      log('Selected Euro Rate: $amout', name: 'MainScreen - onTap Euro Rate');
                      coinProvider.setAmount(amout);
                      coinProvider.calculatedAmount(
                        rateUsdBcv: exchangeProvider.oficialRate,
                        rateUsdMarket: exchangeProvider.averageRate,
                        rateEUR: euroProvider.oficialEuroRate,
                        rateP2P: binanceProvider.p2pPrice,
                      );
                    },
                    child: ExchangeRateContainer(
                      imagePath: Currency.eur.flagPath,
                      // size: size.width * 0.42,
                      type: ExchangeType.oficialEur,
                      size: size.width * 0.9,
                      value: euroProvider.oficialEuroRate,
                      nameType: 'Euro',
                      upValue: true,
                      isSelected: selectEuroOficialRate,
                      icon: const Icon(Icons.account_balance),
                      percentageDifference: 0,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {

                      coinProvider.changeExchangeType(ExchangeType.p2pUsdt);

                      if(coinProvider.inputCurrencyCoin != Currency.ves.code) {
                        coinProvider.setInputCurrencyCoin(Currency.usdt.code);
                      } else {
                        coinProvider.setOutputCurrencyCoin(Currency.usdt.code);
                      }

                      setState(() {
                        selectAverageRate = false;
                        selectOficialRate = false;
                        selectEuroOficialRate = false;
                        selectP2pRate = true;
                      });

                      double amout = binanceProvider.p2pPrice;
                      log('Selected P2P USDT Rate: $amout', name: 'MainScreen - onTap P2P Rate');
                      coinProvider.setAmount(amout);
                      coinProvider.calculatedAmount(
                        rateUsdBcv: exchangeProvider.oficialRate,
                        rateUsdMarket: exchangeProvider.averageRate,
                        rateEUR: euroProvider.oficialEuroRate,
                        rateP2P: binanceProvider.p2pPrice,
                      );
                    },
                    child: ExchangeRateContainer(
                      imagePath: Currency.usd.flagPath,
                      type: ExchangeType.p2pUsdt,
                      size: size.width * 0.9,
                      value: binanceProvider.p2pPrice,
                      nameType: 'USDT P2P',
                      upValue: true,
                      isSelected: selectP2pRate,
                      icon: const Icon(Icons.currency_bitcoin),
                      percentageDifference: 0,
                    ),
                  ),
                ],
              ),

              if(customProvider.selectedCustomModel != null)...[
                GestureDetector(
                  onTap: () {
                    coinProvider.changeExchangeType(ExchangeType.custom);

                    if(coinProvider.inputCurrencyCoin != Currency.ves.code) {
                      coinProvider.setInputCurrencyCoin(Currency.custom.code);
                    } else {
                      coinProvider.setOutputCurrencyCoin(Currency.custom.code);
                    }

                    setState(() {
                      selectAverageRate = false;
                      selectOficialRate = false;
                      selectEuroOficialRate = false;
                    });

                    double amout = customProvider.selectedCustomModel!.value;
                    log('Selected Custom Rate: $amout', name: 'MainScreen - onTap Custom Rate');
                    coinProvider.setAmount(amout);
                    coinProvider.calculatedAmount(
                      rateUsdBcv: exchangeProvider.oficialRate,
                      rateUsdMarket: exchangeProvider.averageRate,
                      rateEUR: euroProvider.oficialEuroRate,
                      rateP2P: binanceProvider.p2pPrice,
                    );
                  },
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
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return Padding(
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
                                        ),
                                        child: const Text(
                                          'Guardar',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ),
                            
                                    SizedBox(height: 10,),
                                  ],
                                ),
                            ),
                          ),
                        );
                      }
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    maximumSize: Size(size.width * 0.9, 60),
                    minimumSize: Size(size.width * 0.9, 60),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    padding: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                    side: BorderSide(color: Colors.white10, width: 1),
                  ),
                  child: Text('+ Agregar tasa personalizada', style: TextStyle(color: Colors.white, fontSize: 16),),
                ),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.white10,
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