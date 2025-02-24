import 'package:bookcaffeine/data/model/book.dart';
import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/book_cover.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/book_desc.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/book_name_authors.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/register_widgets/book_register_bottom.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/emotion_tag_box.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/post_list.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/register_widgets/register_state_update_box.dart';
import 'package:bookcaffeine/ui/home/home_view_model.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookRegisterPage extends ConsumerStatefulWidget {
  const BookRegisterPage({super.key});

  @override
  ConsumerState<BookRegisterPage> createState() => _BookRegisterPageState();
}

class _BookRegisterPageState extends ConsumerState<BookRegisterPage> {
  String selectedState = '읽을 예정'; // ✅ 초기값 설정
  String dbValue = "upcoming"; // ✅ DB 저장용 상태값

  bool isBookRegistered = false; // ✅ 책 등록 여부 상태 변수

  // 상태 값과 DB 저장 값 매핑
  final Map<String, String> stateToDbValue = {
    '읽는 중': 'current',
    '읽을 예정': 'upcoming',
    '독서 완료': 'finish',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isBookExists(); // 이곳에서 호출하여 `BuildContext`가 준비된 후 실행
  }

  // 책이 이미 등록되었는지 체크
  void isBookExists() async {
    final book = ModalRoute.of(context)?.settings.arguments as Book;

    final bookDetailVm =
        ref.read(bookDetailViewModelProvider(book.isbn).notifier);
    bool bookExists =
        await bookDetailVm.handleIsBookExists(GlobalUserInfo.uid!, book.bookId);

    setState(() {
      isBookRegistered = bookExists;
    });
  }

  // 상태 업데이트
  void updateState(newValue) {
    setState(() {
      selectedState = newValue; // UI용 상태 변경
      dbValue = stateToDbValue[newValue]!; // DB용 상태값 변경
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)?.settings.arguments as Book;

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
            bookCover(context, false, homeVm, bookDetailVm, book.thumbnail,
                book.isbn),
            const SizedBox(height: 20),

            // ✅ 책 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ 책 제목 및 작가이름
                  bookNameAuthors(book.title, book.authors[0]),
                  const SizedBox(height: 16),

                  // ✅ 상태 드롭다운
                  RegisterStateUpdateBox(
                      updateState: updateState,
                      selectedState: selectedState,
                      stateToDbValue: stateToDbValue),
                  const SizedBox(height: 16),

                  // ✅ 책 소개 (더보기 기능 추가)
                  bookDesc(book.contents),

                  // ✅ 감성 태그 표시
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
        bottomNavigationBar: registerBottom(
            context, book, bookDetailVm, homeVm, dbValue, isBookRegistered));
  }
}
