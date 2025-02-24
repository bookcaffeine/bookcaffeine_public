import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/ui/home/widget/read_book_record.dart';
import 'package:bookcaffeine/ui/mypage/widget/state_book_tab_bar.dart';
import 'package:bookcaffeine/ui/mypage/widget/tab_bar_view.dart';
import 'package:bookcaffeine/ui/sns_my_page/sns_my_page_view_model.dart';
import 'package:bookcaffeine/ui/sns_my_page/widgets/divider.dart';
import 'package:bookcaffeine/util/global_widgets/empty_profile_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class SnsMyPage extends ConsumerStatefulWidget {
  const SnsMyPage({super.key});

  @override
  ConsumerState<SnsMyPage> createState() => _SnsMyPage();
}

class _SnsMyPage extends ConsumerState<SnsMyPage> {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final userId = arguments?['userId'] as String;
    final nickname = arguments?['nickname'] as String;
    final profileImg = arguments?['profileImg'] as String?;

    final snsMyPageState = ref.watch(snsMyPageViewModelProvider(userId));

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: Text(nickname),
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/chevron-left.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.grey800,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                  child: SizedBox(
                height: 30,
              )),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: profileImg != null && profileImg.isNotEmpty
                          ? Image.network(
                              profileImg,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  emptyProfileImg(),
                            )
                          : emptyProfileImg(),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    divider(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ReadBookRecord(
                          readBooks: snsMyPageState.monthlyReadBooks.length,
                          dateUnit: '월간 독서',
                        ),
                        ReadBookRecord(
                          readBooks: snsMyPageState.yearlyReadBooks.length,
                          dateUnit: '연간 독서',
                        ),
                        ReadBookRecord(
                          readBooks: snsMyPageState.totalReadBooks.length,
                          dateUnit: '누적 독서',
                        ),
                      ],
                    ),
                    divider(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              stateBookTapBar()
            ];
          },
          body: tabBarView(userId),
        ),
      ),
    );
  }
}
