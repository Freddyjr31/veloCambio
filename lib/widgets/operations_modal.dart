import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/core/utils/operations.dart';
import 'package:velocambio/core/utlis/format_coins.dart';
import 'package:velocambio/providers/theme_provider.dart';
import 'package:velocambio/widgets/operation_pill_button.dart';

/// Tipos de operación disponibles en el modal.
enum OperationType {
  percentOf,
  addPercent,
  subtractPercent,
  addValue,
  subtractValue,
}

/// Modal de operaciones sobre tasas/montos.
///
/// Permite calcular porcentajes o sumar/restar un valor fijo al resultado
/// de la calculadora, sin salir de la app.
class OperationsModal extends StatefulWidget {
  /// Monto base inicial (prellenado con el resultado de la calculadora).
  final double baseAmount;

  /// Código de la moneda del monto base (USD, VES, EUR, USDT...).
  final String currencyCode;

  const OperationsModal({
    super.key,
    required this.baseAmount,
    required this.currencyCode,
  });

  /// Abre el modal como bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required double baseAmount,
    required String currencyCode,
  }) {
    return showModalBottomSheet(
      barrierColor: Colors.black.withValues(alpha: 0.6),
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          OperationsModal(baseAmount: baseAmount, currencyCode: currencyCode),
    );
  }

  @override
  State<OperationsModal> createState() => _OperationsModalState();
}

class _OperationsModalState extends State<OperationsModal> {
  /// Controladores de los campos de texto.
  late final TextEditingController _baseController;
  late final TextEditingController _valueController;

  /// Operación seleccionada (por defecto: sumar porcentaje).
  OperationType _operation = OperationType.addPercent;

  @override
  void initState() {
    super.initState();

    //* Se prellena el monto base con el resultado de la calculadora.
    _baseController = TextEditingController(
      text: widget.baseAmount.toStringAsFixed(3),
    );
    _valueController = TextEditingController();
  }

  @override
  void dispose() {
    _baseController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  /// Formatea el monto según la moneda del monto base.
  String _formatAmount(double value) {
    switch (widget.currencyCode) {
      case 'USD':
      case 'USDT':
        return formatoDolar.format(value);
      case 'EUR':
        return formatoEuro.format(value);
      default:
        return formatoBolivar.format(value);
    }
  }

  /// Calcula el resultado según la operación seleccionada.
  double _computeResult() {
    final base =
        double.tryParse(_baseController.text.replaceAll(',', '.')) ?? 0;
    final value =
        double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0;

    switch (_operation) {
      case OperationType.percentOf:
        return OperationsCalculator.percentageOf(
          amount: base,
          percentage: value,
        );
      case OperationType.addPercent:
        return OperationsCalculator.applyPercentage(
          base: base,
          percentage: value,
          subtract: false,
        );
      case OperationType.subtractPercent:
        return OperationsCalculator.applyPercentage(
          base: base,
          percentage: value,
          subtract: true,
        );
      case OperationType.addValue:
        return OperationsCalculator.applyValue(
          base: base,
          value: value,
          subtract: false,
        );
      case OperationType.subtractValue:
        return OperationsCalculator.applyValue(
          base: base,
          value: value,
          subtract: true,
        );
    }
  }

  /// Copia el resultado al portapapeles y notifica al usuario.
  void _copyResult() {
    final result = _formatAmount(_computeResult());

    Clipboard.setData(ClipboardData(text: result));

    toastification.show(
      context: context,
      style: ToastificationStyle.fillColored,
      title: Text(result),
      description: const Text('Resultado copiado al portapapeles!'),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  /// Etiqueta dinámica del campo de valor según la operación.
  String get _valueLabel {
    switch (_operation) {
      case OperationType.percentOf:
        return 'Porcentaje a calcular (%)';
      case OperationType.addPercent:
      case OperationType.subtractPercent:
        return 'Porcentaje (%)';
      case OperationType.addValue:
      case OperationType.subtractValue:
        return 'Valor a sumar/restar';
    }
  }

  /// Icono de la operación seleccionada.
  IconData get _operationIcon {
    switch (_operation) {
      case OperationType.percentOf:
        return Icons.percent;
      case OperationType.addPercent:
      case OperationType.addValue:
        return Icons.add_circle_outline;
      case OperationType.subtractPercent:
      case OperationType.subtractValue:
        return Icons.remove_circle_outline;
    }
  }

  /// Define los chips de selección de operación.
  List<({OperationType type, String label, String tooltip})> get _operations {
    return const [
      (
        type: OperationType.percentOf,
        label: 'X% de',
        tooltip: '¿Cuánto es un porcentaje del monto?',
      ),
      (
        type: OperationType.addPercent,
        label: '+ %',
        tooltip: 'Suma un porcentaje al monto',
      ),
      (
        type: OperationType.subtractPercent,
        label: '- %',
        tooltip: 'Resta un porcentaje al monto',
      ),
      (
        type: OperationType.addValue,
        label: '+ Valor',
        tooltip: 'Suma un valor fijo al monto',
      ),
      (
        type: OperationType.subtractValue,
        label: '- Valor',
        tooltip: 'Resta un valor fijo al monto',
      ),
    ];
  }

  /// Chips de porcentaje (agrupados arriba).
  List<({OperationType type, String label, String tooltip})>
  get _percentageOps => _operations
      .where(
        (op) =>
            op.type == OperationType.percentOf ||
            op.type == OperationType.addPercent ||
            op.type == OperationType.subtractPercent,
      )
      .toList();

  /// Chips de sumar/restar valor (en un mismo row).
  List<({OperationType type, String label, String tooltip})> get _valueOps =>
      _operations
          .where(
            (op) =>
                op.type == OperationType.addValue ||
                op.type == OperationType.subtractValue,
          )
          .toList();

  /// Construye un pill de selección con tooltip y sin checkmark.
  Widget _operationPill(
    ({OperationType type, String label, String tooltip}) op,
  ) {
    return OperationPillButton(
      label: op.label,
      tooltip: op.tooltip,
      selected: _operation == op.type,
      onTap: () => setState(() => _operation = op.type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = context.watch<ThemeProvider>();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  //* Titulo + boton cerrar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Operaciones',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  //* Descripcion
                  Text(
                    'Calcula porcentajes, obtén el % de un monto o suma/resta valores',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 16),

                  //* Monto base
                  TextField(
                    controller: _baseController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    keyboardAppearance: Theme.of(context).brightness,
                    textAlign: TextAlign.center,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(
                        Icons.currency_exchange,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                      label: const Text('Monto base'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  //* Selector de operacion: porcentajes agrupados arriba
                  Row(
                    spacing: 8,
                    children: _percentageOps
                        .map((op) => Expanded(child: _operationPill(op)))
                        .toList(),
                  ),

                  const SizedBox(height: 8),

                  //* Sumar/restar valor en un mismo row
                  Row(
                    spacing: 8,
                    children: _valueOps
                        .map((op) => Expanded(child: _operationPill(op)))
                        .toList(),
                  ),

                  const SizedBox(height: 16),

                  //* Campo de valor/porcentaje
                  TextField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    keyboardAppearance: Theme.of(context).brightness,
                    textAlign: TextAlign.center,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(
                        _operationIcon,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                      label: Text(_valueLabel),
                    ),
                  ),

                  const SizedBox(height: 16),

                  //* Resultado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: primaryColor.withAlpha(50),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resultado',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  _formatAmount(_computeResult()),
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          tooltip: 'Copiar resultado',
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: _copyResult,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  //* Boton de guardar/cerrar
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        minimumSize: Size(size.width * 0.85, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: themeProvider.isDark ? 
                          Colors.grey[50]?.withAlpha(10) : Colors.black,
                        overlayColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(
                        'Cerrar',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        ),
                        ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
