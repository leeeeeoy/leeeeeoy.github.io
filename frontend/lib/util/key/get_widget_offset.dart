import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

double getWidgetOffset(GlobalKey key) {
  final renderObject = key.currentContext?.findRenderObject();
  if (renderObject == null) return 0;

  final viewport = RenderAbstractViewport.of(renderObject);
  return viewport.getOffsetToReveal(renderObject, 0.0).offset;
}
