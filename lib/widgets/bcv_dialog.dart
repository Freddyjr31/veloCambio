import 'package:flutter/material.dart';

class BcvDisclaimerModal {
  static void show(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Column(
            spacing: 12,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [

              Image.asset(
                'assets/images/app_icon-removebg_small.PNG',
                width: size.width * 0.5,
              ),
                
              Text('Aviso Importante')

              ],
          ),
          content: SingleChildScrollView(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Esta aplicación tiene un carácter puramente informativo.',
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 15),
                Text(
                  'La tasa oficial que debe utilizarse para transacciones legales en el territorio nacional es la emitida por el Banco Central de Venezuela (BCV).',
                  textAlign: TextAlign.justify,
                  maxLines: 6,
                ),
                SizedBox(height: 10),
                Text(
                  'Nuestra plataforma solo se encarga de mostrar las cotizaciones de diversas fuentes para su referencia y comparación.',
                  textAlign: TextAlign.justify,
                  maxLines: 6,
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity, // Botón de ancho completo
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[50]?.withAlpha(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'ENTENDIDO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
