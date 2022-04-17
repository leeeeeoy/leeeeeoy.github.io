import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    Key? key,
    this.height,
    this.width,
    this.color,
    this.child,
    this.margin,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  final double? height;
  final double? width;
  final Color? color;
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        color: color ?? (Theme.of(context).primaryColor),
      ),
    );
  }
}
