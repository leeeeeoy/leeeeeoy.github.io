import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leeeeeoy_portfolio/feature/common/bloc/theme_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final width = MediaQueryData.fromView(View.of(context)).size.width;
    final height = MediaQueryData.fromView(View.of(context)).size.height;

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
          actions: [
            BlocBuilder<ThemeBloc, ThemeState>(
              buildWhen: (previous, current) => current is ThemeLoaded,
              builder: (context, state) {
                ThemeMode themeMode =
                    Theme.of(context).brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark;

                if (state is ThemeLoaded) {
                  themeMode = state.themeMode;
                }

                return IconButton(
                  onPressed: () => context.read<ThemeBloc>().add(
                        ThemeChanged(
                          themeMode: switch (themeMode) {
                            ThemeMode.system => ThemeMode.dark,
                            ThemeMode.light => ThemeMode.dark,
                            ThemeMode.dark => ThemeMode.light,
                          },
                        ),
                      ),
                  icon: switch (themeMode) {
                    ThemeMode.system => const SizedBox.shrink(),
                    ThemeMode.light => const Icon(CupertinoIcons.sun_max, color: Color(0xffe5ab00)),
                    ThemeMode.dark => const Icon(CupertinoIcons.moon, color: Color(0xff00ffbf)),
                  },
                );
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: EdgeInsets.symmetric(horizontal: width * 0.2),
            child: Column(
              children: [
                Text(
                  'About Me',
                  style: GoogleFonts.dancingScript().copyWith(fontSize: 32),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(120)),
                      child: Image.network(
                        Supabase.instance.client.storage.from('profile').getPublicUrl('main.jpg'),
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const IconRow(icon: CupertinoIcons.person, body: '장요엘 (Yoel)'),
                        const SizedBox(height: 16),
                        const IconRow(icon: Icons.cake, body: '1996.06.27'),
                        const SizedBox(height: 16),
                        const IconRow(icon: CupertinoIcons.home, body: '서울특별시 강서구'),
                        const SizedBox(height: 16),
                        IconRow(
                          icon: CupertinoIcons.phone,
                          body: '010-6760-6685',
                          onTap: () => launchUrl(Uri.parse('tel:01067606685')),
                        ),
                        const SizedBox(height: 16),
                        IconRow(
                          icon: CupertinoIcons.mail,
                          body: 'hoheho18@gmail.com',
                          onTap: () => launchUrl(Uri.parse('mailto:hoheho18@gmail.com')),
                        ),
                        const SizedBox(height: 16),
                        const IconRow(icon: Icons.school, body: '한국항공대학교 (전자 및 항공전자공학 전공)'),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverList.separated(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.2),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        child: Image.network(
                          Supabase.instance.client.storage.from('app-metadata').getPublicUrl('bpp/icon.png'),
                          width: 48,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'BPP',
                        style: GoogleFonts.dancingScript().copyWith(fontSize: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 400,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          child: Image.network(
                            Supabase.instance.client.storage.from('app-metadata').getPublicUrl('bpp/screenshot4.png'),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '바디프로필 올인원 서비스, 바프플래너\n\n정보를 일일히 찾아보기 힘들었던 소비자들에게\n본인이 원하는 취향을 반영하여\n스튜디오에서부터 메이크업, 왁싱, 태닝까지 한 번에 찾아보고 예약할 수 있는 서비스 제공',
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 24),
        ),
      ],
    );
  }
}

class IconRow extends StatelessWidget {
  const IconRow({
    super.key,
    required this.icon,
    required this.body,
    this.onTap,
  });

  final IconData icon;
  final String body;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 16),
          Text(
            body,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
