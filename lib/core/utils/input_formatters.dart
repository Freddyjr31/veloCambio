import 'package:flutter/services.dart';

/// Limita un campo numérico a porcentajes entre 0 y 100, con hasta dos
/// decimales (máx. `100.00`). Acepta `.` o `,` como separador decimal y
/// rechaza entradas fuera de rango (incluido pegado de texto).
class PercentInputFormatter extends TextInputFormatter {
  const PercentInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trim();
    if (text.isEmpty) return newValue;

    //* Solo dígitos y un único separador decimal (`.` o `,`).
    if (!RegExp(r'^[0-9]*([.,][0-9]*)?$').hasMatch(text)) return oldValue;

    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed == null || parsed > 100) return oldValue;

    //* Máximo 2 decimales.
    final parts = text.replaceAll(',', '.').split('.');
    if (parts.length == 2 && parts[1].length > 2) return oldValue;

    return newValue;
  }
}