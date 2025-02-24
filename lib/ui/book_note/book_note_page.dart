import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_icons.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/menu_item.dart';
import 'package:bookcaffeine/ui/book_note/book_note_view_model.dart';
import 'package:bookcaffeine/ui/book_note/widgets/book_info.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class BookNotePage extends ConsumerWidget {
  const BookNotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 북리스트 페이지로부터 전달받은 BookNote 데이터
    final bookNoteData = ModalRoute.of(context)!.settings.arguments as BookNote;

    // menuItem에 넘겨줄 VM
    final bookDetailVm = ref
        .read(bookDetailViewModelProvider(bookNoteData.book.bookId).notifier);

    // 현재 bookNote 최신 상태 가져오기
    final state = ref.watch(bookNoteViewModelProvider);

    // bookNotes가 비어 있을 때 로딩 상태로 표시
    if (state.bookNotes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 특정 postId를 가진 BookNote 찾기
    final bookNote = state.bookNotes
        .firstWhere((note) => note.postId == bookNoteData.postId);

    // BookDetailViewModel 사용
    final bookDetailState =
        ref.watch(bookDetailViewModelProvider(bookNote.book.isbn));

    // 현재 사용자의 ID 가져오기
    final currentUserId = GlobalUserInfo.uid;

    // 현재 사용자가 작성한 이 책의 모든 포스트 찾기
    final myPosts = bookDetailState?.posts
        .where((post) => post.userId == currentUserId)
        .toList()
      ?..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신순 정렬

    return Scaffold(
      appBar: AppBar(
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          BookInfo(
            book: bookNote.book,
            createdAt: bookNote.book.datetime != null
                ? DateTime.parse(bookNote.book.datetime!)
                : DateTime.now(),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 4, 4, 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.grey300,
                ),
              ),
            ),
            child: Text(
              '작성한 소감',
              style: AppTextStyle.heading5SBold.style,
            ),
          ),
          const SizedBox(height: 16),
          if (myPosts?.isNotEmpty ?? false) ...[
            ...myPosts!
                .map((post) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              DateFormat('yyyy.MM.dd').format(post.createdAt),
                              style: AppTextStyle.heading6.style.copyWith(
                                fontSize: 14,
                                color: AppColors.grey700,
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton(
                              icon: AppIcons.moreHorizontal,
                              iconColor: AppColors.grey700,
                              padding: EdgeInsets.zero,
                              position: PopupMenuPosition.over,
                              color: Colors.white,
                              itemBuilder: (context) {
                                return [
                                  menuItem(
                                      '수정',
                                      context,
                                      post.postId ?? "",
                                      bookNoteData.book.bookId,
                                      bookDetailVm,
                                      post.review),
                                  menuItem(
                                      '삭제',
                                      context,
                                      post.postId ?? "",
                                      bookNoteData.book.bookId,
                                      bookDetailVm,
                                      null),
                                ];
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.review ?? '',
                          style: AppTextStyle.heading6R.style.copyWith(
                            color: AppColors.grey900,
                          ),
                        ),
                        const SizedBox(height: 24), // 소감 사이 간격
                      ],
                    ))
                .toList(),
          ] else
            Center(
              child: Text(
                '작성한 소감이 없습니다.',
                style: AppTextStyle.heading6R.style.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
