import 'package:bookcaffeine/data/model/book.dart';
import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/book_cover.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/book_desc.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/detail_widgets/book_detail_bottom.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/book_name_authors.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/emotion_tag_box.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/detail_widgets/detail_state_update_box.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/post_list.dart';
import 'package:bookcaffeine/ui/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookDetailPage extends ConsumerStatefulWidget {
  const BookDetailPage({super.key});

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  @override
  Widget build(BuildContext context) {
    // book 컬렉션에 등록되어 있는 데이터
    final book = ModalRoute.of(context)!.settings.arguments as Book;

    final bookDetailInfo = ref.watch(bookDetailViewModelProvider(book.isbn));
    final bookDetailVm =
        ref.read(bookDetailViewModelProvider(book.isbn).notifier);
    final homeVm = ref.read(homeViewModelProvider.notifier);

    if (bookDetailInfo == null) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ListView(
        children: [
          // ✅ 책 표지
          bookCover(context, true, homeVm, bookDetailVm,
              bookDetailInfo.bookInfo?.thumbnail, book.isbn),
          const SizedBox(height: 20),

          // ✅ 책 정보
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ 책 제목 및 작가이름
                bookNameAuthors(bookDetailInfo.bookInfo?.title,
                    bookDetailInfo.bookInfo?.authors[0]),
                const SizedBox(height: 16),

                // ✅ 상태 드롭다운
                DetailStateUpdateBoxWidget(
                  isDetail: true,
                  bookDetailVm: bookDetailVm,
                  homeVm: homeVm,
                  bookId: book.bookId,
                  bookState: book.state,
                ),
                const SizedBox(height: 16),

                // ✅ 책 소개 (더보기 기능 추가)
                bookDesc(bookDetailInfo.bookInfo?.contents),

                // 감성 태그 표시
                emotionTagBox(bookDetailInfo, context),
                const SizedBox(height: 20),

                // ✅ 소감 리스트
                PostListWidget(
                  bookDetailInfo: bookDetailInfo,
                  bookDetailVm: bookDetailVm, // 뷰모델 전달
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: bookDetailBottom(context, book.isbn),
    );
  }
}
