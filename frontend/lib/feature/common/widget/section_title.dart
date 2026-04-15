import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SectionTitle extends StatefulWidget {
  const SectionTitle({required super.key, required this.text, required this.sectionKey});

  final String text;
  final GlobalKey sectionKey;

  @override
  State<SectionTitle> createState() => _SectionTitleState();
}

class _SectionTitleState extends State<SectionTitle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _underlineWidth;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _underlineWidth = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_triggered && info.visibleFraction > 0.5) {
      _triggered = true;
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return VisibilityDetector(
      key: widget.key!,
      onVisibilityChanged: _onVisibilityChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          key: widget.sectionKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.text, style: AppStlye.egTitleL, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _underlineWidth,
              builder: (context, _) {
                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 3,
                    width: _underlineWidth.value * 64,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
