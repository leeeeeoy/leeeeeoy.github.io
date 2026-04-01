import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/asset/assets.gen.dart';
import 'package:leeeeeoy_portfolio/data/model/project_info_data.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/app_image.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/background_container.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/content_mark.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/title_mark.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

int _currentIndex = 0;

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

  List<Widget> getContentWidgetList({
    required String title,
    required List<String> dataList,
    bool isExpanded = false,
  }) =>
      [
        Row(
          children: [
            const TitleMark(),
            const SizedBox(width: 16),
            Text(title, style: AppStlye.krBodyM),
          ],
        ),
        const SizedBox(height: 8),
        for (final data in dataList)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ContentMark(),
                const SizedBox(width: 4),
                if (isExpanded)
                  Expanded(child: Text(data, style: AppStlye.krBodyS))
                else
                  Text(data, style: AppStlye.krBodyS),
              ],
            ),
          ),
      ];

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
          const TitleMark(),
          const SizedBox(width: 16),
          Text(widget.projectInfoData.subTitle, style: AppStlye.krBodyM),
        ],
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(widget.projectInfoData.description, style: AppStlye.krBodyS),
      ),
    ];

    final socialDataRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (widget.projectInfoData.githubLink != null)
          IconButton(
            onPressed: () => launchUrl(Uri.parse(widget.projectInfoData.githubLink!)),
            icon: Assets.social.githubWhite.image(width: 28, height: 28),
          ),
        if (widget.projectInfoData.playStoreLink != null)
          IconButton(
            onPressed: () => launchUrl(Uri.parse(widget.projectInfoData.playStoreLink!)),
            icon: Assets.social.playstore.image(width: 28, height: 28),
          ),
        if (widget.projectInfoData.appStoreLink != null)
          IconButton(
            onPressed: () => launchUrl(Uri.parse(widget.projectInfoData.appStoreLink!)),
            icon: Assets.social.appstore.image(width: 28, height: 28),
          )
      ],
    );

    final featureData = getContentWidgetList(title: 'Feature', dataList: widget.projectInfoData.features);
    final skillData = getContentWidgetList(title: 'Skill', dataList: widget.projectInfoData.skills);

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
                      onPageChanged: (value) => _currentIndex = value,
                      itemCount: widget.projectInfoData.screenshots.length,
                      itemBuilder: (context, index) => AppImage(
                        image: AssetImage(widget.projectInfoData.screenshots[index]),
                        placeholder: const CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DotedIndicator(
                  pageController: pageController,
                  length: widget.projectInfoData.screenshots.length,
                ),
                const SizedBox(height: 16),
                ...infoData,
                const SizedBox(height: 16),
                ...getContentWidgetList(title: 'Task', dataList: widget.projectInfoData.tasks, isExpanded: true),
                const SizedBox(height: 16),
                ...skillData,
                const SizedBox(height: 16),
                ...featureData,
                const SizedBox(height: 16),
                socialDataRow,
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
                            onPageChanged: (value) => _currentIndex = value,
                            itemCount: widget.projectInfoData.screenshots.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: AppImage(
                                image: AssetImage(widget.projectInfoData.screenshots[index]),
                                placeholder: const CircularProgressIndicator.adaptive(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DotedIndicator(
                          pageController: pageController,
                          length: widget.projectInfoData.screenshots.length,
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
                            const TitleMark(),
                            const SizedBox(width: 16),
                            Text(widget.projectInfoData.subTitle, style: AppStlye.krBodyM),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(widget.projectInfoData.description, style: AppStlye.krBodyS),
                        const SizedBox(height: 24),
                        const Row(children: [TitleMark(), SizedBox(width: 16), Text('Task', style: AppStlye.krBodyM)]),
                        const SizedBox(width: 16),
                        for (final data in widget.projectInfoData.tasks)
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ContentMark(),
                                const SizedBox(width: 4),
                                Expanded(child: Text(data, style: AppStlye.krBodyS)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...featureData]),
                            const SizedBox(width: 32),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...skillData]),
                          ],
                        ),
                        const SizedBox(height: 24),
                        socialDataRow,
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

class DotedIndicator extends StatelessWidget {
  const DotedIndicator({super.key, required this.pageController, required this.length});

  final PageController pageController;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (_currentIndex == 0) {
              return;
            }

            pageController.animateToPage(_currentIndex - 1,
                duration: const Duration(milliseconds: 500), curve: Curves.linear);
          },
          child: const Icon(Icons.arrow_left_rounded, size: 32),
        ),
        SmoothPageIndicator(
          controller: pageController,
          count: length,
          textDirection: TextDirection.ltr,
          onDotClicked: (index) =>
              pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.linear),
          effect: WormEffect(
            dotHeight: 8,
            spacing: 8,
            radius: 8,
            dotWidth: 8,
            dotColor: Theme.of(context).colorScheme.primary,
            activeDotColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        InkWell(
          onTap: () {
            if (_currentIndex == length - 1) {
              return;
            }

            pageController.animateToPage(_currentIndex + 1,
                duration: const Duration(milliseconds: 500), curve: Curves.linear);
          },
          child: const Icon(Icons.arrow_right_rounded, size: 32),
        ),
      ],
    );
  }
}
