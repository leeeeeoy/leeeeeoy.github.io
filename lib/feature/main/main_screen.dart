import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            onPressed: () {},
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
