import 'dart:async';

import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/background_container.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';

class SkillCard extends StatelessWidget {
  const SkillCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dataList = [
      (skill: 'Flutter', rate: 90.0),
      (skill: 'Dart', rate: 90.0),
      (skill: 'Go', rate: 50.0),
      (skill: 'Kotlin', rate: 30.0),
      (skill: 'Swift', rate: 30.0),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQueryData.fromView(View.of(context)).size.width;
        double graphMaxWidth;

        if (width >= AppConst.point1920) {
          graphMaxWidth = 1200;
        } else if (width >= AppConst.point440) {
          graphMaxWidth = width - 200;
        } else {
          graphMaxWidth = 200;
        }
        return BackGroundContainer(
          child: Column(
            children: List.generate(
              dataList.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(dataList[index].skill, style: AppStlye.krBodyM),
                    const SizedBox(width: 12),
                    AnimatedGraph(maxWidth: graphMaxWidth, rate: dataList[index].rate),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedGraph extends StatefulWidget {
  const AnimatedGraph({super.key, required this.maxWidth, required this.rate});

  final double rate;
  final double maxWidth;

  @override
  State<AnimatedGraph> createState() => _AnimatedGraphState();
}

class _AnimatedGraphState extends State<AnimatedGraph> {
  bool start = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer(Duration.zero, () => setState(() => start = true));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double rightPadding = 0.0;

    if (start) {
      rightPadding = ((100 - widget.rate) / 100) * widget.maxWidth;
    } else {
      rightPadding = widget.maxWidth;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500) * 5,
      height: 32,
      width: widget.maxWidth,
      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
      padding: EdgeInsets.only(right: rightPadding),
      child: Container(
        height: 32,
        alignment: Alignment.centerRight,
        width: widget.maxWidth,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.onPrimary,
          ]),
        ),
        child: Text('${widget.rate}%', style: AppStlye.krBodyS),
      ),
    );
  }
}
