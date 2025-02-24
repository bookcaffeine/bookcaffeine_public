import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_icons.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/core/filled_buttons.dart';
import 'package:bookcaffeine/ui/home/home_view_model.dart';
import 'package:bookcaffeine/ui/home/widget/books_item.dart';
import 'package:bookcaffeine/ui/home/widget/home_book_list.dart';
import 'package:bookcaffeine/ui/home/widget/read_book_record.dart';
import 'package:bookcaffeine/util/global_widgets/empty_book_cover.dart';
import 'package:bookcaffeine/util/global_widgets/empty_profile_img.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/profile_page_view_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    try {
      await ref.read(profileViewModelProvider.notifier).loadUserProfile();
      await ref.read(homeViewModelProvider.notifier).fetchData();
    } catch (e) {
      // print('유저 데이터 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final profileState = ref.watch(profileViewModelProvider);
      final homeState = ref.watch(homeViewModelProvider);

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
        ),
        body: ListView(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/mypage');
              },
              child: Center(
                child: Stack(
                  children: [
                    ClipOval(
                      child: profileState.profile != null
                          ? Image.network(
                              profileState.profile!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  emptyProfileImg(),
                            )
                          : emptyProfileImg(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: ShapeDecoration(
                            color: AppColors.brown500,
                            shape: OvalBorder(
                                side: BorderSide(
                                    width: 1, color: AppColors.brown50))),
                      ),
                    ),
                    Positioned(bottom: 5, right: 5, child: AppIcons.userWhite),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
                child: Text(
              '${profileState.nickName}',
              style: AppTextStyle.heading4M.style
                  .copyWith(color: AppColors.grey900),
            )),
            SizedBox(
              height: 32,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ReadBookRecord(
                  readBooks: homeState.monthlyReadBooks.length,
                  dateUnit: '월간 독서',
                ),
                ReadBookRecord(
                  readBooks: homeState.yearlyReadBooks.length,
                  dateUnit: '연간 독서',
                ),
                ReadBookRecord(
                  readBooks: homeState.totalReadBooks.length,
                  dateUnit: '누적 독서',
                ),
              ],
            ),
            SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(),
            ),
            SizedBox(height: 27),
            BooksItem(
              text: '읽고 있는 책',
              numbers: homeState.currentBooks.length,
              readingState: 'currentBooks',
            ),
            SizedBox(height: 15),
            homeState.currentBooks.isEmpty
                ? SizedBox(
                    height: 120,
                    child: Center(
                      child: Text(
                        '아직 등록된 책이 없습니다.\n아래 버튼을 통해 추가해 주세요.',
                        style: AppTextStyle.heading6R.style
                            .copyWith(color: AppColors.grey800),
                      ),
                    ),
                  )
                : HomeBookList(homeState: homeState),
            SizedBox(height: 32),
            BooksItem(
              text: '읽고 싶은 책',
              numbers: homeState.upcomingBooks.length,
              readingState: 'upcomingBooks',
            ),
            SizedBox(height: 15),
            homeState.upcomingBooks.isEmpty
                ? SizedBox(
                    height: 120,
                    child: Center(
                      child: Text(
                        '아직 등록된 책이 없습니다.\n아래 버튼을 통해 추가해 주세요.',
                        style: AppTextStyle.heading6R.style
                            .copyWith(color: AppColors.grey800),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: SizedBox(
                      height: 126,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: homeState.upcomingBooks.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/book_detail',
                                arguments: homeState.upcomingBooks[index],
                              );
                            },
                            child: AspectRatio(
                              aspectRatio: 2 / 3,
                              child: (homeState.upcomingBooks[index]
                                              ?.thumbnail !=
                                          null &&
                                      homeState.upcomingBooks[index]!.thumbnail!
                                          .isNotEmpty)
                                  ? Image.network(homeState
                                      .upcomingBooks[index]!.thumbnail!)
                                  : emptyBookCover(
                                      homeState.upcomingBooks[index]!.title),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.grey300,
                  width: 1,
                ),
              ),
            ),
            child: FilledButtons.h48(
              text: '책 추가하기',
              backgroundColor: AppColors.brown500,
              onPressed: () {
                FirebaseAnalytics.instance.logEvent(
                  name: "BOOK_SEARCH_EVENT",
                );
                Navigator.pushNamed(context, '/book_search');
              },
            ),
          ),
        ),
      );
    });
  }
}
