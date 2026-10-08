/// Utilidades de cálculos financieros (cuotas y sueldos).
///
/// Funciones puras usadas por la pestaña de Herramientas.
/// Todos los montos se expresan en la misma moneda base; la conversión
/// a VES la hace el widget con la tasa seleccionada.
class FinanceCalculator {
  /// Desglose de cuotas estilo financiamiento (tipo Cashea).
  ///
  /// - [initial] = [price] * [initialPercent] / 100 (pago de inicio).
  /// - [financed] = [price] - [initial] (lo que se reparte en cuotas).
  /// - [payment] = [financed] / [installments] (cuota por periodo).
  /// - [total] = [price] + [managementFee] (la gestión se paga adelantada).
  static InstallmentResult calculateInstallments({
    required double price,
    required double initialPercent,
    required int installments,
    double managementFee = 0,
  }) {
    final initial = price * initialPercent / 100;
    final financed = price - initial;
    final total = price + managementFee;
    final payment = installments <= 0 ? 0.0 : financed / installments;
    return InstallmentResult(
      price: price,
      initial: initial,
      financed: financed,
      payment: payment,
      total: total,
      managementFee: managementFee,
    );
  }

  /// Sueldo neto a partir del bruto y las deducciones.
  ///
  /// Las deducciones = [gross] * [deductionsPercent] / 100 + [fixedDeduction].
  static SalaryResult calculateNetSalary({
    required double gross,
    required double deductionsPercent,
    double fixedDeduction = 0,
  }) {
    final deductions = gross * deductionsPercent / 100 + fixedDeduction;
    final net = gross - deductions;
    return SalaryResult(gross: gross, deductions: deductions, net: net);
  }
}

/// Resultado del cálculo de cuotas (todo en la moneda base).
class InstallmentResult {
  /// Precio original (moneda base).
  final double price;

  /// Monto de inicio pagado por adelantado.
  final double initial;

  /// Monto que se reparte en cuotas ([price] - [initial]).
  final double financed;

  /// Cuota por periodo.
  final double payment;

  /// Total a pagar ([price] + [managementFee]).
  final double total;

  /// Gastos de gestión (pagados en la inicial).
  final double managementFee;

  const InstallmentResult({
    required this.price,
    required this.initial,
    required this.financed,
    required this.payment,
    required this.total,
    required this.managementFee,
  });

  /// Recargo total respecto al precio (suele ser la gestión, en %).
  double get surchargePercent => price == 0 ? 0 : (total - price) / price * 100;
}

/// Periodos de pago de un salario dentro de un mes.
enum SalaryPeriod {
  /// Una vez al mes.
  mensual(1),

  /// Cada 15 días (2 pagos al mes).
  quincenal(2),

  /// Una vez a la semana (~4.33 pagos al mes).
  semanal(52 / 12);

  const SalaryPeriod(this.paymentsPerMonth);

  /// Cantidad de pagos en un mes.
  final double paymentsPerMonth;

  /// Etiqueta para mostrar en la UI.
  String get label => switch (this) {
    SalaryPeriod.mensual => 'mensual',
    SalaryPeriod.quincenal => 'quincenal',
    SalaryPeriod.semanal => 'semanal',
  };
}

/// Resultado del cálculo de sueldo (todo en la moneda base).
class SalaryResult {
  /// Sueldo bruto (mensual).
  final double gross;

  /// Total de deducciones (mensual).
  final double deductions;

  /// Sueldo neto (mensual).
  final double net;

  const SalaryResult({
    required this.gross,
    required this.deductions,
    required this.net,
  });

  /// Bruto prorrateado al [period].
  double grossFor(SalaryPeriod period) =>
      period.paymentsPerMonth == 0 ? 0 : gross / period.paymentsPerMonth;

  /// Neto prorrateado al [period].
  double netFor(SalaryPeriod period) =>
      period.paymentsPerMonth == 0 ? 0 : net / period.paymentsPerMonth;
}
