import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leeeeeoy_portfolio/config/app_env.dart';
import 'package:leeeeeoy_portfolio/data/model/career_model.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/app_image.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/background_container.dart';
import 'package:leeeeeoy_portfolio/feature/common/widget/title_mark.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:url_launcher/url_launcher.dart';

class CareerCard extends StatelessWidget {
  const CareerCard({super.key, required this.career});

  final CareerModel career;

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
                border: Border.fromBorderSide(
                  BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(120)),
                child: AppImage(
                  image: NetworkImage(AppEnv.assetUrl(career.logoUrl)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(career.company, style: AppStlye.egTitleM),
          _DateRangeText(start: career.joinDate, end: career.endDate),
          const SizedBox(height: 24),
          if (career.description != null)
            Text(career.description!, style: AppStlye.krBodyS),
          const SizedBox(height: 32),
          for (final detail in career.details) ..._buildDetail(context, detail),
        ],
      ),
    );
  }

  List<Widget> _buildDetail(BuildContext context, CareerDetailModel detail) => [
        _ProjectTitleRow(title: detail.title),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _DateRangeText(start: detail.startDate, end: detail.endDate),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (detail.playstoreUrl != null)
              IconButton(
                onPressed: () => launchUrl(Uri.parse(detail.playstoreUrl!)),
                icon: Image.network(
                  AppEnv.assetUrl('social/playstore.png'),
                  width: 28,
                  height: 28,
                ),
              ),
            if (detail.appstoreUrl != null)
              IconButton(
                onPressed: () => launchUrl(Uri.parse(detail.appstoreUrl!)),
                icon: Image.network(
                  AppEnv.assetUrl('social/appstore.png'),
                  width: 28,
                  height: 28,
                ),
              ),
            if (detail.downloadCount != 0) ...[
              const SizedBox(width: 16),
              Text(
                '다운로드 수: 약 ${NumberFormat.compact().format(detail.downloadCount)}',
                style: AppStlye.krBodyXS,
              ),
            ],
            if (detail.userCount != 0)
              Text(
                ', 회원 수: 약 ${NumberFormat.compact().format(detail.userCount)}',
                style: AppStlye.krBodyXS,
              ),
          ],
        ),
        const SizedBox(height: 24),
        for (final task in detail.tasks)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _TaskRow(task: task),
          ),
        const SizedBox(height: 24),
      ];
}

String _formatDate(String date) {
  final parts = date.split('-');
  if (parts.length < 2) return date;
  return '${parts[0]}.${int.tryParse(parts[1]) ?? parts[1]}';
}

class _DateRangeText extends StatelessWidget {
  const _DateRangeText({required this.start, this.end});

  final String start;
  final String? end;

  @override
  Widget build(BuildContext context) {
    final text = end == null
        ? '${_formatDate(start)} ~'
        : '${_formatDate(start)} ~ ${_formatDate(end!)}';
    return Text(text, style: AppStlye.krBodyS);
  }
}

class _ProjectTitleRow extends StatelessWidget {
  const _ProjectTitleRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(top: 8), child: TitleMark()),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: AppStlye.egTitleS)),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});

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
