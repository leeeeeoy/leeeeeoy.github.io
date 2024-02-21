import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/data/repository/app_repository.dart';
import 'package:leeeeeoy_portfolio/di/di.dart';
import 'package:leeeeeoy_portfolio/feature/home/widget/about_me_card.dart';
import 'package:leeeeeoy_portfolio/feature/home/widget/career_card.dart';
import 'package:leeeeeoy_portfolio/feature/home/widget/project_card.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:leeeeeoy_portfolio/util/key/get_widget_offset.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scrollController = ScrollController();
  final aboutMeKey = GlobalKey();
  final projectKey = GlobalKey();
  final careerKey = GlobalKey();

  final projectDataList = getIt<AppRepository>().getProjectData();
  final careerDataList = getIt<AppRepository>().getCarrerData();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverAppBar(
          pinned: false,
          floating: true,
          snap: true,
          centerTitle: false,
          title: const Text("Leeeeeoy's Portfolio", style: AppStlye.egBodyM),
          actions: [
            TextButton(
              onPressed: () => scrollController.animateTo(getWidgetOffset(aboutMeKey),
                  duration: const Duration(milliseconds: 500), curve: Curves.linear),
              child: const Text('About Me'),
            ),
            TextButton(
              onPressed: () => scrollController.animateTo(getWidgetOffset(careerKey),
                  duration: const Duration(milliseconds: 500), curve: Curves.linear),
              child: const Text('Career'),
            ),
            TextButton(
              onPressed: () => scrollController.animateTo(getWidgetOffset(projectKey),
                  duration: const Duration(milliseconds: 500), curve: Curves.linear),
              child: const Text('Project'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(key: aboutMeKey, 'About Me', style: AppStlye.egTitleL, textAlign: TextAlign.center),
          ),
        ),
        const SliverToBoxAdapter(child: AboutMeCard()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(key: careerKey, 'Career', style: AppStlye.egTitleL, textAlign: TextAlign.center),
          ),
        ),
        SliverList.separated(
          itemCount: careerDataList.length,
          itemBuilder: (context, index) => CareerCard(careerData: careerDataList[index]),
          separatorBuilder: (_, __) => const SizedBox(height: 24),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(key: projectKey, 'Project', style: AppStlye.egTitleL, textAlign: TextAlign.center),
          ),
        ),
        SliverList.separated(
          itemCount: projectDataList.length,
          itemBuilder: (context, index) => ProjectCard(projectInfoData: projectDataList[index]),
          separatorBuilder: (_, __) => const SizedBox(height: 24),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
        SliverToBoxAdapter(
          child: Container(
            height: 80,
            color: Colors.black,
            alignment: Alignment.center,
            child: const Text('© 2023. Yoel Jang. All rights reserved.', style: AppStlye.krBodyS),
          ),
        ),
      ],
    );
  }
}
