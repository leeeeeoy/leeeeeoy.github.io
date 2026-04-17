import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/data/model/career_model.dart';
import 'package:leeeeeoy_portfolio/data/model/profile_model.dart';
import 'package:leeeeeoy_portfolio/data/model/project_model.dart';
import 'package:leeeeeoy_portfolio/data/model/skill_model.dart';
import 'package:leeeeeoy_portfolio/data/repository/portfolio_repository.dart';
import 'package:leeeeeoy_portfolio/di/di.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/fade_in_section.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/section_title.dart';
import 'package:leeeeeoy_portfolio/feature/home/widget/about_me_card.dart';
import 'package:leeeeeoy_portfolio/feature/home/widget/career_card.dart';
import 'package:leeeeeoy_portfolio/feature/home/widget/portfolio_info_sheet.dart';
import 'package:leeeeeoy_portfolio/feature/home/widget/project_card.dart';
import 'package:leeeeeoy_portfolio/feature/home/widget/skill_card.dart';
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
  final skillKey = GlobalKey();
  final careerKey = GlobalKey();
  final projectKey = GlobalKey();

  late final Future<ProfileModel> _profileFuture;
  late final Future<SkillsModel> _skillsFuture;
  late final Future<List<CareerModel>> _careersFuture;
  late final Future<List<ProjectModel>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    final repo = getIt<PortfolioRepository>();
    _profileFuture = repo.getProfile();
    _skillsFuture = repo.getSkills();
    _careersFuture = repo.getCareers();
    _projectsFuture = repo.getProjects();
  }

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
              onPressed: () => scrollController.animateTo(
                getWidgetOffset(aboutMeKey),
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear,
              ),
              child: const Text('About Me'),
            ),
            TextButton(
              onPressed: () => scrollController.animateTo(
                getWidgetOffset(skillKey),
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear,
              ),
              child: const Text('Skill'),
            ),
            TextButton(
              onPressed: () => scrollController.animateTo(
                getWidgetOffset(careerKey),
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear,
              ),
              child: const Text('Career'),
            ),
            TextButton(
              onPressed: () => scrollController.animateTo(
                getWidgetOffset(projectKey),
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear,
              ),
              child: const Text('Project'),
            ),
            IconButton(
              onPressed: () => showPortfolioInfoSheet(context),
              icon: const Icon(Icons.code, size: 20),
              tooltip: 'About this Portfolio',
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: SectionTitle(
            key: const ValueKey('title-about-me'),
            text: 'About Me',
            sectionKey: aboutMeKey,
          ),
        ),
        SliverToBoxAdapter(
          child: FutureBuilder<ProfileModel>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FadeInSection(
                  key: const ValueKey('about-me'),
                  child: AboutMeCard(profile: snapshot.data!),
                );
              }
              if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
              return const Center(
                child: Padding(padding: EdgeInsets.all(64), child: CircularProgressIndicator.adaptive()),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: SectionTitle(
            key: const ValueKey('title-skill'),
            text: 'Skill',
            sectionKey: skillKey,
          ),
        ),
        SliverToBoxAdapter(
          child: FutureBuilder<SkillsModel>(
            future: _skillsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FadeInSection(
                  key: const ValueKey('skill'),
                  child: SkillCard(skills: snapshot.data!),
                );
              }
              if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
              return const Center(
                child: Padding(padding: EdgeInsets.all(64), child: CircularProgressIndicator.adaptive()),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
        SliverToBoxAdapter(
          child: SectionTitle(
            key: const ValueKey('title-career'),
            text: 'Career',
            sectionKey: careerKey,
          ),
        ),
        SliverToBoxAdapter(
          child: FutureBuilder<List<CareerModel>>(
            future: _careersFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final careers = snapshot.data!;
                return Column(
                  children: [
                    for (int i = 0; i < careers.length; i++) ...[
                      FadeInSection(
                        key: ValueKey('career-$i'),
                        child: CareerCard(career: careers[i]),
                      ),
                      if (i < careers.length - 1) const SizedBox(height: 24),
                    ],
                  ],
                );
              }
              if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
              return const Center(
                child: Padding(padding: EdgeInsets.all(64), child: CircularProgressIndicator.adaptive()),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: SectionTitle(
            key: const ValueKey('title-project'),
            text: 'Project',
            sectionKey: projectKey,
          ),
        ),
        SliverToBoxAdapter(
          child: FutureBuilder<List<ProjectModel>>(
            future: _projectsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final projects = snapshot.data!;
                return Column(
                  children: [
                    for (int i = 0; i < projects.length; i++) ...[
                      FadeInSection(
                        key: ValueKey('project-$i'),
                        child: ProjectCard(project: projects[i]),
                      ),
                      if (i < projects.length - 1) const SizedBox(height: 24),
                    ],
                  ],
                );
              }
              if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
              return const Center(
                child: Padding(padding: EdgeInsets.all(64), child: CircularProgressIndicator.adaptive()),
              );
            },
          ),
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
