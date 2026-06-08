import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {

  const MainAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarIconBrightness: Brightness.dark
        ),
        // title: Center(
        //   child: 
        //     Text(
        //       'Calculadora', 
        //       style: TextStyle(
        //         color: primaryColor,
        //         fontWeight: FontWeight.bold),
        //         textAlign: TextAlign.center,
        //       )
        //     ),
      );
  }
}