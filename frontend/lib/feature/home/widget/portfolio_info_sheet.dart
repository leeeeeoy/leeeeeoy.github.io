import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:url_launcher/url_launcher.dart';

void showPortfolioInfoSheet(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final isMobile = width <= AppConst.point800;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: const _PortfolioInfoContent()),
    ),
  );
}

class _PortfolioInfoContent extends StatelessWidget {
  const _PortfolioInfoContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Container(
            width: double.infinity,
            color: colorScheme.primaryContainer,
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
            child: Row(
              children: [
                Icon(Icons.folder_special_outlined, size: 20, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(child: Text('leeeeeoy / portfolio', style: AppStlye.egTitleS)),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // 본문
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview
                  Text(
                    'Flutter Web + Cloudflare로 구축한 개인 포트폴리오 웹사이트입니다. '
                    'Edge 서버리스 환경에서 운영되며, Frontend와 Backend가 완전히 독립된 모노레포 구조를 가집니다.',
                    style: AppStlye.krBodyS,
                  ),
                  const SizedBox(height: 28),

                  // Tech Stack
                  _SectionHeader(icon: Icons.layers_outlined, label: 'Tech Stack'),
                  const SizedBox(height: 12),
                  _StackGroup(
                    label: 'Frontend',
                    items: const ['Flutter Web', 'flutter_bloc', 'go_router', 'get_it + injectable'],
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _StackGroup(
                    label: 'Backend',
                    items: const ['Cloudflare Workers', 'Hono (TypeScript)', 'Cloudflare D1 (SQLite)', 'Cloudflare R2'],
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _StackGroup(
                    label: 'Infra / CI·CD',
                    items: const ['Cloudflare Pages', 'GitHub Actions'],
                    color: Colors.green,
                  ),
                  const SizedBox(height: 28),

                  // Architecture
                  _SectionHeader(icon: Icons.account_tree_outlined, label: 'Architecture'),
                  const SizedBox(height: 12),
                  _ArchDiagram(),
                  const SizedBox(height: 16),
                  _ArchPoint(
                    title: 'Edge Serverless',
                    body: 'Backend는 Cloudflare Workers 전용. EC2·Docker 등 서버 도입 없이 모든 API가 Edge에서 실행됩니다.',
                  ),
                  const SizedBox(height: 8),
                  _ArchPoint(
                    title: 'BFF 패턴',
                    body: 'Backend는 데이터 제공 역할만 수행. 복잡한 비즈니스 로직 없이 단순 SQL 쿼리로 JSON 응답을 반환합니다.',
                  ),
                  const SizedBox(height: 8),
                  _ArchPoint(
                    title: '선택적 CI/CD',
                    body: 'frontend/ 변경 시 Pages만, backend/ 변경 시 Workers만 배포. 변경 영역 감지 후 독립 배포합니다.',
                  ),
                  const SizedBox(height: 28),

                  // GitHub 링크
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(Uri.parse('https://github.com/leeeeeoy/leeeeeoy_portfolio')),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('View on GitHub', style: AppStlye.egBodyM),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(label, style: AppStlye.krBodyM),
      ],
    );
  }
}

class _StackGroup extends StatelessWidget {
  const _StackGroup({required this.label, required this.items, required this.color});

  final String label;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: AppStlye.krBodyXS.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(item, style: AppStlye.krBodyXS),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ArchDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_DiagramBox(label: 'Flutter Web', sublabel: 'Cloudflare Pages', color: Colors.blue)],
          ),
          const SizedBox(height: 8),
          Icon(Icons.arrow_downward, size: 16, color: colorScheme.outline),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_DiagramBox(label: 'Hono API', sublabel: 'Cloudflare Workers', color: Colors.orange)],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_downward, size: 16, color: colorScheme.outline),
              const SizedBox(width: 48),
              Icon(Icons.arrow_downward, size: 16, color: colorScheme.outline),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DiagramBox(label: 'D1', sublabel: 'SQLite', color: Colors.green),
              const SizedBox(width: 16),
              _DiagramBox(label: 'R2', sublabel: 'Object Storage', color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiagramBox extends StatelessWidget {
  const _DiagramBox({required this.label, required this.sublabel, required this.color});

  final String label;
  final String sublabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: AppStlye.egBodyM.copyWith(fontWeight: FontWeight.w600)),
          Text(sublabel, style: AppStlye.krBodyXS.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ArchPoint extends StatelessWidget {
  const _ArchPoint({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(Icons.check_circle_outline, size: 14, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppStlye.krBodyS.copyWith(color: Theme.of(context).colorScheme.onSurface),
              children: [
                TextSpan(
                  text: '$title  ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: body),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
