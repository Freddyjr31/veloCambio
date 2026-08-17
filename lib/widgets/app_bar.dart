import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:velocambio/providers/theme_provider.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  //* para guardar la version
  late Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = context.watch<ThemeProvider>();

    return AppBar(
      title: FutureBuilder<PackageInfo>(
        future: _packageInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('VeloCambio');
          } else if (snapshot.hasError) {
            return Text('VeloCambio');
          } else {
            final version = snapshot.data?.version ?? '1.0.0';
            final buildNumber = snapshot.data?.buildNumber ?? '000';
            return Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset(
                  !themeProvider.isDark
                      ? 'assets/images/app_icon_dark_mode.png'
                      : 'assets/images/app_icon-removebg_small.PNG',
                  width: size.width * 0.4,
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'v$version+$buildNumber',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            );
          }
        },
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            themeProvider.isDark
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_outlined,
          ),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: themeProvider.isDark ? 'Tema claro' : 'Tema oscuro',
        ),
      ],
    );
  }
}
