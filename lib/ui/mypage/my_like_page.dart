import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/data/model/book_detail.dart';
import 'package:bookcaffeine/data/model/post.dart';
import 'package:bookcaffeine/ui/mypage/my_like_view_model.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:bookcaffeine/util/global_widgets/empty_profile_img.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:bookcaffeine/core/app_icons.dart';
import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';

class MyLikePage extends ConsumerWidget {
  const MyLikePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myLikeViewModelProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context, state, ref),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      title: const Text('내가 좋아요한 소감'),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: SvgPicture.asset(
          'assets/icons/chevron-left.svg',
          width: 24,
          height: 24,
          colorFilter:
              const ColorFilter.mode(AppColors.grey800, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyLikeState state, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text(state.error!));
    }
    if (state.likedBooks.isEmpty) {
      return const Center(child: Text('좋아요한 소감이 없습니다.'));
    }

    // 각 책의 소감들을 최신순으로 정렬
    final sortedBooks = state.likedBooks.map((bookDetail) {
      final sortedPosts = [...bookDetail.posts]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return MapEntry(bookDetail, sortedPosts);
    }).toList();

    // 책들을 가장 최근 소감 기준으로 정렬
    sortedBooks.sort(
        (a, b) => b.value.first.createdAt.compareTo(a.value.first.createdAt));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: sortedBooks.length,
        itemBuilder: (context, index) {
          final bookDetail = sortedBooks[index].key;
          final posts = sortedBooks[index].value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index != 0) const SizedBox(height: 24),
              _buildBookHeader(bookDetail),
              const SizedBox(height: 12),
              ...posts.map((post) => PostItem(
                    post: post,
                    bookDetail: bookDetail,
                    ref: ref,
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookHeader(BookDetail bookDetail) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: AppColors.grey300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: bookDetail.bookInfo?.title ?? '',
                    style: AppTextStyle.heading5SBold.style.copyWith(
                      color: AppColors.grey800,
                    ),
                  ),
                  TextSpan(
                    text: ' (${bookDetail.bookInfo?.authors.join(", ") ?? ''})',
                    style: AppTextStyle.detailRegular.style.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostItem extends StatelessWidget {
  final Post post;
  final BookDetail bookDetail;
  final WidgetRef ref;

  const PostItem({
    super.key,
    required this.post,
    required this.bookDetail,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPostHeader(context),
        const SizedBox(height: 6),
        _buildPostContent(),
        const SizedBox(height: 6),
        Divider(color: AppColors.grey200),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return Row(
      children: [
        _buildUserProfile(context),
        const SizedBox(width: 8),
        Text(post.nickName, style: AppTextStyle.heading6.style),
        const Spacer(),
        Consumer(
          builder: (context, ref, child) {
            final isLoading = ref.watch(myLikeViewModelProvider).isLoading;

            return Row(
              children: [
                Text('${post.likeCount}', style: AppTextStyle.heading6.style),
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () async {
                          await ref
                              .read(myLikeViewModelProvider.notifier)
                              .unlikePost(post.postId ?? "");
                        },
                  child: SvgPicture.asset(
                    'assets/icons/icon_more_heart.svg',
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      isLoading ? AppColors.grey400 : AppColors.heart,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToUserProfile(context),
      child: ClipOval(
        child: post.profileImg != null && post.profileImg!.isNotEmpty
            ? Image.network(
                post.profileImg!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => emptyProfileImg(post: true),
              )
            : emptyProfileImg(post: true),
      ),
    );
  }

  Widget _buildPostContent() {
    return ExpandableText(
      post.review ?? '',
      expandText: '더보기',
      collapseText: '접기',
      maxLines: 3,
      linkColor: AppColors.brown500,
      style: AppTextStyle.body2Regular.style.copyWith(
        color: AppColors.grey900,
      ),
    );
  }

  void _navigateToUserProfile(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/sns_my_page',
      arguments: {
        'userId': post.userId,
        'nickname': post.nickName,
        'profileImg': post.profileImg
      },
    );
  }
}
