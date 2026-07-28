
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/datasource/services/database_hive_services.dart';
import 'package:velocambio/models/adapters/currency_history_adapters.dart' as adapters;
import 'package:velocambio/models/currency_model.dart';
import 'package:velocambio/models/exchange_types_model.dart';


class CoinProvider extends CmmGeneralProvider {

  //* para montos del input de la calculadora
  TextEditingController amountController = TextEditingController();

  //* evaluo si la moneda de destino es VES
  bool isDestinationVES() => destinationCurrency == Currency.ves;
  
  //* modena de origin
  Currency originCurrency = Currency.usd;
  //* modena de destino
  Currency destinationCurrency = Currency.ves;

  //* cambiar la moneda de origen
  void changeOriginCurrency(Currency currency) {
    originCurrency = currency;
    notifyListeners();
  }

  //* cambiar la moneda de destino
  void changeDestinationCurrency(Currency currency) {
    destinationCurrency = currency;
    notifyListeners();
  }

  //* exchange type
  ExchangeType exchangeType = ExchangeType.oficialUsd;
  void changeExchangeType(ExchangeType type) {
    exchangeType = type;
    notifyListeners();
  }

  //* para cambiar el monto, ESTE ES EL VALOR PRINCIPAL QUE SE USA PARA CALCULAR EL MONTO EN LA OTRA MONEDA
  double amount = 0;
  void setAmount(double val) {
    amount = val;
    notifyListeners();
  }

  double currentAmount = 0;
  double calculatedAmount ({required double rateUsdBcv, required double rateUsdMarket, required double rateEUR, required double rateP2P}) {

    double input = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
    log('Calculating amount: $input', name: 'Calculated Amount');
    log('Origin Currency: $originCurrency', name: 'Calculated Amount');
    log('Destination Currency: $destinationCurrency', name: 'Calculated Amount');
    // log('Rates - VES: $rateUsdBcv, USD: $rateUsdMarket, EUR: $rateEUR', name: 'Calculated Amount');

    if (originCurrency == destinationCurrency) return amount;

    // 1. Convertir origen a USD
    double amountInUSD;
    if (originCurrency == Currency.usd || originCurrency == Currency.usdt) {
      amountInUSD = input;
      // notifyListeners();
    } else if (originCurrency == Currency.ves) {
      amountInUSD = input / amount; // Aquí se usa 'amount' que es la tasa de cambio seleccionada (oficial, promedio o personalizada)
      // notifyListeners();
    } else { // Es EUR
      amountInUSD = input / amount; // Aquí se usa 'amount' que es la tasa de cambio seleccionada (oficial, promedio o personalizada)
       //notifyListeners();
    }

    notifyListeners();

    log('Amount in USD: $amountInUSD', name: 'Calculated Amount');

    // 2. Convertir USD a destino
    if (destinationCurrency == Currency.usd || destinationCurrency == Currency.usdt) {
      currentAmount = amountInUSD;
      log('USD Current amount: $currentAmount', name: 'Calculated Amount');
      notifyListeners();
      return currentAmount;
    } else if (destinationCurrency == Currency.ves) {
      currentAmount = amountInUSD * amount;
      log('VES Current amount: $currentAmount', name: 'Calculated Amount');
      notifyListeners();
      return currentAmount;
    } else { // Es EUR
      currentAmount = amountInUSD * rateEUR;
      log('EUR Current amount: $currentAmount', name: 'Calculated Amount');
      notifyListeners();
      return currentAmount;
    }
  }

  String inputCurrencyCoin = Currency.usd.code;
  void setInputCurrencyCoin(String coin) {
    inputCurrencyCoin = coin;
    notifyListeners();
  }

  String outputCurrencyCoin = Currency.ves.code;
  void setOutputCurrencyCoin(String coin) {
    outputCurrencyCoin = coin;
    notifyListeners();
  }

  //* ------------------ Instancia del servicio de HIVE
  final DatabaseHiveServices _dbService = DatabaseHiveServices();

  Future<bool> insertCurrencyHistory(adapters.CurrencyHistoryModel data) async {
  
    final insertData =   await _dbService.saveCurrencyHistory(data);
    
    if (insertData == false) {
      log('Error al insertar', name: 'HIVE - CoinProvider');
      return false;
    }

    log('Insertado correctamente', name: 'HIVE - CoinProvider');
    return true;
  }

  // Future<List<adapters.CurrencyHistoryModel>> getCurrencyHiveHistory() async {
    
  //   final response = await _dbService.getLastCurrencyHistory(); //.getFirstCurrencyHistory();
  //   log('HIVE GET CURRENCY: ${response.toString()}', name: 'HIVE - CoinProvider');
    
  //   response.asMap().forEach((key, value) => log(value.toString(), name: 'HIVE - CoinProvider'));

  //   if (response.isEmpty) {
  //     log('No hay historial de pagos', name: 'HIVE - CoinProvider');
  //     return List.empty();
  //   }
  
  //   return response;
  // }

}