import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.image,
    required this.placeholder,
    this.fit,
  });

  final ImageProvider image;
  final Widget placeholder;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: image,
      fit: fit,
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
