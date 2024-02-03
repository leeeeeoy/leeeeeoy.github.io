import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/data/model/project_info_data.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.projectInfoData});

  final ProjectInfoData projectInfoData;

  @override
  Widget build(BuildContext context) {
    final nameRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Image.asset(projectInfoData.iconPath, width: 32, height: 32),
        ),
        const SizedBox(width: 12),
        Text(projectInfoData.title, style: AppStlye.egTitleM),
      ],
    );

    final infoData = [
      Row(
        children: [
          Container(width: 8, height: 20, color: Theme.of(context).colorScheme.primaryContainer),
          const SizedBox(width: 16),
          Text(projectInfoData.subTitle, style: AppStlye.krBodyM),
        ],
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(projectInfoData.description, style: AppStlye.krBodyM),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Container(width: 8, height: 20, color: Theme.of(context).colorScheme.primaryContainer),
          const SizedBox(width: 16),
          Text('주요 기능', style: AppStlye.krBodyM),
        ],
      ),
      const SizedBox(height: 8),
      for (final data in projectInfoData.features)
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(data, style: AppStlye.krBodyS),
        ),
      const SizedBox(height: 16),
      Row(
        children: [
          Container(width: 8, height: 20, color: Theme.of(context).colorScheme.primaryContainer),
          const SizedBox(width: 16),
          Text('Skill', style: AppStlye.krBodyM),
        ],
      ),
      const SizedBox(height: 8),
      for (final data in projectInfoData.skills)
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(data, style: AppStlye.krBodyS),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQueryData.fromView(View.of(context)).size.width;

        if (width <= AppConst.point1080) {
          return Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                nameRow,
                const SizedBox(height: 16),
                ...infoData,
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(24),
          margin: EdgeInsets.symmetric(horizontal: width * 0.1),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          child: Column(
            children: [
              nameRow,
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: Image.asset(
                      projectInfoData.mainScreenshotPath,
                      width: 400,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [...infoData],
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
