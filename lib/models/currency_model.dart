
enum Currency {
  
  usd(
    code: 'USD',
    name: 'Dólar Estadounidense',
    symbol: '\$',
    flagPath: 'assets/images/Flag_United_States.svg.png',
  ),
  ves(
    code: 'VES',
    name: 'Bolívar Digital',
    symbol: 'Bs.',
    flagPath: 'assets/images/flag_venezuela.svg.png',
  ),
  eur(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    flagPath: 'assets/images/Flag_of_Europe.svg.png',
  ),
  custom(
    code: 'Custom',
    name: 'Tasa Personalizada',
    symbol: '',
    flagPath: 'assets/images/custom_rate_icon.png',
  ),
  usdt(
    code: 'USDT',
    name: 'USDT',
    symbol: '\$',
    flagPath: 'assets/images/Flag_United_States.svg.png',
  )
  ;

  final String code;
  final String name;
  final String symbol;
  final String flagPath;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flagPath,
  });
}