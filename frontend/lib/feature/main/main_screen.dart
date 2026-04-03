import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:leeeeeoy_portfolio/feature/common/bloc/theme_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: BlocBuilder<ThemeBloc, ThemeState>(
        buildWhen: (previous, current) => current is ThemeLoaded,
        builder: (context, state) {
          ThemeMode themeMode = Theme.of(context).brightness == .light ? .light : .dark;

          if (state is ThemeLoaded) {
            themeMode = state.themeMode;
          }

          return FloatingActionButton(
            onPressed: () => context.read<ThemeBloc>().add(
              ThemeChanged(
                themeMode: switch (themeMode) {
                  .system => .dark,
                  .light => .dark,
                  .dark => .light,
                },
              ),
            ),
            child: switch (themeMode) {
              .system => const SizedBox.shrink(),
              .light => const Icon(CupertinoIcons.sun_max),
              .dark => const Icon(CupertinoIcons.moon),
            },
          );
        },
      ),
    );
  }
}
