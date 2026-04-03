import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:leeeeeoy_portfolio/config/app_env.dart';
import 'package:leeeeeoy_portfolio/data/model/profile_model.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/app_image.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMeCard extends StatelessWidget {
  const AboutMeCard({super.key, required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final infoIcons = [
      IconRow(icon: CupertinoIcons.person, body: profile.name),
      const SizedBox(height: 16),
      if (profile.region != null) ...[
        IconRow(icon: CupertinoIcons.home, body: profile.region!),
        const SizedBox(height: 16),
      ],
      if (profile.email != null) ...[
        IconRow(
          icon: CupertinoIcons.mail,
          body: profile.email!,
          onTap: () => launchUrl(Uri.parse('mailto:${profile.email}')),
        ),
        const SizedBox(height: 16),
      ],
    ];

    final socialRow = Row(
      children: [
        if (profile.githubUrl != null)
          IconButton(
            onPressed: () => launchUrl(Uri.parse(profile.githubUrl!)),
            icon: Image.network(
              AppEnv.assetUrl('social/github.png'),
              color: Theme.of(context).colorScheme.primary,
              width: 32,
              height: 32,
            ),
          ),
        if (profile.blogUrl != null)
          IconButton(
            onPressed: () => launchUrl(Uri.parse(profile.blogUrl!)),
            icon: SvgPicture.network(
              AppEnv.assetUrl('social/velog.svg'),
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, .srcIn),
            ),
          ),
      ],
    );

    final bio = profile.bio ?? '';
    final profileImage = AppImage(
      image: NetworkImage(AppEnv.assetUrl('profile/main.jpg')),
      width: 300,
      height: 300,
      fit: .cover,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQueryData.fromView(View.of(context)).size.width;

        if (width <= AppConst.point800) {
          return Container(
            padding: const .all(32),
            child: Column(
              crossAxisAlignment: .center,
              children: [
                SizedBox(
                  width: width,
                  height: 260,
                  child: AnimatedTextKit(
                    displayFullTextOnTap: true,
                    totalRepeatCount: 1,
                    animatedTexts: [TyperAnimatedText(bio, textStyle: AppStlye.egTitleS)],
                  ),
                ),
                const SizedBox(height: 24),
                ClipRRect(borderRadius: const .all(.circular(120)), child: profileImage),
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
          padding: const .all(32),
          child: Column(
            children: [
              SizedBox(
                width: width,
                height: 240,
                child: AnimatedTextKit(
                  displayFullTextOnTap: true,
                  totalRepeatCount: 5,
                  animatedTexts: [TyperAnimatedText(bio, textStyle: AppStlye.krBodyM, textAlign: .center)],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: .center,
                children: [
                  ClipRRect(borderRadius: const .all(.circular(120)), child: profileImage),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: .start,
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
        crossAxisAlignment: .start,
        children: [
          Padding(padding: const .only(top: 6), child: Icon(icon, size: 24)),
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
