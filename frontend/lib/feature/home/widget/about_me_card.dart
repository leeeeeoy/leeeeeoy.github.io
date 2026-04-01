import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/asset/assets.gen.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/app_image.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMeCard extends StatelessWidget {
  const AboutMeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final infoIcons = [
      const IconRow(icon: CupertinoIcons.person, body: '장요엘 (Yoel)'),
      const SizedBox(height: 16),
      const IconRow(icon: CupertinoIcons.home, body: '서울특별시 강서구'),
      const SizedBox(height: 16),
      IconRow(
        icon: CupertinoIcons.mail,
        body: 'hoheho18@gmail.com',
        onTap: () => launchUrl(Uri.parse('mailto:hoheho18@gmail.com')),
      ),
      const SizedBox(height: 16),
    ];

    final socialRow = Row(
      children: [
        IconButton(
          onPressed: () => launchUrl(Uri.parse('https://github.com/leeeeeoy')),
          icon: Assets.social.github.image(color: Theme.of(context).colorScheme.primary, width: 32, height: 32),
        ),
        IconButton(
          onPressed: () => launchUrl(Uri.parse('https://velog.io/@leeeeeoy/posts')),
          icon: Assets.social.velog.svg(
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQueryData.fromView(View.of(context)).size.width;

        if (width <= AppConst.point800) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: width,
                  height: 260,
                  child: AnimatedTextKit(
                    displayFullTextOnTap: true,
                    totalRepeatCount: 1,
                    animatedTexts: [
                      TyperAnimatedText(
                        "안녕하세요, 5년차 크로스 플랫폼(Flutter) 개발자입니다.\n\n동료들과 협업하며 혼자서는 해낼 수 없는 가치 있는 일들에 관심이 많은 개발자입니다. 읽기 쉬운 코드와 올바른 커뮤니케이션 방법에 대해 고민하며, 협업과 존중에 진심인 개발자입니다.\nFlutter 기반 모바일 앱을 4년 이상 개발하며, 초기 서비스 환경에서 앱 아키텍처 설계부터 배포·운영까지 End-to-End로 책임진 경험이 있습니다.",
                        textStyle: AppStlye.egTitleS,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(120)),
                  child: AppImage(
                    image: AssetImage(Assets.profile.main.path),
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                ...infoIcons,
                const IconRow(icon: Icons.school, body: '한국항공대학교 (전자 및 항공전자공학 전공)', isExpanded: true),
                const SizedBox(height: 32),
                socialRow,
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              SizedBox(
                width: width,
                height: 240,
                child: AnimatedTextKit(
                  displayFullTextOnTap: true,
                  totalRepeatCount: 5,
                  animatedTexts: [
                    TyperAnimatedText(
                      "안녕하세요, 5년차 크로스 플랫폼(Flutter) 개발자입니다.\n\n동료들과 협업하며 혼자서는 해낼 수 없는 가치 있는 일들에 관심이 많은 개발자입니다. 읽기 쉬운 코드와 올바른 커뮤니케이션 방법에 대해 고민하며, 협업과 존중에 진심인 개발자입니다.\nFlutter 기반 모바일 앱을 4년 이상 개발하며, 초기 서비스 환경에서 앱 아키텍처 설계부터 배포·운영까지 End-to-End로 책임진 경험이 있습니다.",
                      textStyle: AppStlye.krBodyM,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(120)),
                    child: AppImage(
                      image: AssetImage(Assets.profile.main.path),
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...infoIcons,
                      const IconRow(icon: Icons.school, body: '한국항공대학교 (전자 및 항공전자공학 전공)'),
                      const SizedBox(height: 32),
                      socialRow,
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class IconRow extends StatelessWidget {
  const IconRow({super.key, required this.icon, required this.body, this.onTap, this.isExpanded = false});

  final IconData icon;
  final String body;
  final void Function()? onTap;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 6), child: Icon(icon, size: 24)),
          const SizedBox(width: 16),
          if (isExpanded)
            Expanded(child: Text(body, style: AppStlye.krBodyM, maxLines: 2))
          else
            Text(body, style: AppStlye.krBodyM, maxLines: 2),
        ],
      ),
    );
  }
}
