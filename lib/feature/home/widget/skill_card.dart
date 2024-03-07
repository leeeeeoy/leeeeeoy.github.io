import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:leeeeeoy_portfolio/asset/assets.gen.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/background_container.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';

class SkillCard extends StatelessWidget {
  const SkillCard({super.key});

  @override
  Widget build(BuildContext context) {
    const dataIconSize = 48.0;

    final dataList = [
      (asset: Assets.skill.flutterOriginal.path, skill: 'Flutter', rate: 90.0),
      (asset: Assets.skill.dartOriginalWordmark.path, skill: 'Dart', rate: 90.0),
      (asset: Assets.skill.goOriginalWordmark.path, skill: 'Go', rate: 50.0),
      (asset: Assets.skill.kotlinOriginalWordmark.path, skill: 'Kotlin', rate: 30.0),
      (asset: Assets.skill.swiftOriginalWordmark.path, skill: 'Swift', rate: 30.0),
    ];

    final etcList = [
      Assets.skill.gitOriginalWordmark.svg(height: 48),
      Assets.skill.githubOriginalWordmark.svg(height: 48),
      Assets.skill.firebaseLineWordmark.svg(height: 72),
      Assets.skill.supabaseOriginalWordmark.svg(),
      Assets.skill.ddIconRgb.svg(height: 48),
      Assets.skill.sentryOriginalWordmark.svg(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQueryData.fromView(View.of(context)).size.width;
        double graphMaxWidth = 0.8 * width;

        if (width >= AppConst.point1920) {
          graphMaxWidth = 0.7 * width;
        }

        if (width <= AppConst.point800) {
          graphMaxWidth = width - 48;
        }

        graphMaxWidth -= (32 + dataIconSize + 24);

        return BackGroundContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(
                dataList.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SvgPicture.asset(dataList[index].asset, width: dataIconSize, height: dataIconSize),
                      const SizedBox(width: 24),
                      AnimatedGraph(maxWidth: graphMaxWidth, rate: dataList[index].rate),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ...List.generate(
                      etcList.length,
                      (index) => etcList[index],
                    )
                  ],
                ),
              ),
            ],
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
      duration: const Duration(milliseconds: 200) * 5,
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
