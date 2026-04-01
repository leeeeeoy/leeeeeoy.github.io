import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';

class BackGroundContainer extends StatelessWidget {
  const BackGroundContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = MediaQueryData.fromView(View.of(context)).size.width;
        double margin = maxWidth * 0.1;

        if (maxWidth <= AppConst.point800) {
          margin = 24.0;
        }

        if (maxWidth >= AppConst.point1920) {
          margin = maxWidth * 0.15;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: margin),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: child,
        );
      },
    );
  }
}
