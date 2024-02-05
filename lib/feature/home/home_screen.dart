import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leeeeeoy_portfolio/asset/assets.gen.dart';
import 'package:leeeeeoy_portfolio/data/model/project_info_data.dart';
import 'package:leeeeeoy_portfolio/feature/home/widget/about_me_card.dart';
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

  final projectDataList = [
    ProjectInfoData(
      title: 'Cafein',
      iconPath: Assets.cafein.icon.path,
      mainScreenshotPath: Assets.cafein.screenshot1.path,
      subTitle: '카공인을 위한 지도',
      description: '''
카페인은 약 2500개 카페들의 카공 정보와 혼잡도를 모아
나에게 맞는 카페를 추천해 주는 지도 서비스에요.
- 등록된 카페 4500곳
- 리뷰 약 2500개
지금 내 위치를 기준으로 근처의 카공 만족도가 높은 카페를 쉽게 확인할 수 있어요.
콘센트, 와이파이, 테이블 높이와 넓이, 화장실, 그리고 혼잡도까지!
카공에 필요한 모든 정보를 만나보세요.
카페 이름, 지하철역, 지역 등으로 카페를 쉽게 찾을 수 있어요.
헷갈리기 쉬운 영업시간과 매번 달라지는 혼잡도 정보는 ‘나의 카페’에서 빠르게 확인할 수 있어요.
자주 가는 카페나 나중에 가고 싶은 카페는 ‘나의 카페’에 저장해 보세요!
''',
      skills: ['Flutter', 'Bloc', 'Retrofit', 'Dio', 'Freezed'],
      features: ['카페 찾기', '지도 탐색', '사진업로드', '찜하기/짐목록', '검색필터', '리뷰달기', '신고하기'],
      githubLink: 'https://github.com/dalbong-cafein/cafein_flutter',
      downloadCount: 2500,
      screenshots: [
        Assets.cafein.screenshot1.path,
        Assets.cafein.screenshot2.path,
        Assets.cafein.screenshot3.path,
        Assets.cafein.screenshot4.path,
        Assets.cafein.screenshot5.path,
      ],
    ),
    ProjectInfoData(
      title: 'BPP',
      iconPath: Assets.bpp.icon.path,
      mainScreenshotPath: Assets.bpp.screenshot1.path,
      subTitle: '바디프로필 올인원 서비스',
      description: '정보를 일일히 찾아보기 힘들었던 소비자들에게\n본인이 원하는 취향을 반영하여\n스튜디오에서부터 메이크업, 왁싱, 태닝까지 한 번에 찾아보고 예약할 수 있는 서비스 제공',
      skills: ['Flutter', 'Riverpod', 'Retrofit', 'Dio', 'Freezed'],
      features: ['스튜디오 조회', '찜하기/짐목록', '검색필터', '리뷰달기', '신고하기'],
      githubLink: 'https://github.com/BPPlannerplus/bpp_plus_flutter',
      downloadCount: 100,
      screenshots: [
        Assets.bpp.screenshot1.path,
        Assets.bpp.screenshot2.path,
        Assets.bpp.screenshot3.path,
        Assets.bpp.screenshot4.path,
        Assets.bpp.screenshot5.path,
        Assets.bpp.screenshot6.path,
      ],
    ),
  ];

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
          title: Text("Leeeeeoy's Portfolio", style: GoogleFonts.pacifico().copyWith()),
          actions: [
            TextButton(
              onPressed: () => scrollController.animateTo(getWidgetOffset(aboutMeKey),
                  duration: const Duration(milliseconds: 500), curve: Curves.linear),
              child: const Text('About Me'),
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
            child: Text(key: projectKey, 'Project', style: AppStlye.egTitleL, textAlign: TextAlign.center),
          ),
        ),
        SliverList.separated(
          itemCount: projectDataList.length,
          itemBuilder: (context, index) => ProjectCard(projectInfoData: projectDataList[index]),
          separatorBuilder: (_, __) => const SizedBox(height: 24),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
