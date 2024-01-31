import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MainScreen AppBar'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = Supabase.instance.client.storage.from('app-metadata').getPublicUrl('bpp/bpp_icon.png');
              debugPrint(result);
            },
            icon: const Icon(CupertinoIcons.moon),
          ),
        ],
      ),
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigationShell.goBranch(1),
        child: const Icon(Icons.ad_units),
      ),
    );
  }
}
