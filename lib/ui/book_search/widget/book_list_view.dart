import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/ui/book_search/book_search_page_view_model.dart';
import 'package:bookcaffeine/util/global_widgets/empty_book_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookListView extends StatelessWidget {
  /// 책 검색 결과
  const BookListView({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(bookSearchViewModel);
      final books = state.books;
      if (books == null) {
        return SizedBox();
      }
      if (books.isEmpty) {
        return Expanded(
          child: Center(
            child: Text(
              '검색된 결과가 없습니다.',
              style: AppTextStyle.heading6R.style.copyWith(
                color: AppColors.grey800,
              ),
            ),
          ),
        );
      }
      return Expanded(
        child: ListView.separated(
          itemCount: books.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                Navigator.pushNamed(
                  context,
                  '/book_register',
                  arguments: books[index],
                );
              },
              child: SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 68,
                      height: 100,
                      child: (books[index].thumbnail != null &&
                              books[index].thumbnail!.isNotEmpty)
                          ? Image.network(
                              books[index].thumbnail!,
                              fit: BoxFit.contain,
                            )
                          : emptyBookCover(books[index].title),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${books[index].title}',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.heading5SBold.style,
                          ),
                          Text.rich(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            TextSpan(
                              style: AppTextStyle.heading6.style
                                  .copyWith(color: AppColors.grey700),
                              children: [
                                TextSpan(
                                  text: books[index].authors.join(', '),
                                  style: AppTextStyle.heading6.style
                                      .copyWith(color: AppColors.grey700),
                                ),
                                TextSpan(
                                  text: ' \t저',
                                  style: AppTextStyle.heading6.style
                                      .copyWith(color: AppColors.grey500),
                                ),
                                if (books[index].translators.isNotEmpty)
                                  TextSpan(
                                    text: '\t/',
                                    style: AppTextStyle.heading6.style
                                        .copyWith(color: AppColors.grey700),
                                  ),
                                TextSpan(
                                  text: books[index].translators.join(', '),
                                  style: AppTextStyle.heading6.style
                                      .copyWith(color: AppColors.grey700),
                                ),
                                if (books[index].translators.isNotEmpty)
                                  TextSpan(
                                    text: '\t역',
                                    style: AppTextStyle.heading6.style
                                        .copyWith(color: AppColors.grey500),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${books[index].publisher}',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.heading6.style
                                .copyWith(color: AppColors.grey700),
                          ),
                          Text(
                            books[index].datetime?.substring(0, 7) ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.heading6.style
                                .copyWith(color: AppColors.grey500),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
