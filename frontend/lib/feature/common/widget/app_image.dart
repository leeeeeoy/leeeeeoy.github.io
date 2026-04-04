import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.imageUrl,
    this.placeholder = const CircularProgressIndicator.adaptive(),
    this.fit,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.radius = 8,
  });

  final String imageUrl;
  final Widget placeholder;
  final BoxFit? fit;
  final double? height;
  final double? width;
  final Color? color;
  final BlendMode? colorBlendMode;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        placeholder: (context, url) => placeholder,
      ),
    );
  }
}
