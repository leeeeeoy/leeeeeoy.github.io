import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:leeeeeoy_portfolio/config/app_env.dart';
import 'package:leeeeeoy_portfolio/data/model/skill_model.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/background_container.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';

class SkillCard extends StatelessWidget {
  const SkillCard({super.key, required this.skills});

  final SkillsModel skills;

  @override
  Widget build(BuildContext context) {
    const iconSize = 48.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQueryData.fromView(View.of(context)).size.width;
        double graphMaxWidth = 0.8 * width;

        if (width >= AppConst.point1920) graphMaxWidth = 0.7 * width;
        if (width <= AppConst.point800) graphMaxWidth = width - 48;
        graphMaxWidth -= (32 + iconSize + 24);

        return BackGroundContainer(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              // Language — proficiency graph
              ...skills.language.map(
                (skill) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      _SkillIcon(iconUrl: skill.iconUrl, size: iconSize),
                      const SizedBox(width: 24),
                      AnimatedGraph(maxWidth: graphMaxWidth, rate: (skill.proficiency ?? 0).toDouble()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Tool + Platform — icon grid
              Padding(
                padding: const .all(16),
                child: Wrap(
                  runAlignment: .center,
                  crossAxisAlignment: .center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ...skills.tool.map((s) => _SkillIcon(iconUrl: s.iconUrl, size: iconSize)),
                    ...skills.platform.map((s) => _SkillIcon(iconUrl: s.iconUrl, size: iconSize)),
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

class _SkillIcon extends StatelessWidget {
  const _SkillIcon({required this.iconUrl, required this.size});

  final String? iconUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = AppEnv.assetUrl(iconUrl);
    if (url.isEmpty) return SizedBox(width: size, height: size);
    if (url.endsWith('.svg')) {
      return SvgPicture.network(url, width: size, height: size);
    }
    return Image.network(url, width: size, height: size);
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
    final rightPadding = start ? ((100 - widget.rate) / 100) * widget.maxWidth : widget.maxWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200) * 5,
      height: 32,
      width: widget.maxWidth,
      decoration: const BoxDecoration(borderRadius: .all(.circular(20))),
      padding: .only(right: rightPadding),
      child: Container(
        height: 32,
        alignment: .centerRight,
        width: widget.maxWidth,
        padding: const .only(right: 16),
        decoration: BoxDecoration(
          borderRadius: const .all(.circular(20)),
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.onPrimary],
          ),
        ),
        child: Text('${widget.rate.toInt()}%', style: AppStlye.krBodyS),
      ),
    );
  }
}
