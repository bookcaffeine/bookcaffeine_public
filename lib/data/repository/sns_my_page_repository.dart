import 'package:bookcaffeine/data/model/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SnsMyPageRepository {
  final _firestore = FirebaseFirestore.instance;

  ///올해 년도
  final thisYear = DateTime.now().year;

  /// 월간 독서량 불러오기
  Future<List<Book>?> fetchMonthlyReadBooks(String userId) async {
    ///이번 달
    final thisMonth = DateTime.now().month;
    final doc = await _firestore
        .collection('user')
        .doc(userId)
        .collection('my_books')
        .where('state', isEqualTo: 'finish')
        .where('finishedAt',
            isGreaterThanOrEqualTo: DateTime(thisYear, thisMonth, 1))
        .where('finishedAt', isLessThan: DateTime(thisYear, thisMonth + 1, 1))
        .get();
    return doc.docs.map((e) => Book.fromJson(e.data())).toList();
  }

  /// 연간 독서량 불러오기
  Future<List<Book>?> fetchYearlyReadBooks(String userId) async {
    final doc = await _firestore
        .collection('user')
        .doc(userId)
        .collection('my_books')
        .where('state', isEqualTo: 'finish')
        .where('finishedAt', isGreaterThanOrEqualTo: DateTime(thisYear, 1, 1))
        .where('finishedAt', isLessThan: DateTime(thisYear + 1, 1, 1))
        .get();

    return doc.docs.map((e) => Book.fromJson(e.data())).toList();
  }

  /// 누적 독서량 불러오기
  Future<List<Book>?> fetchTotalReadBooks(String userId) async {
    final doc = await _firestore
        .collection('user')
        .doc(userId)
        .collection('my_books')
        .where('state', isEqualTo: 'finish')
        .get();
    return doc.docs.map((e) => Book.fromJson(e.data())).toList();
  }
}
