import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:leeeeeoy_portfolio/asset/assets.gen.dart';
import 'package:leeeeeoy_portfolio/data/model/project_info_data.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/app_image.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/background_container.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({super.key, required this.projectInfoData});

  final ProjectInfoData projectInfoData;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  final pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Image.asset(widget.projectInfoData.iconPath, width: 32, height: 32),
        ),
        const SizedBox(width: 12),
        Text(widget.projectInfoData.title, style: AppStlye.egTitleM),
      ],
    );

    final infoData = [
      Row(
        children: [
          Container(width: 8, height: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Text(widget.projectInfoData.subTitle, style: AppStlye.krBodyM),
        ],
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(widget.projectInfoData.description, style: AppStlye.krBodyM),
      ),
    ];

    final featureData = [
      Row(
        children: [
          Container(width: 8, height: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Text('주요 기능', style: AppStlye.krBodyM),
        ],
      ),
      const SizedBox(height: 8),
      for (final data in widget.projectInfoData.features)
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(data, style: AppStlye.krBodyS),
        ),
    ];

    final skillData = [
      Row(
        children: [
          Container(width: 8, height: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Text('Skill', style: AppStlye.krBodyM),
        ],
      ),
      const SizedBox(height: 8),
      for (final data in widget.projectInfoData.skills)
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(data, style: AppStlye.krBodyS),
        ),
    ];

    final taskData = [
      Row(
        children: [
          Container(width: 8, height: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Text('Task', style: AppStlye.krBodyM),
        ],
      ),
      const SizedBox(height: 8),
      for (final data in widget.projectInfoData.tasks)
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(data, style: AppStlye.krBodyS),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQueryData.fromView(View.of(context)).size.width;

        if (width <= AppConst.point1080) {
          return BackGroundContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                nameRow,
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 480,
                    width: 270,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: widget.projectInfoData.screenshots.length,
                      itemBuilder: (context, index) => AppImage(
                        image: AssetImage(widget.projectInfoData.screenshots[index]),
                        placeholder: const CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: widget.projectInfoData.screenshots.length,
                    textDirection: TextDirection.ltr,
                    onDotClicked: (index) => pageController.animateToPage(index,
                        duration: const Duration(milliseconds: 500), curve: Curves.linear),
                    effect: WormEffect(
                      dotHeight: 8,
                      spacing: 8,
                      radius: 8,
                      dotWidth: 8,
                      dotColor: Theme.of(context).colorScheme.primary,
                      activeDotColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...infoData,
                const SizedBox(height: 16),
                ...taskData,
                const SizedBox(height: 16),
                ...skillData,
                const SizedBox(height: 16),
                ...featureData,
                if (widget.projectInfoData.githubLink != null) ...[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () => launchUrl(Uri.parse(widget.projectInfoData.githubLink!)),
                      icon: Assets.social.githubWhite.image(width: 32, height: 32),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return BackGroundContainer(
          child: Column(
            children: [
              nameRow,
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 360,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 720,
                          width: 360,
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: widget.projectInfoData.screenshots.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(16)),
                                child: Image.asset(
                                  widget.projectInfoData.screenshots[index],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SmoothPageIndicator(
                          controller: pageController,
                          count: widget.projectInfoData.screenshots.length,
                          textDirection: TextDirection.ltr,
                          onDotClicked: (index) => pageController.animateToPage(index,
                              duration: const Duration(milliseconds: 500), curve: Curves.linear),
                          effect: WormEffect(
                            dotHeight: 8,
                            spacing: 8,
                            radius: 8,
                            dotWidth: 8,
                            dotColor: Theme.of(context).colorScheme.primary,
                            activeDotColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 8, height: 20, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 16),
                            Text(widget.projectInfoData.subTitle, style: AppStlye.krBodyM),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(widget.projectInfoData.description, style: AppStlye.krBodyM),
                        const SizedBox(height: 24),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...taskData]),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...featureData]),
                            const SizedBox(width: 32),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...skillData]),
                          ],
                        ),
                        if (widget.projectInfoData.githubLink != null) ...[
                          const SizedBox(height: 24),
                          IconButton(
                            onPressed: () => launchUrl(Uri.parse(widget.projectInfoData.githubLink!)),
                            icon: Assets.social.githubWhite.image(width: 32, height: 32),
                          )
                        ],
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
