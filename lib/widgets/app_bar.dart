import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/app_icon-removebg_small.PNG',
                  width: size.width * 0.5,
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white10,
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
    );
  }
}
