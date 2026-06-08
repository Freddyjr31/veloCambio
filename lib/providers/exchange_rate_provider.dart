
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:velocambio/datasource/usd_api.dart';
import 'package:velocambio/models/usd_model.dart';
import 'package:velocambio/providers/cmm_general_provider.dart';

class UsdExchangeRateProvider extends CmmGeneralProvider{

  TextEditingController amountController = TextEditingController();

  //* para cambiar el monto, ESTE ES EL VALOR PRINCIPAL QUE SE USA PARA CALCULAR EL MONTO EN LA OTRA MONEDA
  // double amount = 0;
  // void setAmount(double val) {
  //   amount = val;
  //   notifyListeners();
  // }


  //* Para saber si subio o bajo el valor de la tasa oficial
  bool oficialRateUpValue = false;
  void setOficialRateUpValue(bool val) {
    oficialRateUpValue = val;
    notifyListeners();
  }
  //* Para saber si subio o bajo el valor de la tasa promedio
  bool averageRateUpValue = false;
  void setAverageRateUpValue(bool val) {
    averageRateUpValue = val;
    notifyListeners();
  }

  //* Tasas
  double oficialRate = 0;
  void setOficialRate(double val) {
    oficialRate = val;
    notifyListeners();
  }

  double averageRate = 0;
  void setAverageRate(double val) {
    averageRate = val;
    notifyListeners();
  }

  //* Fecha de actualización
  DateTime oficialRateUpdateDate = DateTime.now();
  void setOficialUpdateDate(DateTime val) {
    oficialRateUpdateDate = val;
    notifyListeners();
  }

  DateTime averageRateUpdateDate = DateTime.now();
  void setAverageUpdateDate2(DateTime val) {
    averageRateUpdateDate = val;
    notifyListeners();
  }

  //* Porcentajes
  double oficialRatePercentage = 0;
  void setOficialRatePercentage(double val) {
    oficialRatePercentage = val;
    notifyListeners();
  }

  double averageRatePercentage = 0;
  void setAverageRatePercentage(double val) {
    averageRatePercentage = val;
    notifyListeners();
  }

  // double currentAmount = 0;
  // double calculatedAmount (Currency destinationCurrency) {

  //   double input = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;

  //   if (destinationCurrency == Currency.ves) {
      
  //     log('Calculating amount: ${input * amount}', name: 'Calculated Amount');
  //     currentAmount = input * amount;
  //     notifyListeners();
  //     return currentAmount;

  //   } else if (destinationCurrency == Currency.usd) {
  //     // Verificamos que 'amount' sea mayor a un valor mínimo razonable
  //     // para evitar divisiones con números minúsculos que causan Infinity
  //     if (amount > 0.0001) {
  //       currentAmount = input / amount;
  //       log('Calculating amount: $currentAmount', name: 'Calculated Amount');
  //     } else {
  //       currentAmount = 0.0;
  //       log('Tasa de cambio inválida o muy pequeña, resultado 0.0', name: 'Calculated Amount');
  //     }

  //     notifyListeners();
  //     return currentAmount;
  //   } else if (destinationCurrency == Currency.eur) {
      
  //   }

  //   notifyListeners();
  //   return 0.0;
  // }

  late UsdsExchangeRateApi usdsExchangeRateApi = UsdsExchangeRateApi();

  Future<UsdExchangeModel> getUsdExchangeRate() async {
    
    log('Function getUsdExchangeRate');
    super.setLoadingStatus(true);
    notifyListeners();

    try{
      
      UsdExchangeModel resp = await usdsExchangeRateApi.getExchangeRate();
      debugPrint('Respuesta de la API: ${resp.exchange.toList()}');
      debugPrint(resp.toString());

      oficialRate = resp.exchange[0].promedio;
      averageRate = resp.exchange[1].promedio;
      // amount = oficialRate;
      oficialRateUpdateDate = resp.exchange[0].fechaActualizacion!;
      averageRateUpdateDate = resp.exchange[1].fechaActualizacion!;

      log('Oficial: $oficialRate, Average: $averageRate');
      log('Oficial: $oficialRateUpdateDate, Average: $averageRateUpdateDate');

      notifyListeners();
      return resp;

    } catch (e) {
      // Aquí podrías manejar el error de forma global
      log('Error en el provider: $e');
      throw Exception('Failed to fetch exchange rate: $e');

    } finally {
      super.setLoadingStatus(false);
      notifyListeners();
    }
  }

  //* Funcion solo para llamar al api de historico
  // Future<UsdExchangeModel> getUsdExchangeRateHistoric() async {

  //   log('Function HISTORICO', name: 'HISTORY');
  //   super.setLoadingStatus(true);
  //   notifyListeners();

  //   try{
  //       UsdExchangeModel resp = await usdsExchangeRateApi.getExchangeRateHistoric();
  //       return resp;
  //   } catch (e) {
  //     // Aquí podrías manejar el error de forma global
  //     log('Error en el provider: $e', name: 'getUsdExchangeRateHistory - HISTORY', error: e, stackTrace: StackTrace.current);
  //     throw Exception('Failed to fetch exchange rate: $e');

  //   } finally {
  //     super.setLoadingStatus(false);
  //     notifyListeners();
  //   }
  // }

  //* historico de tasas de cambio USD
  // Future<List<adapters.CurrencyHistoryModel>> getUsdExchangeRateHistory() async {
    
  //   log('Function HISTORICO', name: 'HISTORY');
  //   super.setLoadingStatus(true);
  //   notifyListeners();

  //   try{

  //       UsdExchangeModel resp = await getUsdExchangeRateHistoric();
        
  //       var data = processExchangeRateDatahistoric(resp);
  //       log('Data recibida: $data', name: 'HISTORY PROVIDER');

  //       data.then((value) {
  //         log('Data recibida: $value', name: 'HISTORY PROVIDER');
  //         for(var element in value) {
  //           log('Elemento: $element', name: 'HISTORY PROVIDER');
  //           oficialRate = element.value as double;
  //           averageRate = element.marketUsdValue as double;
  //           oficialRateUpdateDate = element.oficialRateUpdateDate!;
  //           averageRateUpdateDate = element.averageRateUpdateDate!;
  //           amount = oficialRate;
  //           setAverageRatePercentage(element.marketUsdPercentageDifference as double);
  //           setOficialRatePercentage(element.percentageDifference as double);
  //           setAverageRateUpValue(element.marketUsdIncrementValue as bool);
  //           setOficialRateUpValue(element.incrementValue as bool);
  //         }
  //       });
        
  //       log('Fecha oficial: $oficialRateUpdateDate', name: 'HISTORY PROVIDER');
  //       log('Fecha average: $averageRateUpdateDate', name: 'HISTORY PROVIDER');
        
  //       notifyListeners();
  //       return data;

  //   } catch (e) {
  //     // Aquí podrías manejar el error de forma global
  //     log('Error en el provider: $e', name: 'getUsdExchangeRateHistory - HISTORY', error: e, stackTrace: StackTrace.current);
  //     throw Exception('Failed to fetch exchange rate: $e');

  //   } finally {
  //     super.setLoadingStatus(false);
  //     notifyListeners();
  //   }
  // }

  // Future<List<adapters.CurrencyHistoryModel>> processExchangeRateDatahistoric(UsdExchangeModel rate) async {
  //   List<adapters.CurrencyHistoryModel> finalRates = [];

  //   DateTime now = DateTime.now();
  //   DateTime today = DateTime(now.year, now.month, now.day);
  //   DateTime startDate = today.subtract(const Duration(days: 7));

  //   // 1. Filtrar registros de la semana y ordenar por fecha
  //   List<UsdExchangeTypeModel> ratesWeek = rate.exchange.where((e) {
  //     return e.fecha!.isAfter(startDate) || e.fecha!.isAtSameMomentAs(startDate);
  //   }).toList();
    
  //   if (ratesWeek.isEmpty) return []; // Si no hay datos, retornar lista vacía

  //   ratesWeek.sort((a, b) => a.fecha!.compareTo(b.fecha!));

  //   // 2. Agrupar por día
  //   Map<String, List<UsdExchangeTypeModel>> groupedByDate = {};
  //   for (var e in ratesWeek) {
  //     String dateKey = e.fecha!.toIso8601String().split('T')[0];
  //     groupedByDate.putIfAbsent(dateKey, () => []).add(e);
  //   }

  //   // 3. OBTENER VALORES INICIALES DE FORMA SEGURA
  //   // En lugar de buscar la fecha exacta de startDate, buscamos el primer registro disponible
  //   // para 'oficial' y 'paralelo' dentro de la lista que ya tenemos.
    
  //   double lastOficialValue = 0;
  //   double lastParaleloValue = 0;

  //   try {
  //     // Intentamos buscar el del primer día del grupo para que sirva de base
  //     lastOficialValue = rate.exchange.firstWhere(
  //       (e) => e.fuente == 'oficial' && (e.fecha!.isBefore(ratesWeek.first.fecha!) || e.fecha!.isAtSameMomentAs(ratesWeek.first.fecha!)),
  //       orElse: () => rate.exchange.firstWhere((e) => e.fuente == 'oficial') // Si no, el primero que exista
  //     ).promedio;

  //     lastParaleloValue = rate.exchange.firstWhere(
  //       (e) => e.fuente == 'paralelo' && (e.fecha!.isBefore(ratesWeek.first.fecha!) || e.fecha!.isAtSameMomentAs(ratesWeek.first.fecha!)),
  //       orElse: () => rate.exchange.firstWhere((e) => e.fuente == 'paralelo')
  //     ).promedio;
  //   } catch (e) {
  //     // Si la tabla está totalmente vacía de esa fuente
  //     lastOficialValue = 0;
  //     lastParaleloValue = 0;
  //   }

  //   // 4. Procesar grupos
  //   groupedByDate.forEach((dateKey, entries) {
  //     var oficialToday = entries.where((e) => e.fuente == 'oficial').isEmpty 
  //         ? null : entries.firstWhere((e) => e.fuente == 'oficial');
          
  //     var paraleloToday = entries.where((e) => e.fuente == 'paralelo').isEmpty 
  //         ? null : entries.firstWhere((e) => e.fuente == 'paralelo');

  //     double currentOficial = oficialToday?.promedio ?? lastOficialValue;
  //     double currentParalelo = paraleloToday?.promedio ?? lastParaleloValue;

  //     // Calcular diferencias (Solo si el valor previo no es cero para evitar divisiones por cero)
  //     double oficialDiff = lastOficialValue == 0 ? 0 : ((currentOficial - lastOficialValue) / lastOficialValue) * 100;
  //     double paraleloDiff = lastParaleloValue == 0 ? 0 : ((currentParalelo - lastParaleloValue) / lastParaleloValue) * 100;

  //     finalRates.add(
  //       adapters.CurrencyHistoryModel(
  //         createdAt: now,
  //         previusValue: lastOficialValue,
  //         value: currentOficial,
  //         incrementValue: currentOficial >= lastOficialValue,
  //         percentageDifference: oficialDiff.abs(),
  //         marketUsdPreviusValue: lastParaleloValue,
  //         marketUsdValue: currentParalelo,
  //         marketUsdIncrementValue: currentParalelo >= lastParaleloValue,
  //         marketUsdPercentageDifference: paraleloDiff.abs(),
  //         euroPreviusValue: 0,
  //         euroValue: 0,
  //         euroIncrementValue: false,
  //         euroPercentageDifference: 0,
  //         averageRateUpdateDate: paraleloToday?.fecha ?? oficialToday?.fecha ?? now,
  //         oficialRateUpdateDate: oficialToday?.fecha ?? paraleloToday?.fecha ?? now,
  //       )
  //     );

  //     // Actualizar para el siguiente día
  //     lastOficialValue = currentOficial;
  //     lastParaleloValue = currentParalelo;
  //   });

  //   return finalRates;
  // }


  @override
  void disposeValues() {
    super.disposeValues();
    setOficialRate(0);
    setAverageRate(0);
    setOficialRateUpValue(false);
    setAverageRateUpValue(false);
  }

}