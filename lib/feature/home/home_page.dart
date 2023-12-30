import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leeeeeoy_portfolio/data/repository/repository_provider.dart';
import 'package:leeeeeoy_portfolio/feature/common/provider/theme_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Row(
        children: [
          Container(
            height: height,
            width: 250,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 1,
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: OverflowBox(
                child: SizedBox(
                  width: 10.0,
                  height: 20.0,
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    minWidth: 0.0,
                    maxWidth: 200.0,
                    minHeight: 0.0,
                    maxHeight: 50.0,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.ac_unit_outlined,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                Consumer(
                  builder: (context, ref, child) {
                    final isDark = ref.watch(themeProvider);

                    return SliverAppBar(
                      floating: true,
                      pinned: false,
                      snap: true,
                      title: const Text('Leeeeeoy'),
                      actions: [
                        isDark ? const Icon(CupertinoIcons.moon) : const Icon(CupertinoIcons.sun_max),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CupertinoSwitch(
                            value: isDark,
                            onChanged: (value) {
                              ref.read(appRepositoryProvider).setThmeMode(!isDark);
                              ref.read(themeProvider.notifier).state = !isDark;
                            },
                            trackColor: Colors.black54,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const Text(
                          '텍스트 테스트 입니다.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '텍스트 테스트 입니다.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const Text(
                          '텍스트 테스트 입니다.',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          '텍스트 테스트 입니다.',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const Text(
                          '텍스트 테스트 입니다.',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          '텍스트 테스트 입니다.',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
