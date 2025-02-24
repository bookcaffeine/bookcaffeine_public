import 'package:bookcaffeine/data/model/book.dart';
import 'package:bookcaffeine/data/repository/book_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookSearchState {
  final List<Book>? books;

  BookSearchState({required this.books});
}

class BookSearchPageViewModel extends AutoDisposeNotifier<BookSearchState> {
  @override
  BookSearchState build() {
    return BookSearchState(books: null);
  }

  final bookRepository = BookRepository();

  /// 책list 검색
  Future<void> searchBooks(String query) async {
    final getBooks = await bookRepository.searchBooks(query);
    state = BookSearchState(books: getBooks ?? []);
  }
}

///
final bookSearchViewModel =
    NotifierProvider.autoDispose<BookSearchPageViewModel, BookSearchState>(
  () {
    return BookSearchPageViewModel();
  },
);
