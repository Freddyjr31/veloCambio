// import 'dart:developer';

// import 'package:velocambio/main.dart';
// import 'package:velocambio/models/currency_history_model.dart';
// import 'package:velocambio/providers/cmm_general_provider.dart';

// class DatabaseDatasource extends CmmGeneralProvider {

//   //* Insertar los datos en la base de datos
//   Future<bool> insertPaymentDataSource(CurrencyHistoryModel data) async {
//       try {
//         await supabase
//             .from('dolar_history')
//             .insert(data.toJson());

//         log('Insertado correctamente', name: 'insertPaymentDataSource');
//         return true;
//       } catch (error) {
//         log('Error al insertar: $error', name: 'insertPaymentDataSource');
//         return false;
//       }
//   }

//   //* Consultar los datos de la base de datos
//   Future<List<CurrencyHistoryModel>> getPaymentDataSource() async {
//     final response = await supabase
//         .from('dolar_history')
//         .select()
//         .order('created_at', ascending: false)
//         .limit(1);
//         // .maybeSingle();

//     return response.map((json) => CurrencyHistoryModel.fromJson(json)).toList();
//   }

// }
