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
                        const IconRow(icon: CupertinoIcons.person, body: '장요엘'),
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
        )
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
