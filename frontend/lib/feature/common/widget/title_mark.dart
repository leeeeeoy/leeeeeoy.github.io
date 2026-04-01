import 'package:flutter/material.dart';

class TitleMark extends StatelessWidget {
  const TitleMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 16,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
