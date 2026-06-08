import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:velocambio/providers/euro_provider.dart';
import 'package:velocambio/providers/index.dart';

/// Calculadora personalizada para ingresar montos
class Calculator extends StatefulWidget {

  const Calculator({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  
  ///
  double amount = 0.00;
  ///
  double valueAmount = 0.00;
  /// Para mostrar el monto ingresado en la calculadora
  String calculatorAmount = '';
  /// Para guardar el monto total de la conversión
  String amountCalculated = '';
  /// Para saber si el monto debe reflejarse en VES
  bool isVes = true;

  @override
  Widget build(BuildContext context) {

    final coinProvider = context.watch<CoinProvider>();
    final exchangeProvider = context.watch<UsdExchangeRateProvider>();
    final euroProvider = context.watch<EuroProvider>();

    Currency originCurrency = coinProvider.originCurrency; //* USD primera vez
    Currency destinationCurrency = coinProvider.destinationCurrency; //* VES primera vez

    /// Para obtener el tamaño de la pantalla
    final size = MediaQuery.of(context).size;
    
    ///* Para mostrar el monto ingresado en la calculadora y demas (solo son logs)
    log(coinProvider.formatoBolivar.format(coinProvider.amount).toString(), name: 'amount provider Bs');
    log(coinProvider.formatoDolar.format(coinProvider.amount).toString(), name: 'amount provider USD');
    log(coinProvider.formatoBolivar.format(amount).toString(), name: 'amount Bs');
    log(coinProvider.formatoDolar.format(amount).toString(), name: 'amount USD');


    return Container(
        width: size.width * 0.9,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: Colors.white10, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                  child: Text(
                    'Conversión ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                //*  boton para cambiar las monedas
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[50]!.withAlpha(10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    spacing: 5,
                    children: [
                      
                      //* Icono de la moneda de origen
                      Text(
                        coinProvider.inputCurrencyCoin,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white
                        )
                      ),
                
                      Tooltip(
                        message: 'Cambiar monedas',
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            // color: Colors.grey[50]?.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                        child: IconButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(EdgeInsets.zero),
                            minimumSize: WidgetStateProperty.all(Size(30, 30)),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.center,
                            backgroundColor: WidgetStateProperty.all(Colors.white12),
                          ),
                          onPressed: () {
                      
                            setState(() {
                              isVes = !isVes;
                            });
                            
                            //* Intercambiar las monedas
                            coinProvider.changeOriginCurrency(destinationCurrency);
                            coinProvider.changeDestinationCurrency(originCurrency);
                      
                            //* aqui intercambio las tasas de cambio
                            if(isVes == false) {

                              coinProvider.setInputCurrencyCoin(Currency.ves.code);

                              if(ExchangeType.oficialUsd == coinProvider.exchangeType || ExchangeType.averageUsd == coinProvider.exchangeType) {
                                coinProvider.setOutputCurrencyCoin(Currency.usd.code);
                              } else if (ExchangeType.oficialEur == coinProvider.exchangeType) {
                                coinProvider.setOutputCurrencyCoin(Currency.eur.code);
                              } else if (ExchangeType.custom == coinProvider.exchangeType) {
                                coinProvider.setOutputCurrencyCoin(Currency.custom.code);
                              }

                            } else {

                              coinProvider.setOutputCurrencyCoin(Currency.ves.code);
                              
                              if(ExchangeType.oficialUsd == coinProvider.exchangeType || ExchangeType.averageUsd == coinProvider.exchangeType) {
                                coinProvider.setInputCurrencyCoin(Currency.usd.code);
                              } else if (ExchangeType.oficialEur == coinProvider.exchangeType) {
                                coinProvider.setInputCurrencyCoin(Currency.eur.code);
                              } else if (ExchangeType.custom == coinProvider.exchangeType) {
                                coinProvider.setInputCurrencyCoin(Currency.custom.code);
                              }
                            }
                      
                            //* Recalcular el monto con la nueva moneda de destino
                            coinProvider.calculatedAmount(
                              rateUsdBcv: exchangeProvider.oficialRate,
                              rateUsdMarket: exchangeProvider.averageRate,
                              rateEUR: euroProvider.oficialEuroRate,
                            );
                          },
                          icon: const Icon(
                            Icons.swap_horiz,
                            color: Colors.white,
                          ),
                        ),
                      )
                      ),
                
                      //* Icono de la moneda de destino
                      Text(
                        coinProvider.outputCurrencyCoin,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white
                        )
                      ),
                    ],
                  ),
                )
              ],
            ),

            // DropdownButtonFormField<Currency>(
            //     borderRadius: BorderRadius.circular(16),
            //     initialValue: originCurrency,
            //     elevation: 9,
            //     decoration: InputDecoration(
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       labelText: 'Moneda origen',
            //       labelStyle: TextStyle(color: Colors.white),
            //     ),
            //     onChanged: (Currency? newValue) {

            //       if (newValue != null) {
            //         setState(() {
            //           originCurrency = newValue;
            //           coinProvider.changeOriginCurrency(newValue);
            //         });

            //         // coinProvider.calculatedAmount(destinationCurrency);
            //         coinProvider.calculatedAmount(
            //           rateUsdBcv: exchangeProvider.oficialRate,
            //           rateUsdMarket: exchangeProvider.averageRate,
            //           rateEUR: euroProvider.oficialEuroRate,
            //         );
            //       }

            //     },
            //     items: Currency.values.map((Currency currency) {
            //       return  DropdownMenuItem<Currency>(
            //         value: currency,
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             ClipRRect(
            //               borderRadius: BorderRadius.circular(3),
            //               child: Image.asset(
            //                 currency.flagPath,
            //                 width: 23,
            //                 height: 15,
            //                 fit: BoxFit.cover,
            //                 errorBuilder: (context, error, stackTrace) => 
            //                     const Icon(Icons.flag, size: 15),
            //               ),
            //             ),
            //             const SizedBox(width: 5),
            //             Text(currency.code),
            //           ],
            //         ),
            //       );
            //     }).toList(),
                
            //   ),

            // const SizedBox(height: 10),

            // DropdownButtonFormField<Currency>(
            //     borderRadius: BorderRadius.circular(16),
            //     initialValue: destinationCurrency,
            //     elevation: 9,
            //     decoration: InputDecoration(
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       labelText: 'Moneda destino',
            //       labelStyle: TextStyle(color: Colors.white),
            //     ),
            //     onChanged: (Currency? newValue) {

            //       if (newValue == null) return;
                  
            //       setState(() {
            //         destinationCurrency = newValue;
            //         coinProvider.changeDestinationCurrency(newValue);
            //       });

            //       coinProvider.calculatedAmount(
            //         rateUsdBcv: exchangeProvider.oficialRate,
            //         rateUsdMarket: exchangeProvider.averageRate,
            //         rateEUR: euroProvider.oficialEuroRate,
            //       );

            //     },
            //     items: Currency.values.map((Currency currency) {
            //       return DropdownMenuItem<Currency>(
            //         value: currency,
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             ClipRRect(
            //               borderRadius: BorderRadius.circular(3),
            //               child: Image.asset(
            //                 currency.flagPath,
            //                 width: 23,
            //                 height: 15,
            //                 fit: BoxFit.cover,
            //                 errorBuilder: (context, error, stackTrace) => 
            //                     const Icon(Icons.flag, size: 15),
            //               ),
            //             ),
            //             const SizedBox(width: 5),
            //             Text(currency.code),
            //                 ],
            //               ),
            //             );
            //           }).toList(),
            //         ),

            //* Monto Ingresado
            if(destinationCurrency != originCurrency)...[

              //* Monto Total
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[50]?.withAlpha(10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                
                    Expanded(
                      child: Container(
                        width: size.width * 0.65,
                        margin: const EdgeInsets.only(top: 0),
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child:
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text.rich(
                            TextSpan(
                              text: 'Total: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  // text: destinationCurrency == Currency.usd
                                  //   ? "${coinProvider.formatoDolar.format(coinProvider.currentAmount)} USD"
                                  //   : destinationCurrency == Currency.ves
                                  //     ? coinProvider.formatoBolivar.format(coinProvider.currentAmount) 
                                  //     : "${coinProvider.formatoEuro.format(coinProvider.currentAmount)} EUR",
                                  text: isVes ? coinProvider.formatoBolivar.format(coinProvider.currentAmount) : ExchangeType.oficialUsd == coinProvider.exchangeType ? "${coinProvider.formatoDolar.format(coinProvider.currentAmount)} USD" : ExchangeType.oficialEur == coinProvider.exchangeType ? "${coinProvider.formatoEuro.format(coinProvider.currentAmount)} EUR" : destinationCurrency == Currency.usd
                                    ? "${coinProvider.formatoDolar.format(coinProvider.currentAmount)} USD"
                                    : destinationCurrency == Currency.ves
                                      ? coinProvider.formatoBolivar.format(coinProvider.currentAmount) 
                                      : "${coinProvider.formatoEuro.format(coinProvider.currentAmount)} EUR",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        )
                      ),
                    ),
                                
                    // const Spacer(),
                                
                    SizedBox(
                      width: size.width * 0.1,
                      child: IconButton(
                        alignment: Alignment.centerRight,
                        icon: const Icon(
                          Icons.copy,
                          size: 20,
                        ),
                        onPressed: () {
                                      
                          //* Copiamos el monto
                          Clipboard.setData(
                            ClipboardData(
                              // text: coinProvider.destinationCurrency == Currency.usd
                              //       ? coinProvider.currentAmount.toStringAsFixed(3)
                              //       : coinProvider.destinationCurrency == Currency.ves
                              //         ? coinProvider.currentAmount.toStringAsFixed(3)
                              //         : coinProvider.currentAmount.toStringAsFixed(3)
                              text: isVes ? coinProvider.formatoBolivar.format(coinProvider.currentAmount) : ExchangeType.oficialUsd == coinProvider.exchangeType ? coinProvider.currentAmount.toStringAsFixed(3) : ExchangeType.oficialEur == coinProvider.exchangeType ? coinProvider.currentAmount.toStringAsFixed(3) : coinProvider.destinationCurrency == Currency.usd
                                    ? coinProvider.currentAmount.toStringAsFixed(3)
                                    : coinProvider.destinationCurrency == Currency.ves
                                      ? coinProvider.currentAmount.toStringAsFixed(3) 
                                      : coinProvider.currentAmount.toStringAsFixed(3),
                              )
                            );
                      
                          //* Para mostrar mensaje de que se ha copiado el monto
                          toastification.show(
                            style: ToastificationStyle.fillColored,
                            // title: Text(coinProvider.destinationCurrency == Currency.usd
                            //         ? "${coinProvider.formatoDolar.format(coinProvider.currentAmount)} USD"
                            //         : coinProvider.destinationCurrency == Currency.ves
                            //           ? coinProvider.formatoBolivar.format(coinProvider.currentAmount) 
                            //           : "${coinProvider.formatoEuro.format(coinProvider.currentAmount)} EUR"),
                            title: Text( isVes ? coinProvider.formatoBolivar.format(coinProvider.currentAmount) : ExchangeType.oficialUsd == coinProvider.exchangeType ? "${coinProvider.formatoDolar.format(coinProvider.currentAmount)} USD" : ExchangeType.oficialEur == coinProvider.exchangeType ? "${coinProvider.formatoEuro.format(coinProvider.currentAmount)} EUR" : coinProvider.destinationCurrency == Currency.usd
                                    ? "${coinProvider.formatoDolar.format(coinProvider.currentAmount)} USD"
                                    : coinProvider.destinationCurrency == Currency.ves
                                      ? "${coinProvider.formatoBolivar.format(coinProvider.currentAmount)} VES" 
                                      : "${coinProvider.formatoEuro.format(coinProvider.currentAmount)} EUR"),
                            description: Text('Monto copiado al portapapeles!'),
                            type: ToastificationType.success,
                            autoCloseDuration: Duration(seconds: 3),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              //* Input de monto
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                        )]
                      ),
                      child: TextField(
                        onTapUpOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        controller: coinProvider.amountController,
                        onChanged: (value) {
                          setState(() {
                            amount = coinProvider.calculatedAmount(
                              rateUsdBcv: exchangeProvider.oficialRate,
                              rateUsdMarket: exchangeProvider.averageRate,
                              rateEUR: euroProvider.oficialEuroRate,
                            );
                          });
                        },
                        keyboardType: TextInputType.number,
                        keyboardAppearance: Brightness.dark,
                        textAlign: TextAlign.end,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.currency_exchange, color: Colors.blueGrey[100], size: 20,),
                          label: Text('Monto a cambiar', style: TextStyle(color: Colors.blueGrey[100], fontSize: 15, fontWeight: FontWeight.bold),),
                          prefix: Text(coinProvider.inputCurrencyCoin,
                            style: TextStyle(color: Colors.blueGrey[100], fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          suffixStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.close, size: 20, color: Colors.grey[600],),
                            onPressed: () {
                              coinProvider.amountController.clear();
                              coinProvider.calculatedAmount(
                                rateUsdBcv: exchangeProvider.oficialRate,
                                rateUsdMarket: exchangeProvider.averageRate,
                                rateEUR: euroProvider.oficialEuroRate,
                              );
                              setState(() {
                                amount = 0.00;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              
            ] else ...[
              Center(
                child: Container(
                  width: size.width * 0.9,
                  height: size.height * 0.05,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      Icon(Icons.warning_amber_outlined, size: 20, color: Colors.black),
                      SizedBox(width: 5),
                      Text(
                        'Seleccione monedas diferentes para convertir',
                        style: TextStyle(fontSize: size.height * 0.015, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ], 
                  )
                  ),
              ),
            ],

            SizedBox(height: 10),
    
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 5),
      //         child: Divider(
      //           thickness: 1,
      //           color: Colors.blueGrey[300]!,
      //         ),
      //       ),
    
      //       //* -------- Calculadora --------------
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 5),
      //         child: Text(
      //           'Calcular conversión',
      //           textAlign: TextAlign.start,
      //           style: TextStyle(
      //             fontSize: 16,
      //             fontWeight: FontWeight.bold,
      //           ),
      //         ),
      //       ),
    
      //       SizedBox(height: 10),
    
      //       //* AQUI MUESTRO EL TEXTO DEL CALCULO EN PANTALLA
      //       Container(
      //         decoration: BoxDecoration(
      //           color: Colors.blueGrey[50],
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //         alignment: Alignment.centerRight,
      //         padding: EdgeInsets.all(10),
      //         child: Text(
      //           calculatorAmount,
      //           maxLines: 2,
      //           style: TextStyle(
      //             fontSize: calculatorAmount.length > 20 ? 15 : 20 ,
      //             fontWeight: FontWeight.bold),
      //         ),
      //       ),
    
      //       SizedBox(height: 10),
    
      //       //* Botones para sumar y restar
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //         children: [
      //         //* borrar todo el contenido calculado
      //         ElevatedButton(
      //           onPressed: () {
      //             setState(() {
      //               calculatorAmount = '';
      //             });
      //           },
      //           style: ElevatedButton.styleFrom(
      //             backgroundColor: Colors.redAccent,
      //           ),
      //           child: Text('C', style: TextStyle(fontSize: 20)),
      //         ),
      //         SizedBox(width: 10),
    
      //         //* sumar
      //         ElevatedButton(
      //           onPressed: () {
    
      //             if(calculatorAmount.endsWith('+') || calculatorAmount.endsWith('-') || calculatorAmount.isEmpty) {
      //               HapticFeedback.mediumImpact();
      //               return;
      //             } else {
      //               setState(() {
      //                 calculatorAmount += '+';
      //               });
      //             }
    
      //           },
      //           child: Text('+', style: TextStyle(fontSize: 20)),
      //         ),
      //         SizedBox(width: 10),
    
      //         //* restar
      //         ElevatedButton(
      //           onPressed: () {
      //             if(calculatorAmount.endsWith('+') || calculatorAmount.endsWith('-') || calculatorAmount.isEmpty) {
      //               HapticFeedback.mediumImpact();
      //               return;
      //             } else {
      //               setState(() {
      //                 calculatorAmount += '-';
      //               });
      //             }
      //           },
      //           child: Text('-', style: TextStyle(fontSize: 20)),
      //         ),
    
      //         SizedBox(width: 10),
    
      //         //* igual
      //         ElevatedButton(
      //           onPressed: () {
    
      //             if(calculatorAmount.endsWith('+') || calculatorAmount.endsWith('-') || calculatorAmount.isEmpty) {
      //               HapticFeedback.mediumImpact();
      //               return;
      //             }
    
      //             setState(() {
      //               //* Calcular el resultado
      //               var partes = calculatorAmount.split(RegExp(r'(\+|-)'));
      //               log(partes.toString(), name: 'partes');
      //               var operadores = RegExp(r'(\+|-)').allMatches(calculatorAmount).map((m) => m.group(0)).toList();
      //               log(operadores.toString(), name: 'operadores');
      //               var numeros = partes.map((parte) => double.tryParse(parte.trim()) ?? 0.0).toList();
      //               var resultado = 0.0;
      //               for (var i = 0; i < operadores.length; i++) {
      //                 if (operadores[i] == '+') {
      //                   resultado = numeros[i] + numeros[i + 1];
      //                 } else if (operadores[i] == '-') {
      //                   resultado = numeros[i] - numeros[i + 1];
      //                 }
      //               }
    
      //               setState(() {
      //                 calculatorAmount = resultado.toStringAsFixed(2);
      //               });
    
      //             });
      //           },
      //           child: Text('=', style: TextStyle(fontSize: 20)),
      //         )
      //       ],),
    
      //       //* TECLADO PERSONALIZADO
      //       Expanded(
      //         child: GridView.count(
      //           childAspectRatio: 1.5,
      //           crossAxisCount: 3,
      //           shrinkWrap: true,
      //           children: [
      //             _boton('7'), _boton('8'), _boton('9'),
      //             _boton('4'), _boton('5'), _boton('6'),
      //             _boton('1'), _boton('2'), _boton('3'),
      //             _boton('.'), _boton('0'), _boton('Borrar'),
      //           ],
      //         ),
      //       ),
          ],
        ),
      );
  }

  //* ------- Función para crear los botones
  /// Función para crear los botones
//   Widget _boton(String valor) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         splashFactory: InkRipple.splashFactory,
//         focusColor: Colors.blueGrey[50],
//         splashColor: Colors.blueGrey[50],
//         highlightColor: Colors.blueGrey[50],
//         radius: 20,
//         borderRadius: BorderRadius.circular(20),
//         onTap: () {
      
//           if (valor == 'Borrar') {
//             setState(() {
//               // Lógica para borrar el texto
//               if (calculatorAmount.isNotEmpty) {
//                 calculatorAmount = calculatorAmount.substring(0, calculatorAmount.length - 1);
//               }
//             });
//             return;
//           } else {
//             setState(() {
//               // Lógica para concatenar el texto (validando que no haya doble punto)
//               calculatorAmount += valor; 
//             });
//           }
//         },
//         child: Center(
//           child: 
//           Text(valor, style: TextStyle(fontSize: 20))
//         ),
//       ),
//     );
//   }
}

