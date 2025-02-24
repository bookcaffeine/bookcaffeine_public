import 'package:bookcaffeine/data/model/book.dart';

class HomeState {
  final List<Book?> currentBooks;
  final List<Book?> upcomingBooks;
  final List<Book?> finishedBook;
  final List<Book?> yearlyReadBooks;
  final List<Book?> monthlyReadBooks;
  final List<Book?> totalReadBooks;

  HomeState({
    required this.currentBooks,
    required this.upcomingBooks,
    required this.finishedBook,
    required this.yearlyReadBooks,
    required this.monthlyReadBooks,
    required this.totalReadBooks,
  });

  HomeState copyWith({
    List<Book?>? currentBooks,
    List<Book?>? upcomingBooks,
    List<Book?>? finishedBook,
    List<Book?>? yearlyReadBooks,
    List<Book?>? monthlyReadBooks,
    List<Book?>? totalReadBooks,
  }) {
    return HomeState(
      currentBooks: currentBooks ?? this.currentBooks,
      upcomingBooks: upcomingBooks ?? this.upcomingBooks,
      finishedBook: finishedBook ?? this.finishedBook,
      yearlyReadBooks: yearlyReadBooks ?? this.yearlyReadBooks,
      monthlyReadBooks: monthlyReadBooks ?? this.monthlyReadBooks,
      totalReadBooks: totalReadBooks ?? this.totalReadBooks,
    );
  }
}
