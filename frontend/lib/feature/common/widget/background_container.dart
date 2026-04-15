import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';

class BackGroundContainer extends StatefulWidget {
  const BackGroundContainer({super.key, required this.child});

  final Widget child;

  @override
  State<BackGroundContainer> createState() => _BackGroundContainerState();
}

class _BackGroundContainerState extends State<BackGroundContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final Animation<double> _hoverAnim;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverAnim = CurvedAnimation(parent: _hoverController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final containerColor = Theme.of(context).colorScheme.primaryContainer;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = MediaQueryData.fromView(View.of(context)).size.width;
        double margin = maxWidth * 0.1;

        if (maxWidth <= AppConst.point800) margin = 24.0;
        if (maxWidth >= AppConst.point1920) margin = maxWidth * 0.15;

        return MouseRegion(
          onEnter: (_) => _hoverController.forward(),
          onExit: (_) => _hoverController.reverse(),
          child: AnimatedBuilder(
            animation: _hoverAnim,
            // child를 분리해 애니메이션 중 자식 트리 리빌드 방지
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: widget.child,
            ),
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: margin),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  color: containerColor,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: _hoverAnim.value * 16,
                      spreadRadius: 0,
                      color: primaryColor.withValues(alpha: _hoverAnim.value * 0.2),
                      offset: Offset(0, _hoverAnim.value * 4),
                    ),
                  ],
                ),
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}
