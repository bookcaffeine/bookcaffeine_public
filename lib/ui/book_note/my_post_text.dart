import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_icons.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';
import 'package:bookcaffeine/ui/book_note/book_note_view_model.dart';
import 'package:bookcaffeine/ui/profile/profile_page_view_model.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MyPostText extends ConsumerWidget {
  const MyPostText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookNoteViewModelProvider);
    final profileState = ref.watch(profileViewModelProvider);

    // 책별로 소감 그룹화
    Map<String, List<BookNote>> groupedNotes = {};
    for (var note in state.bookNotes) {
      final bookId = note.book.bookId;
      if (!groupedNotes.containsKey(bookId)) {
        groupedNotes[bookId] = [];
      }
      groupedNotes[bookId]!.add(note);
    }

    // 각 그룹 내에서 소감을 최신순으로 정렬
    groupedNotes.forEach((_, notes) {
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

    // 책들을 가장 최근 소감 기준으로 정렬
    final sortedBooks = groupedNotes.entries.toList()
      ..sort(
          (a, b) => b.value.first.createdAt.compareTo(a.value.first.createdAt));

    return Scaffold(
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : state.bookNotes.isEmpty
                  ? const Center(child: Text('작성한 소감이 없습니다.'))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        itemCount: sortedBooks.length,
                        itemBuilder: (context, index) {
                          final bookNotes = sortedBooks[index].value;
                          final book = bookNotes.first.book;

                          final bookDetailVm = ref.read(
                              bookDetailViewModelProvider(book.isbn).notifier);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.grey300,
                                      width: 1,
                                    ),
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
                                              text: book.title ?? '',
                                              style: AppTextStyle
                                                  .heading5SBold.style
                                                  .copyWith(
                                                color: AppColors.grey800,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  ' (${book.authors.join(", ")})',
                                              style: AppTextStyle
                                                  .detailRegular.style
                                                  .copyWith(
                                                color: AppColors.grey700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...bookNotes.map((note) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipOval(
                                            child: Image.network(
                                              profileState.profile!,
                                              width: 32,
                                              height: 32,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat('yyyy.MM.dd')
                                                .format(note.createdAt),
                                            style: AppTextStyle.heading6.style,
                                          ),
                                          Spacer(),
                                          PopupMenuButton(
                                            icon: AppIcons.moreHorizontal,
                                            iconColor: AppColors.grey700,
                                            padding: EdgeInsets.zero,
                                            position: PopupMenuPosition.over,
                                            color: Colors.white,
                                            itemBuilder: (context) {
                                              return [
                                                PopupMenuItem(
                                                  child: const Text('수정'),
                                                  onTap: () async {
                                                    await Future.delayed(
                                                        const Duration(
                                                            seconds: 0));
                                                    if (context.mounted) {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/write',
                                                        arguments: {
                                                          'isModify': true,
                                                          'postId': note.postId,
                                                          'bookId': book.isbn,
                                                          'review': note.review,
                                                        },
                                                      ).then((_) {
                                                        ref
                                                            .read(
                                                                bookNoteViewModelProvider
                                                                    .notifier)
                                                            .loadBookNotes();
                                                      });
                                                    }
                                                  },
                                                ),
                                                PopupMenuItem(
                                                  child: const Text('삭제'),
                                                  onTap: () async {
                                                    await Future.delayed(
                                                        const Duration(
                                                            seconds: 0));
                                                    if (context.mounted) {
                                                      await Future.wait([
                                                        bookDetailVm
                                                            .handleDeletePost(
                                                                note.postId),
                                                        bookDetailVm
                                                            .fetchBookDetailInfo(
                                                                book.isbn),
                                                      ]).then((_) {
                                                        ref
                                                            .read(
                                                                bookNoteViewModelProvider
                                                                    .notifier)
                                                            .loadBookNotes();
                                                      });
                                                    }
                                                  },
                                                ),
                                              ];
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ExpandableText(
                                        note.review ?? '',
                                        expandText: '더보기',
                                        collapseText: '접기',
                                        maxLines: 3,
                                        linkColor: AppColors.brown500,
                                        style: AppTextStyle.body2Regular.style
                                            .copyWith(
                                          color: AppColors.grey900,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Divider(color: AppColors.grey200),
                                      const SizedBox(height: 8),
                                    ],
                                  )),
                              if (index !=
                                  sortedBooks.length -
                                      1) // 마지막 책이 아닐 경우에만 간격 추가
                                const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                    ),
    );
  }
}
