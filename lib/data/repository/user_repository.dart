import 'package:bookcaffeine/data/model/book.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = firebase_auth.FirebaseAuth.instance;

  // 현재 로그인된 유저 ID 가져오기
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // 유저 존재 여부 확인
  Future<bool> checkUserExists(String userId) async {
    try {
      final doc = await _firestore.collection('user').doc(userId).get();
      return doc.exists;
    } catch (e) {
      // print('유저 존재 여부 확인 실패: $e');
      return false;
    }
  }

  // 상태별 책 목록 조회를 위한 공통 메서드
  Future<List<Book>?> _fetchBooksByState(String userId, String state) async {
    try {
      final docs = await _firestore
          .collection('user')
          .doc(userId)
          .collection('my_books')
          .orderBy('registeredAt', descending: true) // registeredAt 기준 내림차순 정렬
          .get();

      List<Book> books = [];

      for (var doc in docs.docs) {
        final subDoc = await _firestore
            .collection('user')
            .doc(userId)
            .collection('my_books')
            .doc(doc.id)
            .get();

        if (subDoc.exists && subDoc.data()?['state'] == state) {
          final bookDoc = await _firestore
              .collection('book')
              .doc(subDoc.data()?['bookId'])
              .get();

          if (bookDoc.exists) {
            // Book 객체에 상태 값을 포함시켜 반환
            books.add(Book.fromJson({
              ...bookDoc.data()!,
              'state': subDoc.data()?['state'], // 'state' 값을 추가
            }));
          }
        }
      }

      return books;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // 읽고있는 책 list 파이어베이스에서 read
  Future<List<Book>?> fetchCurrentBooks(String userId) async {
    return _fetchBooksByState(userId, 'current');
  }

  // 읽을 예정인 책 list 파이어베이스에서 read
  Future<List<Book>?> fetchUpcomingBooks(String userId) async {
    return _fetchBooksByState(userId, 'upcoming');
  }

  // 다 읽은 책 list 파이어베이스에서 read
  Future<List<Book>?> fetchFinishedBooks(String userId) async {
    return _fetchBooksByState(userId, 'finish');
  }

  // 프로필 데이터 저장
  Future<bool> saveProfileData({
    required String userId,
    String? nickName,
    String? profile,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      String snsType = '';

      if (currentUser != null && currentUser.uid.isNotEmpty) {
        // 카카오의 경우 providerData 비워서 보내는 경우가 있음
        // providerData가 비어있으면 카카오 로그인일 가능성 높음
        if (currentUser.providerData.isEmpty) {
          snsType = 'kakao';
        } else {
          // providerData가 있다면, 이를 기준으로 snsType 설정
          final provider = currentUser.providerData[0].providerId;

          if (provider.contains('google')) {
            snsType = 'google';
          } else if (provider.contains('apple')) {
            snsType = 'apple';
          } else if (provider.contains('kakao')) {
            snsType = 'kakao';
          }
        }

        // user 컬렉션에 프로필 데이터 저장
        await _firestore.collection('user').doc(userId).set({
          'nickName': nickName,
          'profile': profile,
          'snsType': snsType,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return true;
      }

      return false;
    } catch (e) {
      // print('프로필 데이터 저장 실패: $e');
      throw Exception('프로필 데이터 저장에 실패했습니다.');
    }
  }

  // 프로필 데이터 조회
  Future<Map<String, dynamic>> getProfileData(String userId) async {
    try {
      final userDoc = await _firestore.collection('user').doc(userId).get();
      return userDoc.data() ?? {};
    } catch (e) {
      // print('프로필 데이터 조회 실패: $e');
      throw Exception('프로필 데이터 조회에 실패했습니다.');
    }
  }

  /// 연간 독서량 불러오기
  Future<List<Book>?> fetchYearlyReadBooks() async {
    ///올해 년도
    final thisYear = DateTime.now().year;
    final doc = await _firestore
        .collection('user')
        .doc(GlobalUserInfo.uid)
        .collection('my_books')
        .where('state', isEqualTo: 'finish')
        .where('finishedAt', isGreaterThanOrEqualTo: DateTime(thisYear, 1, 1))
        .where('finishedAt', isLessThan: DateTime(thisYear + 1, 1, 1))
        .get();

    return doc.docs.map((e) => Book.fromJson(e.data())).toList();
  }

  /// 월간 독서량 불러오기
  Future<List<Book>?> fetchMonthlyReadBooks() async {
    ///올해 년도
    final thisYear = DateTime.now().year;

    ///이번 달
    final thisMonth = DateTime.now().month;
    final doc = await _firestore
        .collection('user')
        .doc(GlobalUserInfo.uid)
        .collection('my_books')
        .where('state', isEqualTo: 'finish')
        .where('finishedAt',
            isGreaterThanOrEqualTo: DateTime(thisYear, thisMonth, 1))
        .where('finishedAt', isLessThan: DateTime(thisYear, thisMonth + 1, 1))
        .get();
    return doc.docs.map((e) => Book.fromJson(e.data())).toList();
  }

  /// 누적 독서량 불러오기
  Future<List<Book>?> fetchTotalReadBooks() async {
    final doc = await _firestore
        .collection('user')
        .doc(GlobalUserInfo.uid)
        .collection('my_books')
        .where('state', isEqualTo: 'finish')
        .get();
    return doc.docs.map((e) => Book.fromJson(e.data())).toList();
  }
}
