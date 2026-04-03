import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/config/app_env.dart';
import 'package:leeeeeoy_portfolio/data/model/project_model.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/app_image.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/background_container.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/content_mark.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/title_mark.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({super.key, required this.project});

  final ProjectModel project;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  final pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildContentList({required String title, required List<String> dataList, bool isExpanded = false}) => [
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
          crossAxisAlignment: .start,
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
    final project = widget.project;

    final nameRow = Row(
      mainAxisAlignment: .center,
      children: [
        if (project.iconUrl != null) ...[
          ClipRRect(
            borderRadius: const .all(.circular(12)),
            child: Image.network(AppEnv.assetUrl(project.iconUrl), width: 32, height: 32),
          ),
          const SizedBox(width: 12),
        ],
        Text(project.title, style: AppStlye.egTitleM),
      ],
    );

    final socialRow = Row(
      children: [
        if (project.githubUrl != null)
          IconButton(
            onPressed: () => launchUrl(Uri.parse(project.githubUrl!)),
            icon: Image.network(AppEnv.assetUrl('social/github.png'), width: 28, height: 28),
          ),
        if (project.playstoreUrl != null)
          IconButton(
            onPressed: () => launchUrl(Uri.parse(project.playstoreUrl!)),
            icon: Image.network(AppEnv.assetUrl('social/playstore.png'), width: 28, height: 28),
          ),
        if (project.appstoreUrl != null)
          IconButton(
            onPressed: () => launchUrl(Uri.parse(project.appstoreUrl!)),
            icon: Image.network(AppEnv.assetUrl('social/appstore.png'), width: 28, height: 28),
          ),
      ],
    );

    final skillNames = project.skills.map((s) => s.name).toList();
    final featureData = _buildContentList(title: 'Feature', dataList: project.features);
    final skillData = _buildContentList(title: 'Skill', dataList: skillNames);

    final screenshots = project.screenshots;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQueryData.fromView(View.of(context)).size.width;

        final pageView = PageView.builder(
          controller: pageController,
          onPageChanged: (value) => setState(() => _currentIndex = value),
          itemCount: screenshots.length,
          itemBuilder: (context, index) => Padding(
            padding: const .symmetric(horizontal: 4),
            child: AppImage(
              image: NetworkImage(AppEnv.assetUrl(screenshots[index])),
              placeholder: const CircularProgressIndicator.adaptive(),
            ),
          ),
        );

        final indicator = DotedIndicator(
          pageController: pageController,
          length: screenshots.length,
          currentIndex: _currentIndex,
        );

        if (width <= AppConst.point1080) {
          return BackGroundContainer(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                nameRow,
                const SizedBox(height: 16),
                Align(
                  alignment: .center,
                  child: SizedBox(height: 480, width: 270, child: pageView),
                ),
                const SizedBox(height: 16),
                indicator,
                const SizedBox(height: 16),
                if (project.subtitle != null) ...[
                  Row(
                    children: [
                      const TitleMark(),
                      const SizedBox(width: 16),
                      Text(project.subtitle!, style: AppStlye.krBodyM),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (project.description != null) ...[
                  Padding(
                    padding: const .only(left: 20),
                    child: Text(project.description!, style: AppStlye.krBodyS),
                  ),
                  const SizedBox(height: 16),
                ],
                ..._buildContentList(title: 'Task', dataList: project.tasks, isExpanded: true),
                const SizedBox(height: 16),
                ...skillData,
                const SizedBox(height: 16),
                ...featureData,
                const SizedBox(height: 16),
                socialRow,
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
                mainAxisAlignment: .center,
                crossAxisAlignment: .start,
                children: [
                  SizedBox(
                    width: 360,
                    child: Column(
                      children: [
                        SizedBox(height: 720, width: 360, child: pageView),
                        const SizedBox(height: 16),
                        indicator,
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        if (project.subtitle != null) ...[
                          Row(
                            children: [
                              const TitleMark(),
                              const SizedBox(width: 16),
                              Text(project.subtitle!, style: AppStlye.krBodyM),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (project.description != null) ...[
                          Text(project.description!, style: AppStlye.krBodyS),
                          const SizedBox(height: 24),
                        ],
                        const Row(
                          children: [
                            TitleMark(),
                            SizedBox(width: 16),
                            Text('Task', style: AppStlye.krBodyM),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final task in project.tasks)
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              crossAxisAlignment: .start,
                              children: [
                                const ContentMark(),
                                const SizedBox(width: 4),
                                Expanded(child: Text(task, style: AppStlye.krBodyS)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: .start,
                          children: [
                            Column(crossAxisAlignment: .start, children: [...featureData]),
                            const SizedBox(width: 32),
                            Column(crossAxisAlignment: .start, children: [...skillData]),
                          ],
                        ),
                        const SizedBox(height: 24),
                        socialRow,
                      ],
                    ),
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

class DotedIndicator extends StatelessWidget {
  const DotedIndicator({super.key, required this.pageController, required this.length, required this.currentIndex});

  final PageController pageController;
  final int length;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      children: [
        InkWell(
          onTap: () {
            if (currentIndex == 0) return;
            pageController.animateToPage(
              currentIndex - 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.linear,
            );
          },
          child: const Icon(Icons.arrow_left_rounded, size: 32),
        ),
        SmoothPageIndicator(
          controller: pageController,
          count: length,
          textDirection: .ltr,
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
            if (currentIndex == length - 1) return;
            pageController.animateToPage(
              currentIndex + 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.linear,
            );
          },
          child: const Icon(Icons.arrow_right_rounded, size: 32),
        ),
      ],
    );
  }
}
