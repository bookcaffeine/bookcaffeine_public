import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_icons.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/data/model/book_detail.dart';
import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/menu_item.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:bookcaffeine/util/global_widgets/empty_profile_img.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class PostListWidget extends ConsumerWidget {
  final BookDetail bookDetailInfo;
  final BookDetailViewModel bookDetailVm;

  const PostListWidget(
      {super.key, required this.bookDetailInfo, required this.bookDetailVm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                    border: Border(
                  bottom: BorderSide(color: AppColors.grey300, width: 1),
                )),
                child: Row(
                  children: [
                    Text('소감 ',
                        style: AppTextStyle.heading5SBold.style.copyWith(
                          color: AppColors.grey800,
                        )),
                    Text('(${bookDetailInfo.posts.length})',
                        style: AppTextStyle.detailRegular.style.copyWith(
                          color: AppColors.grey600,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookDetailInfo.posts.length,
          itemBuilder: (context, index) {
            final post = bookDetailInfo.posts[index];
            return Consumer(
              builder: (context, ref, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(context, '/sns_my_page',
                                arguments: {
                                  'userId': post.userId,
                                  'nickname': post.nickName,
                                  'profileImg': post.profileImg
                                });
                          },
                          child: ClipOval(
                            child: post.profileImg != null &&
                                    post.profileImg!.isNotEmpty
                                ? Image.network(
                                    post.profileImg!,
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            emptyProfileImg(post: true),
                                  )
                                : emptyProfileImg(post: true),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            post.nickName,
                            style: AppTextStyle.heading6.style.copyWith(
                              color: AppColors.grey700,
                            ),
                            maxLines: 1, // 닉네임을 한 줄로 제한
                            overflow: TextOverflow.ellipsis, // 길면 "..." 표시
                          ),
                        ),
                        PopupMenuButton(
                          icon: AppIcons.moreHorizontal,
                          iconColor: AppColors.grey700,
                          padding: EdgeInsets.zero,
                          position: PopupMenuPosition.over,
                          color: Colors.white,
                          itemBuilder: (context) {
                            final isbn = bookDetailInfo.bookInfo?.isbn ?? '';
                            return [
                              if (post.userId != GlobalUserInfo.uid)
                                menuItem('신고', context, post.postId ?? "", isbn,
                                    bookDetailVm, null),
                              if (post.userId == GlobalUserInfo.uid) ...[
                                menuItem('수정', context, post.postId ?? "", isbn,
                                    bookDetailVm, post.review),
                                menuItem('삭제', context, post.postId ?? "", isbn,
                                    bookDetailVm, null),
                              ]
                            ];
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 1), // 닉네임과 소감 사이 간격 유지
                    ExpandableText(
                      post.review ?? '',
                      expandText: '더보기',
                      collapseText: '접기',
                      maxLines: 3,
                      linkColor: AppColors.brown500,
                      style: AppTextStyle.body2Regular.style.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${post.likeCount}',
                          style: AppTextStyle.body2Regular.style.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            // 현재 좋아요 작업이 진행 중인지 확인
                            final viewModelState = ref.watch(
                                bookDetailViewModelProvider(
                                    bookDetailInfo.bookInfo?.isbn ?? ''));

                            // viewModelState가 null이거나 데이터를 로드 중일 때
                            final isLoading = viewModelState == null;

                            return GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      bookDetailVm.toggleLike(
                                          post.postId ?? "", ref);
                                    },
                              child: SvgPicture.asset(
                                post.isLiked
                                    ? 'assets/icons/icon_more_heart.svg'
                                    : 'assets/icons/icon_more.svg',
                                width: 32,
                                height: 32,
                                colorFilter: ColorFilter.mode(
                                  isLoading
                                      ? AppColors.grey400
                                      : post.isLiked
                                          ? AppColors.heart
                                          : AppColors.grey700,
                                  BlendMode.srcIn,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
