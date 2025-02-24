import 'package:bookcaffeine/data/model/book.dart';
import 'package:bookcaffeine/data/repository/book_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'BookRepository search test',
    () async {
      await dotenv.load(fileName: ".env");

      BookRepository bookRepository = BookRepository();
      List<Book>? results = await bookRepository.searchBooks('강아지');
      expect(results != null, true);
      // if (results != null) {
      //   for (var result in results) {
      //     print(result.title);
      //   }
      // }
    },
  );
}
