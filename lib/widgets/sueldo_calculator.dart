import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/core/utils/finance_calculator.dart';
import 'package:velocambio/core/utils/input_formatters.dart';
import 'package:velocambio/core/utils/truncate.dart';
import 'package:velocambio/core/utlis/format_coins.dart';
import 'package:velocambio/providers/theme_provider.dart';

/// Calculadora de sueldo / quincena.
///
/// A partir del sueldo bruto (USD o Bs), un porcentaje de deducciones y un
/// monto fijo, calcula el neto por periodo (mensual, quincenal o semanal)
/// en USD y VES usando la [rate] seleccionada.
class SueldoCalculator extends StatefulWidget {
  /// Tasa actual (VES por unidad de la moneda base).
  final double rate;

  /// Moneda de la tasa usada (para mostrarla en el aviso).
  final String baseCurrency;

  const SueldoCalculator({
    super.key,
    required this.rate,
    required this.baseCurrency,
  });

  @override
  State<SueldoCalculator> createState() => _SueldoCalculatorState();
}

class _SueldoCalculatorState extends State<SueldoCalculator> {
  final _salaryController = TextEditingController();
  final _deductionsPercentController = TextEditingController(text: '0');
  final _fixedDeductionController = TextEditingController(text: '0');

  /// `true` = el sueldo se escribe en USD; `false` = en Bs.
  bool _salaryInUsd = true;

  /// Periodo de pago seleccionado.
  SalaryPeriod _period = SalaryPeriod.mensual;

  @override
  void dispose() {
    _salaryController.dispose();
    _deductionsPercentController.dispose();
    _fixedDeductionController.dispose();
    super.dispose();
  }

  double _parsed(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  /// Sueldo bruto en USD, o 0 si no se puede convertir.
  double get _grossInUsd {
    final gross = _parsed(_salaryController);
    if (gross <= 0) return 0;
    if (_salaryInUsd) return gross;
    return widget.rate > 0 ? gross / widget.rate : 0;
  }

  SalaryResult? get _result {
    final gross = _grossInUsd;
    if (gross <= 0 || widget.rate <= 0) return null;
    return FinanceCalculator.calculateNetSalary(
      gross: gross,
      deductionsPercent: _parsed(_deductionsPercentController),
      fixedDeduction: _parsed(_fixedDeductionController),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 14,
              children: [
                //* Titulo
                Text(
                  'Sueldo / quincena',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Calcula el neto de un sueldo en dólares o bolívares',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                //* Sueldo + moneda base
                _LabeledField(
                  label: 'Sueldo bruto (mensual)',
                  child: Column(
                    spacing: 8,
                    children: [
                      TextField(
                        controller: _salaryController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        keyboardAppearance: Theme.of(context).brightness,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          filled: true,
                          prefix: Text(
                            _salaryInUsd ? 'USD ' : 'Bs ',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          label: const Text('Sueldo'),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          _chip(
                            'USD',
                            _salaryInUsd,
                            () => setState(() => _salaryInUsd = true),
                          ),
                          _chip(
                            'Bs',
                            !_salaryInUsd,
                            () => setState(() => _salaryInUsd = false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                //* Deducciones
                _LabeledField(
                  label: 'Deducciones (ISLR, paro, etc.)',
                  child: Column(
                    spacing: 8,
                    children: [
                      TextField(
                        controller: _deductionsPercentController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: const [PercentInputFormatter()],
                        keyboardAppearance: Theme.of(context).brightness,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          filled: true,
                          label: Text('Porcentaje'),
                          suffixText: '%',
                        ),
                      ),
                      TextField(
                        controller: _fixedDeductionController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        keyboardAppearance: Theme.of(context).brightness,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          filled: true,
                          label: Text('Monto fijo'),
                          prefixText: _salaryInUsd ? 'USD ' : 'Bs ',
                        ),
                      ),
                    ],
                  ),
                ),

                //* Periodo de pago
                _LabeledField(
                  label: 'Periodo para el neto',
                  child: Wrap(
                    spacing: 8,
                    children: [
                      for (final p in SalaryPeriod.values)
                        _chip(
                          p.label[0].toUpperCase() + p.label.substring(1),
                          _period == p,
                          () => setState(() => _period = p),
                        ),
                    ],
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

  List<Widget> _buildResult(BuildContext context, SalaryResult? result) {
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
              'Sueldo bruto mensual · tasa usada ${_truncateRate()}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const Divider(height: 12, thickness: 1),
            row('Bruto', result.gross),
            row('Deducciones', result.deductions),
            const Divider(height: 12, thickness: 1),
            row('Neto ${_period.label}', result.netFor(_period), highlight: true),
            if (_period != SalaryPeriod.mensual)
              row('Neto mensual', result.net, highlight: true),
          ],
        ),
      ),
    ];
  }

  /// Tasa formateada (VES por unidad) sin redondear.
  String _truncateRate() {
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
      spacing: 8,
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
