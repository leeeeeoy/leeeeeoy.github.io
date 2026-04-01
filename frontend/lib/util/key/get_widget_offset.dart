import 'package:flutter/material.dart';

double getWidgetOffset(GlobalKey key) {
  final renderBox = key.currentContext!.findRenderObject() as RenderBox;

  final offset = renderBox.localToGlobal(Offset.zero);

  return offset.dy;
}
