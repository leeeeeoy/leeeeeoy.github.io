import 'package:injectable/injectable.dart';
import 'package:leeeeeoy_portfolio/asset/assets.gen.dart';
import 'package:leeeeeoy_portfolio/data/local/app_database.dart';
import 'package:leeeeeoy_portfolio/data/model/career_data.dart';
import 'package:leeeeeoy_portfolio/data/model/project_info_data.dart';

@LazySingleton()
final class AppRepository {
  const AppRepository({required this.appDatabase});

  final AppDatabase appDatabase;

  bool getThemeMode() => appDatabase.isDarkMode();

  Future<void> setThemeMode(bool isDark) => appDatabase.setThemeMode(isDark);

  List<CareerData> getCarrerData() => [
        CareerData(
          imagePath: Assets.career.seoulx.path,
          company: '서울거래',
          joinDateTime: DateTime(2024, 04),
          description: '''
개발팀

비상장 주식 거래 플랫폼 신규 앱을 개발하고 있습니다.
''',
          detailDataList: [],
        ),
        CareerData(
          imagePath: Assets.career.dozn.path,
          company: '더즌(Dozn)',
          joinDateTime: DateTime(2022, 01, 10),
          endDateTime: DateTime(2022, 04),
          description: '''
아보카도팀/사원

입주민들을 위한 서비스인 아보카도 앱과, 관리사무소 직원들을 위한 백오피스 웹페이지를 개발했습니다. 전반적인 애플리케이션 초기 개발부터 유지 보수를 담당했습니다.
''',
          detailDataList: [
            CarrerDetailData(
              title: '아보카도 모바일 앱 개발 및 유지 보수',
              startDateTime: DateTime(2022, 01),
              endDateTime: DateTime(2024, 04),
              appDescription: '',
              downloadCount: 6000,
              userCount: 3500,
              playStoreLink: 'https://play.google.com/store/apps/details?id=kr.co.dozn.avokado',
              appStoreLink:
                  'https://apps.apple.com/kr/app/%EC%95%84%EB%B3%B4%EC%B9%B4%EB%8F%84-%EB%82%B4%EC%86%90%EC%95%88%EC%9D%98-%EB%8D%94%EC%95%84%ED%8C%8C%ED%8A%B8/id1630699896',
              tasks: [
                'Bloc을 이용한 상태관리 적용',
                'Graphql을 이용한 API 통신',
                'Dynamic Link를 이용한 앱 딥링킹 구현',
                'FCM을 이용한 Push Notification',
                'Fastlane을 이용한 빌드/배포 라인 구축',
              ],
              screenshots: [
                Assets.avokadoApp.screenshot1.path,
                Assets.avokadoApp.screenshot2.path,
                Assets.avokadoApp.screenshot3.path,
                Assets.avokadoApp.screenshot4.path,
                Assets.avokadoApp.screenshot5.path,
                Assets.avokadoApp.screenshot6.path,
              ],
            ),
            CarrerDetailData(
              title: '아보카도 관리사무소 백오피스 웹 개발 및 유지 보수',
              startDateTime: DateTime(2022, 11),
              endDateTime: DateTime(2022, 04),
              appDescription: '',
              tasks: [
                'Riverpod을 이용한 상태관리 적용',
                'Graphql을 이용한 API 통신',
                'Domain Layer를 가진 3-Layer 구조 적용',
                'GoRouter를 이용한 Navigator 2.0 적용',
              ],
            ),
            CarrerDetailData(
              title: '아보카도 전자투표 모바일 웹 개발 및 유지 보수',
              startDateTime: DateTime(2023, 05),
              endDateTime: DateTime(2022, 04),
              appDescription: '',
              tasks: [
                'Bloc을 이용한 상태관리 적용',
                'GoRouter를 이용한 Navigator 2.0 적용',
                '기존 앱 컴포넌트를 재사용하여 모바일 웹으로 적용',
              ],
            ),
          ],
        ),
      ];

  List<ProjectInfoData> getProjectData() => [
        ProjectInfoData(
          title: 'Celebridog',
          iconPath: Assets.celdog.icon.path,
          mainScreenshotPath: Assets.celdog.screenshot1.path,
          subTitle: '반려견을 위한 숏폼 SNS',
          description: '''
Celebridog은 숏폼을 컨텐츠로 한 반려견 중심의 SNS입니다.

가장 최근에 진행한 사이드 프. 틱톡, 인스타그램, 유튜브와 같은 SNS를 만들어보고 싶었는데, 처음에는 기존 아이템들과 비슷하면서도 반려견 중심의 SNS를 만들기 시작했습니다.
만들면서 생각보다 반려동물에 대한 수요와 시장이 굉장히 크다는 것을 느꼈고, 같이 진행했던 팀들과 함께 더 발전시키려고 준비했었습니다. 다만 여러가지 사정으로 인해 실제 창업까지 이어지진 못했습니다.
저는 팀에 합류하여 Flutter로 앱 개발 및 일부 백엔드 개발을 서포트 했습니다. 백엔드의 경우 기존 Firebase 뿐만 아니라 PostgreSQL을 기반으로 RDBMS를 제공하는 Supabase를 사용해서 구축했는데, 기존 Firebase에서는 지원하지 않던 RDB를 클라우드 서비스로 간편하게 사용할 수 있다는 점이 상당히 매력적이었습니다. API서버가 아니라 Supabase Client를 이용해 직접 sql을 통해 데이터를 가져오는 방식이었으며, 일부 복잡한 데이터나 쿼리의 경우 rpc를 이용해서 통신했습니다.
익숙하진 않았지만 기존 앱개발에 대한 경험 뿐만 아니라 일부 백엔드 개발 경험도 의미가 있었습니다. 실제 데이터 스키마를 작성하는 것부터, 간단한 쿼리를 비롯한 rpc 작성, 그리고 API 서버가 별도로 존재하지 않기 때문에 DB에 직접 접근할 때 유의해야 할 점 등 기존 개발경험 뿐만 아니라 시야를 넓힐 수 있는 좋은 경험이었습니다. 
''',
          skills: ['Flutter', 'Bloc', 'GoRouter', 'Freezed', 'Supabase', 'Firebase', 'OneSignal'],
          features: ['영상 업로드/수정', '댓글 작성/수정', '좋아요', '투표하기', '게시글 작성/수정', '팔로우/팔로잉', '푸쉬알림'],
          tasks: [
            '구글, 애플을 이용한 소셜로그인 구현',
            '사진첩에 저장된 영상을 트림, 인코딩 및 업로드',
            'Dynamic Link를 이용한 앱 딥링킹',
            'OneSignal을 이용한 Push Notification',
            'Hive를 이용한 사용자 캐시 로컬 저장 및 관리',
            '기존 GetX에서 Bloc으로 상태관리 변경, 아키텍쳐 개선을 통한 안드로이드 OOM 발생율 약 80% 개선',
            '이미지 캐싱을 이용한 전체적인 성능 개선, 캐싱 사이즈를 조절하여 메모리 사용률 약 30% 개선',
            'Sentry, Datadog을 이용한 에러 추적 및 이벤트 모니터링',
          ],
          downloadCount: 10000,
          userCount: 1500,
          playStoreLink: 'https://play.google.com/store/apps/details?id=dog.celebri.app&hl=ko-KR',
          appStoreLink: 'https://apps.apple.com/kr/app/%EC%85%80%EB%A0%88%EB%B8%8C%EB%A6%AC%EB%8F%85/id6444745003',
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
Cafein은 약 2500개 카페들의 카공 정보와 혼잡도를 모아 유저에게 맞는 카페를 추천해 주는 지도 서비스입니다.

취업 후 평일 저녁과 주말 시간을 내어 진행한 사이드 프로젝트입니다. 팀을 이루어서 진행한 사이드 프로젝트로, 카공이라는 도메인에 대한 흥미와 지도를 이용한 앱을 만들고 싶어서 참여했었습니다.
Flutter의 특성 상 지도와 같은 Native 기능을 이용하는 것은 쉽지 않았지만, 여러가지 트러블 슈팅을 겪을 수 있는 좋은 경험이었습니다. 앱 개발자는 저를 포함 2명이었는데, 다른 한분께서 당시 비교적 최근에 개발을 시작하셔서 상대적으로 어려움을 많이 겪으셨습니다.
저도 아직 배워가는 중이었지만 제가 알고 있는 내용이나 겪었던 내용에 대해서는 협업을 통해 도움을 드렸으며, 그 과정에서 저도 이전에 알았지만 애매하게 이해가 됐던 부분들을 한번 더 이해하게 되는 좋은 과정이었습니다.
뿐만 아니라 개발 완료 이후 배포하고 팀 내에서 마케팅을 진행하면서 1000명 이상의 유저를 만들었습니다. 2022년 말에 출시 후 약 1년동안 유지하다가 서비스를 종료했습니다.
''',
          tasks: [
            '카카오, 애플을 이용한 소셜로그인 구현',
            '위치 권한과 지도를 통한 카페 위치 표시 및 실시간 유저 위치 표시',
            '실시간 위치/사용자 인터렉션 위치 변화에 따른 API debounce 처리',
            'Hive를 이용한 토큰데이터 로컬 저장 및 관리',
            '기존 GetX에서 Bloc으로 상태관리 변경을 통한 아키텍쳐 개선',
            '이미지 캐싱을 이용한 전체적인 성능 개선',
            'Freezed, Dio, Retrofit을 이용한 데이터 레이어 코드 제너레이터 적용, 불필요한 반복코드 제거',
          ],
          skills: ['Flutter', 'Bloc', 'Retrofit', 'Dio', 'Freezed'],
          features: ['카페 찾기', '지도 탐색', '사진업로드', '좋아요', '검색필터', '리뷰 작성/수정', '신고하기'],
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
BPP는 정보를 일일히 찾아보기 힘들었던 소비자들에게 본인이 원하는 취향을 반영하여 스튜디오에서부터 메이크업, 왁싱, 태닝까지 한 번에 찾아보고 예약할 수 있는 서비스입니다.

혼자가 아닌 팀을 이루어서 진행한 첫번째 사이드 프로젝트로, 개발 완료 이후 PlayStore에 배포한 첫번째 앱이었습니다. 처음으로 다른 사람들과 협업하면서 협업하는 경험을 기를 수 있었으며, 개발 완료 후 배포까지 하나의 결과물을 만드는데 있어서 여러 사람들과 함께 처음부터 끝까지 스스로 해볼 수 있는 좋은 경험이었습니다.
''',
          skills: ['Flutter', 'Riverpod', 'Retrofit', 'Dio', 'Freezed'],
          features: ['스튜디오 조회', '좋아요', '검색필터', '리뷰 작성/수정', '신고하기'],
          githubLink: 'https://github.com/BPPlannerplus/bpp_plus_flutter',
          downloadCount: 100,
          playStoreLink: 'https://play.google.com/store/apps/details?id=com.bpplanner.bpp_flutter&hl=ko-KR',
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
