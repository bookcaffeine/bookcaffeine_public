import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:flutter/material.dart';

SliverPersistentHeader stateBookTapBar() {
  return SliverPersistentHeader(
    pinned: true,
    delegate: _SliverAppBarDelegate(
      TabBar(
        tabs: const [
          Tab(text: '읽는 중'),
          Tab(text: '읽을 예정'),
          Tab(text: '읽기 완료'),
        ],
        labelColor: AppColors.brown500,
        unselectedLabelColor: AppColors.grey500,
        labelStyle: AppTextStyle.heading5SBold.style,
        unselectedLabelStyle: AppTextStyle.heading5SBold.style,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: AppColors.brown500,
        splashFactory: NoSplash.splashFactory,
      ),
    ),
  );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
