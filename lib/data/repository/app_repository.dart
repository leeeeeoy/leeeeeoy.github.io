import 'package:injectable/injectable.dart';
import 'package:leeeeeoy_portfolio/asset/assets.gen.dart';
import 'package:leeeeeoy_portfolio/data/local/app_database.dart';
import 'package:leeeeeoy_portfolio/data/model/project_info_data.dart';

@LazySingleton()
final class AppRepository {
  const AppRepository({required this.appDatabase});

  final AppDatabase appDatabase;

  bool getThemeMode() => appDatabase.isDarkMode();

  Future<void> setThemeMode(bool isDark) => appDatabase.setThemeMode(isDark);

  List<ProjectInfoData> getProjectData() => [
        ProjectInfoData(
          title: 'Celebridog',
          iconPath: Assets.celdog.icon.path,
          mainScreenshotPath: Assets.celdog.screenshot1.path,
          subTitle: '반려견을 위한 숏폼 SNS',
          description: '''
We Loves Dog, Celebridog

세상에서 우리집 강아지가 제일 예뻐!
나만 알고있는 우리집 강아지의 모습을 공유해보세요.

■ 와글와글 사랑스러운 강아지로 가득한 콘텐츠 피드
나만 보기 너무 아까운 방구석 셀럽 우리집 강아지!
강아지의 가장 사랑스러운 모습을 꾹꾹 담은 영상을 올려 자랑해보세요.

■ 가장 인기있는 강아지, 셀레브리독
수많은 강아지 친구들 중 사랑스럽고, 유쾌하고, 발랄한 강아지 콘텐츠 투표해주세요.
물론, 우리집 강아지도 셀레브리독이 될 수 있어요!

■ 다양한 강아지 친구들과 소통하는 팔로우 시스템
팔로우를 통해 다른 귀여운 강아지 친구들과 소통할 수 있어요.
우리집 강아지의 친구를 찾아 팔로우하고 좋아요와 댓글로 친해져보세요.

■ 우리집 귀염둥이 영상 아카이브, 나만의 프로필
피드에 남기고 싶은 강아지의 모습을 업로드하면 프로필에 차곡차곡 쌓여요.
함께했던 모습을 생생하게 기록하고 프로필을 우리집 사랑둥이로 채워보세요.
''',
          skills: ['Flutter', 'Bloc', 'Supabase', 'GoRouter', 'Freezed'],
          features: ['영상업로드'],
          downloadCount: 10000,
          appDiscription: '',
          screenshots: [
            Assets.celdog.screenshot1.path,
            Assets.celdog.screenshot2.path,
            Assets.celdog.screenshot3.path,
            Assets.celdog.screenshot4.path,
            Assets.celdog.screenshot5.path,
            Assets.celdog.screenshot6.path,
            Assets.celdog.screenshot7.path,
          ],
        ),
        ProjectInfoData(
          title: 'Cafein',
          iconPath: Assets.cafein.icon.path,
          mainScreenshotPath: Assets.cafein.screenshot1.path,
          subTitle: '카공인을 위한 지도',
          description: '''
카페인은 약 2500개 카페들의 카공 정보와 혼잡도를 모아 유저에게 맞는 카페를 추천해 주는 지도 서비스입니다.
''',
          tasks: [
            '카카오, 애플을 이용한 소셜로그인 구현',
            '위치 권한과 지도를 통한 카페 위치 표시 및 실시간 유저 위치 표시',
            'Hive를 이용한 토큰데이터 로컬 저장 및 관리',
            '기존 GetX에서 Bloc으로 상태관리 변경을 통한 아키텍쳐 개선',
            '이미지 캐싱을 이용한 전체적인 성능 개선',
            'Freezed, Dio, Retrofit을 이용한 데이터 레이어 코드 제너레이터 적용, 불필요한 반복코드 제거',
          ],
          skills: ['Flutter', 'Bloc', 'Retrofit', 'Dio', 'Freezed'],
          features: ['카페 찾기', '지도 탐색', '사진업로드', '찜하기/짐목록', '검색필터', '리뷰달기', '신고하기'],
          githubLink: 'https://github.com/dalbong-cafein/cafein_flutter',
          downloadCount: 2500,
          userCount: 1100,
          appDiscription: '',
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
          description: '''
정보를 일일히 찾아보기 힘들었던 소비자들에게 본인이 원하는 취향을 반영하여 스튜디오에서부터 메이크업, 왁싱, 태닝까지 한 번에 찾아보고 예약할 수 있는 서비스입니다.

혼자가 아닌 팀을 이루어서 진행한 첫번째 사이드 프로젝트로, 개발 완료 이후 PlayStore에 배포한 첫번째 앱이었습니다. 처음으로 다른 사람들과 협업하면서 협업하는 경험을 기를 수 있었으며, 개발 완료 후 배포까지 하나의 결과물을 만드는데 있어서 여러 사람들과 함께 처음부터 끝까지 스스로 해볼 수 있는 좋은 경험이었습니다.
''',
          skills: ['Flutter', 'Riverpod', 'Retrofit', 'Dio', 'Freezed'],
          features: ['스튜디오 조회', '찜하기/짐목록', '검색필터', '리뷰달기', '신고하기'],
          githubLink: 'https://github.com/BPPlannerplus/bpp_plus_flutter',
          downloadCount: 100,
          tasks: [
            '카카오를 이용한 소셜로그인 구현',
            'TabView와 InfiniteScrollView를 이용해 메인 피드 구성',
            '이미지 캐싱을 이용한 전체적인 성능 개선',
            '기존 GetX에서 Riverpod로 상태관리 변경을 통한 아키텍쳐 개선',
            'Freezed, Dio, Retrofit을 이용한 데이터 레이어 코드 제너레이터 적용, 불필요한 반복코드 제거',
          ],
          appDiscription: '',
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
}
