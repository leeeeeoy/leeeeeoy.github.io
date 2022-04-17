import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leeeeeoy_portfolio/bloc/theme_bloc.dart';
import 'package:leeeeeoy_portfolio/widget/card/custom_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
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
      body: Column(
        children: [
          CustomContainer(
            height: 100,
            width: 100,
            child: Center(
              child: Text('Container'),
            ),
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: Center(
              child: Text('SizedBox'),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Button enable'),
          ),
          ElevatedButton(
            onPressed: null,
            child: Text('Button disable'),
          ),
        ],
      ),
    );
  }
}
