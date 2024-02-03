import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leeeeeoy_portfolio/feature/common/bloc/theme_bloc.dart';

class ThemeButton extends StatefulWidget {
  const ThemeButton({super.key});

  @override
  State<ThemeButton> createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<ThemeButton> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
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
    );
  }
}
