import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leeeeeoy_portfolio/bloc/theme_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return CupertinoSwitch(
                value: (state is ThemeDarkChecked),
                onChanged: (value) => context.read<ThemeBloc>().add(ThemeChanged(value)),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('홈페이지'),
      ),
    );
  }
}
