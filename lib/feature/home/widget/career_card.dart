// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leeeeeoy_portfolio/asset/assets.gen.dart';
import 'package:leeeeeoy_portfolio/data/model/career_data.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/app_image.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/background_container.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/title_mark.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:leeeeeoy_portfolio/util/extension/date_time_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class CareerCard extends StatelessWidget {
  const CareerCard({super.key, required this.careerData});

  final CareerData careerData;

  List<Widget> getCareerDetailList(CarrerDetailData carrerDetailData) => [
        ProjectTitleRow(title: carrerDetailData.title),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: DateTimeText(dateTime: carrerDetailData.startDateTime),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (carrerDetailData.playStoreLink != null)
              IconButton(
                onPressed: () => launchUrl(Uri.parse(carrerDetailData.playStoreLink!)),
                icon: Assets.social.playstore.image(width: 28, height: 28),
              ),
            if (carrerDetailData.appStoreLink != null)
              IconButton(
                onPressed: () => launchUrl(Uri.parse(carrerDetailData.appStoreLink!)),
                icon: Assets.social.appstore.image(width: 28, height: 28),
              ),
            if (carrerDetailData.downloadCount != 0) ...[
              const SizedBox(width: 16),
              Text(
                '다운로드 수: 약 ${NumberFormat.compact().format(carrerDetailData.downloadCount)}',
                style: AppStlye.krBodyXS,
              )
            ],
            if (carrerDetailData.userCount != 0) ...[
              Text(
                ', 회원 수: 약 ${NumberFormat.compact().format(carrerDetailData.userCount)}',
                style: AppStlye.krBodyXS,
              )
            ],
          ],
        ),
        const SizedBox(height: 24),
        for (final data in carrerDetailData.tasks)
          Padding(padding: EdgeInsets.only(left: 16), child: TaskRow(task: data)),
        const SizedBox(height: 24),
      ];

  @override
  Widget build(BuildContext context) {
    return BackGroundContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(120)),
                border: Border.fromBorderSide(BorderSide(color: Theme.of(context).colorScheme.primary)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(120)),
                child: AppImage(image: AssetImage(Assets.career.dozn.path)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(careerData.company, style: AppStlye.egTitleM),
          DateTimeText(dateTime: careerData.joinDateTime),
          const SizedBox(height: 24),
          Text(careerData.description, style: AppStlye.krBodyS),
          const SizedBox(height: 32),
          for (final data in careerData.detailDataList) ...getCareerDetailList(data),
        ],
      ),
    );
  }
}

class ProjectTitleRow extends StatelessWidget {
  const ProjectTitleRow({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(top: 8), child: TitleMark()),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: AppStlye.egTitleS)),
      ],
    );
  }
}

class TaskRow extends StatelessWidget {
  const TaskRow({super.key, required this.task});

  final String task;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: CircleAvatar(radius: 4, backgroundColor: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(task, style: AppStlye.krBodyS)),
      ],
    );
  }
}

class DateTimeText extends StatelessWidget {
  const DateTimeText({super.key, required this.dateTime});

  final DateTime dateTime;

  @override
  Widget build(BuildContext context) => Text(dateTime.getWaveFormat(), style: AppStlye.krBodyS);
}
