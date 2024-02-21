// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/asset/assets.gen.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/background_container.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/title_mark.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';

class CareerCard extends StatelessWidget {
  const CareerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final mobileTask = [
      '아파트 입주민들을 위한 아보카도 모바일 앱 신규 개발 및 유지 보수',
      '관리비 조회, 관리비 자동이체, 아파트 공지사항, 전자투표 기능 개발',
    ];
    final officeTask = [
      '아파트 관리사무소 직원들을 위한 백오피스 웹페이지 신규 개발 및 유지 보수',
      '전자투표 등록, 입주민 관리, 공지사항 관리 기능 개발',
      '기존 모바일 컴포넌트를 재사용하여 Flutter로 개발',
    ];
    final mobileWebTask = [
      '아보카도 모바일 전자투표를 위한 웹페이지 신규 개발 및 유지 보수',
      '기존 모바일 컴포넌트를 재사용하여 Flutter로 개발',
    ];

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
                child: Assets.career.dozn.image(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('더즌(Dozn)', style: AppStlye.egTitleM),
          const DateTimeText(date: '2022.01'),
          const SizedBox(height: 24),
          Text(
            '''
금융기술팀/사원

입주민들을 위한 서비스인 아보카도 앱과, 관리사무소 직원들을 위한 백오피스 웹페이지를 개발했습니다. 전반적인 애플리케이션 초기 개발부터 유지 보수를 담당하고 있습니다.
''',
          ),
          const SizedBox(height: 32),
          const ProjectTitleRow(title: '아보카도 모바일 앱 개발 및 유지 보수'),
          const DateTimeText(date: '2022.01'),
          ...mobileTask.map((e) => TaskRow(task: e)),
          const SizedBox(height: 24),
          const ProjectTitleRow(title: '아보카도 관리사무소 백오피스 웹 개발 및 유지 보수'),
          const DateTimeText(date: '2022.11'),
          ...officeTask.map((e) => TaskRow(task: e)),
          const SizedBox(height: 24),
          const ProjectTitleRow(title: '아보카도 전자투표 모바일 웹 개발 및 유지 보수'),
          const DateTimeText(date: '2023.03'),
          ...mobileWebTask.map((e) => TaskRow(task: e)),
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
        const SizedBox(width: 16),
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
  const DateTimeText({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) => Text('$date ~ ', style: AppStlye.krBodyS);
}
