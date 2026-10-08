import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/core/utils/finance_calculator.dart';
import 'package:velocambio/core/utils/input_formatters.dart';
import 'package:velocambio/core/utils/truncate.dart';
import 'package:velocambio/core/utlis/format_coins.dart';
import 'package:velocambio/providers/theme_provider.dart';

/// Frecuencia de las cuotas.
enum _CuotaFrequency { semanal, quincenal, mensual }

/// Calculadora de cuotas estilo Cashea.
///
/// A partir del precio de un producto, un porcentaje de inicial, la cantidad
/// de cuotas y una frecuencia, calcula el desglose (inicial, financiado,
/// cuota por periodo, total) en USD y VES usando la [rate] seleccionada.
class CuotasCalculator extends StatefulWidget {
  /// Tasa actual (VES por unidad de la moneda base).
  final double rate;

  /// Moneda de la tasa usada (para mostrarla en el aviso).
  final String baseCurrency;

  const CuotasCalculator({
    super.key,
    required this.rate,
    required this.baseCurrency,
  });

  @override
  State<CuotasCalculator> createState() => _CuotasCalculatorState();
}

class _CuotasCalculatorState extends State<CuotasCalculator> {
  final _priceController = TextEditingController();
  final _initialPercentController = TextEditingController(text: '20');
  final _managementController = TextEditingController();

  /// `true` = el precio se escribe en USD; `false` = en Bs.
  bool _priceInUsd = true;

  /// Cantidad de cuotas seleccionada.
  int _installments = 10;

  /// Frecuencia seleccionada.
  _CuotaFrequency _frequency = _CuotaFrequency.semanal;

  /// Habilita el campo de gastos de gestión.
  bool _hasManagement = false;

  @override
  void dispose() {
    _priceController.dispose();
    _initialPercentController.dispose();
    _managementController.dispose();
    super.dispose();
  }

  double _parsed(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  /// Precio de base convertido a USD, o 0 si no se puede convertir.
  double get _priceInUsdValue {
    final price = _parsed(_priceController);
    if (price <= 0) return 0;
    if (_priceInUsd) return price;
    return widget.rate > 0 ? price / widget.rate : 0;
  }

  String get _frequencyLabel => switch (_frequency) {
    _CuotaFrequency.semanal => 'semanal',
    _CuotaFrequency.quincenal => 'quincenal',
    _CuotaFrequency.mensual => 'mensual',
  };

  InstallmentResult? get _result {
    final price = _priceInUsdValue;
    if (price <= 0 || widget.rate <= 0) return null;
    return FinanceCalculator.calculateInstallments(
      price: price,
      initialPercent: _parsed(_initialPercentController),
      installments: _installments,
      managementFee: _hasManagement ? _parsed(_managementController) : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)
              : surfaceColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 14,
              children: [
                //* Titulo
                Row(
                  children: [
                    Text(
                      'Calculadora de cuotas',
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Simula el costo de un producto financiado',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),

                //* Precio + moneda base
                _LabeledField(
                  label: 'Precio del producto',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    spacing: 10,
                    children: [
                      TextField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        keyboardAppearance: Theme.of(context).brightness,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          filled: true,
                          prefix: Text(
                            _priceInUsd ? 'USD ' : 'Bs ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          label: const Text('Monto'),
                        ),
                      ),

                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 5,
                        children: [
                          _chip(
                            'USD',
                            _priceInUsd,
                            () => setState(() => _priceInUsd = true),
                          ),
                          _chip(
                            'Bs',
                            !_priceInUsd,
                            () => setState(() => _priceInUsd = false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                //* Inicial
                _LabeledField(
                  label: 'Porcentaje de inicial',
                  child: TextField(
                    controller: _initialPercentController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [PercentInputFormatter()],
                    keyboardAppearance: Theme.of(context).brightness,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      filled: true,
                      label: Text('Inicial'),
                      suffixText: '%',
                    ),
                  ),
                ),

                //* Cantidad de cuotas
                _LabeledField(
                  label: 'N.º de cuotas',
                  child: Wrap(
                    runAlignment: WrapAlignment.center,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5,
                    children: [
                      for (final n in const [3, 4, 5, 6, 7, 8, 9, 10, 12])
                        _chip(
                          '$n',
                          _installments == n,
                          () => setState(() => _installments = n),
                        ),
                    ],
                  ),
                ),

                //* Frecuencia
                Row(
                  children: [
                    _LabeledField(
                      label: 'Frecuencia',
                      child: Wrap(
                        runAlignment: WrapAlignment.center,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5,
                        children: [
                          for (final f in _CuotaFrequency.values)
                            _chip(
                              switch (f) {
                                _CuotaFrequency.semanal => 'Semanal',
                                _CuotaFrequency.quincenal => 'Quincenal',
                                _CuotaFrequency.mensual => 'Mensual',
                              },
                              _frequency == f,
                              () => setState(() => _frequency = f),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                //* Gestion opcional
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Gastos de gestión'),
                  subtitle: Text(
                    'Se agrega por adelantado a la inicial',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  value: _hasManagement,
                  onChanged: (value) => setState(() => _hasManagement = value),
                ),
                if (_hasManagement)
                  TextField(
                    controller: _managementController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    keyboardAppearance: Theme.of(context).brightness,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      filled: true,
                      label: Text('Gestión'),
                      prefixText: 'USD ',
                    ),
                  ),
              ],
            ),
          ),

          //* Resultado
          ..._buildResult(context, result),
        ],
      ),
    );
  }

  List<Widget> _buildResult(BuildContext context, InstallmentResult? result) {
    if (widget.rate <= 0) {
      return [
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _ResultNote(
            'Carga las tasas en "Inicio" para ver los resultados en VES.',
          ),
        ),
        const SizedBox(height: 16),
      ];
    }
    if (result == null) return const [];

    Widget row(String label, double usd, {bool highlight = false}) {
      return _ResultRow(
        label: label,
        value:
            '${formatDolarTrunc(usd)}  ·  ${formatBolivarTrunc(usd * widget.rate)}',
        highlight: highlight,
      );
    }

    return [
      const SizedBox(height: 14),
      Container(
        width: double.infinity,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.05),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            
            Text(
              'Desglose · tasa usada ${truncateRate()}',
              style: Theme.of(context).textTheme.labelSmall,
            ),

            const Divider(height: 12, thickness: 1),

            row(
              'Inicial (incluye gestión)',
              result.initial + result.managementFee,
              highlight: true,
            ),
            row('Monto financiado', result.financed),
            row('Cuota $_frequencyLabel', result.payment, highlight: true),
            const Divider(height: 12, thickness: 1),
            row('Total a pagar', result.total),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recargo', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  '+${result.surchargePercent.toStringAsFixed(2)}%',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  /// Tasa formateada (VES por unidad) sin redondear.
  String truncateRate() {
    final t = truncateTo(widget.rate, 3);
    return '${t.toStringAsFixed(3)} VES';
  }

  Widget _chip(String label, bool selected, VoidCallback onSelected) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ChoiceChip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      showCheckmark: false,
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: selected
              ? themeProvider.isDark
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: primaryColor.withValues(alpha: 0.25),
      side: BorderSide(
        color: selected
            ? primaryColor.withValues(alpha: 0.5)
            : Colors.transparent,
      ),
    );
  }
}

/// Campo con etiqueta superior.
class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        child,
      ],
    );
  }
}

/// Fila de resultado (etiqueta + valor).
class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ResultRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: highlight ? primaryColor : null,
              fontWeight: highlight ? FontWeight.bold : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Nota informativa dentro de la tarjeta.
class _ResultNote extends StatelessWidget {
  final String message;

  const _ResultNote(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
