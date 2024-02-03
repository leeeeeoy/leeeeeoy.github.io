import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leeeeeoy_portfolio/asset/assets.gen.dart';
import 'package:leeeeeoy_portfolio/feature/home/widget/about_me_card.dart';
import 'package:leeeeeoy_portfolio/feature/home/widget/theme_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: false,
          floating: true,
          snap: true,
          title: Text(
            'Leeeeeoy',
            style: GoogleFonts.pacifico().copyWith(fontWeight: FontWeight.bold),
          ),
          actions: const [
            ThemeButton(),
            SizedBox(width: 16),
          ],
        ),
        const SliverToBoxAdapter(child: AboutMeCard()),
        // SliverList.separated(
        //   itemCount: 1,
        //   itemBuilder: (context, index) {
        //     return Container(
        //       padding: const EdgeInsets.all(24),
        //       decoration: BoxDecoration(
        //         color: Theme.of(context).colorScheme.primary,
        //         borderRadius: const BorderRadius.all(Radius.circular(24)),
        //       ),
        //       child: Column(
        //         children: [
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               ClipRRect(
        //                 borderRadius: const BorderRadius.all(Radius.circular(16)),
        //                 child: Assets.bpp.icon.image(width: 48, height: 48),
        //               ),
        //               const SizedBox(width: 16),
        //               Text(
        //                 'BPP',
        //                 style: GoogleFonts.dancingScript().copyWith(fontSize: 32),
        //               ),
        //             ],
        //           ),
        //           const SizedBox(height: 24),
        //           SizedBox(
        //             height: 400,
        //             child: Row(
        //               children: [
        //                 Assets.bpp.screenshot1.image(),
        //                 const Spacer(),
        //                 const Text(
        //                   '바디프로필 올인원 서비스, 바프플래너\n\n정보를 일일히 찾아보기 힘들었던 소비자들에게\n본인이 원하는 취향을 반영하여\n스튜디오에서부터 메이크업, 왁싱, 태닝까지 한 번에 찾아보고 예약할 수 있는 서비스 제공',
        //                   textAlign: TextAlign.end,
        //                 ),
        //               ],
        //             ),
        //           )
        //         ],
        //       ),
        //     );
        //   },
        //   separatorBuilder: (_, __) => const SizedBox(height: 24),
        // ),
      ],
    );
  }
}
