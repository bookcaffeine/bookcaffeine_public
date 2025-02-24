import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/ui/mypage/widget/tab_bar_view.dart';
import 'package:bookcaffeine/ui/profile/profile_page.dart';
import 'package:bookcaffeine/ui/mypage/widget/state_book_tab_bar.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:bookcaffeine/ui/profile/profile_page_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    final userId = ref.read(userRepositoryProvider).getCurrentUserId();
    if (userId != null) {
      await ref.read(profileViewModelProvider.notifier).loadUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileViewModelProvider);

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                scrolledUnderElevation: 0,
                title: Text('마이페이지'),
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
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/setting');
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/settings.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.grey800,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
                floating: true,
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: "MY_POST_EVENT",
                    );
                    Navigator.pushNamed(
                      context,
                      '/my_post',
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    height: 258,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: AssetImage('assets/images/my_review_photo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '내가 쓴 소감',
                        style: AppTextStyle.heading5R.style.copyWith(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: "MY_LIKE_EVENT",
                    );
                    Navigator.pushNamed(
                      context,
                      '/my_like',
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.only(bottom: 24, left: 20, right: 20),
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        width: 1,
                        color: AppColors.brown400,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/icon_more.svg',
                          color: AppColors.brown500,
                        ),
                        Text(
                          '좋아요한 소감',
                          style: AppTextStyle.heading5R.style.copyWith(
                            color: AppColors.brown500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              stateBookTapBar(),
            ];
          },
          body: tabBarView(GlobalUserInfo.uid!),
        ),
      ),
    );
  }
}
