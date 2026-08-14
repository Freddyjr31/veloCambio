import 'package:flutter/material.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';

/// Botón tipo pill (píldora) para seleccionar una operación.
///
/// Se estira al ancho que le otorgue el padre (típicamente un [Expanded])
/// manteniendo una altura fija. La selección se indica por color/borde;
/// no muestra checkmark.
class OperationPillButton extends StatelessWidget {
  /// Texto visible del botón.
  final String label;

  /// Descripción mostrada al mantener presionado.
  final String tooltip;

  /// Indica si la operación está seleccionada.
  final bool selected;

  /// Callback al tocar el botón.
  final VoidCallback onTap;

  /// Altura fija del pill.
  final double height;

  const OperationPillButton({
    super.key,
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(height / 2),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? primaryColor.withAlpha(60) : surfaceColor,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: selected
                  ? primaryColor.withAlpha(80)
                  : primaryColor.withAlpha(20),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
