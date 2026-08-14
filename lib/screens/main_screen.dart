import 'package:flutter/material.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/screens/history_tab.dart';
import 'package:velocambio/screens/home_tab.dart';
import 'package:velocambio/screens/multi_items_tab.dart';
import 'package:velocambio/widgets/app_bar.dart';

/// Pantalla principal (shell).
///
/// Contiene la navegación inferior con 3 pestañas (sin usar Navigator):
/// - [HomeTab]: tasas disponibles + calculadora.
/// - [MultiItemsTab]: evaluación de varios montos a la vez.
/// - [HistoryTab]: histórico de tasas BCV con lazy loading.
///
/// Usa [IndexedStack] para conservar el estado y el scroll de cada pestaña
/// al alternar entre ellas.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Índice de la pestaña seleccionada.
  int _currentIndex = 0;

  /// Pestañas del menú inferior.
  static const List<Widget> _tabs = [HomeTab(), MultiItemsTab(), HistoryTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.transparent,
          height: 68,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.playlist_add_check_circle_outlined),
              selectedIcon: Icon(Icons.playlist_add_check_circle),
              label: 'Multi-items',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              selectedIcon: Icon(Icons.history_edu_outlined),
              label: 'Histórico',
            ),
          ],
        ),
      ),
    );
  }
}
