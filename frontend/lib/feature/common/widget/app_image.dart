import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.image,
    this.placeholder = const CircularProgressIndicator.adaptive(),
    this.fit,
    this.width,
    this.height,
  });

  final ImageProvider image;
  final Widget placeholder;
  final BoxFit? fit;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: image,
      fit: fit,
      width: width,
      height: height,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded == true) {
          return child;
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: frame != null ? child : placeholder,
        );
      },
    );
  }
}
