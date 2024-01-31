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
      appBar: AppBar(
        title: const Text('Leeeeeoy'),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            buildWhen: (previous, current) => current is ThemeLoaded,
            builder: (context, state) {
              ThemeMode themeMode = Theme.of(context).brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark;

              if (state is ThemeLoaded) {
                themeMode = state.themeMode;
              }

              return IconButton(
                onPressed: () => context.read<ThemeBloc>().add(
                      ThemeChanged(
                        themeMode: switch (themeMode) {
                          ThemeMode.system => ThemeMode.dark,
                          ThemeMode.light => ThemeMode.dark,
                          ThemeMode.dark => ThemeMode.light,
                        },
                      ),
                    ),
                icon: switch (themeMode) {
                  ThemeMode.system => const SizedBox.shrink(),
                  ThemeMode.light => const Icon(CupertinoIcons.sun_max, color: Color(0xffe5ab00)),
                  ThemeMode.dark => const Icon(CupertinoIcons.moon, color: Color(0xff00ffbf)),
                },
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(CupertinoIcons.chat_bubble_text),
      ),
    );
  }
}
