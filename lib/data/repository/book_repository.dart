import 'dart:convert';

import 'package:bookcaffeine/data/model/book.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class BookRepository {
  Client client = Client();

  final _collectionRef = FirebaseFirestore.instance;

  /// Book READ 정보 불러오기
  Future<List<Book>?> searchBooks(String query) async {
    try {
      Response result = await client.get(
        Uri.parse(
          'https://dapi.kakao.com/v3/search/book?query=$query',
        ),
        headers: {
          'Authorization': dotenv.env["KAKAO_API_KEY"] ?? '',
        },
      );
      if (result.statusCode == 200) {
        final decodedJson = jsonDecode(result.body);
        return List.from(decodedJson['documents'])
            .map((e) => Book.fromJson(e))
            .toList();
      }
      // 응답코드가 200이 아닐 경우 빈 리스트 반환
      return [];
    } catch (e) {
      // print(e);
      return [];
    }
  }

  /// Book Create firebase에 넣기
  /// book과 user 컬렉션에 동시에 저장
  Future<void> insertBook(Book book, String state) async {
    try {
      final map = book.toJson();

      // book 컬렉션에 책 정보 저장(중복저장되지 않도록 set() 사용)
      await _collectionRef.collection('book').doc(book.isbn).set(map);

      // user 컬렉션의 하위 컬렉션인 my_books에 bookId와 상태 저장
      final Map<String, dynamic> updateData = {
        'bookId': book.isbn,
        'state': state,
        'thumbnail': book.thumbnail,
        'registeredAt': DateTime.now()
      };

      // state가 'finish'인 경우에만 finishedAt 추가
      if (state == 'finish') {
        updateData['finishedAt'] = DateTime.now();
      }

      // user 컬렉션의 하위 컬렉션인 my_books에 bookId와 상태 저장
      await _collectionRef
          .collection('user')
          .doc(GlobalUserInfo.uid)
          .collection('my_books')
          .doc(book.isbn)
          .set(
            updateData,
          );
    } catch (e) {
      print(e);
    }
  }

  /// isbn 기준으로 책 정보 가져오기.
  Future<Book?> fetchBook(String isbn) async {
    try {
      final doc = await _collectionRef.collection('book').doc(isbn).get();

      if (doc.exists) {
        // final data = doc.data() as Map<String, dynamic>;
        // 디버그 로그 추가
        // print('Firestore book data: $data');
        // print('Emotion tags from Firestore: ${data['emotionTags']}');

        return Book.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching book: $e');
      return null;
    }
  }

  /// my_books에 상태 업데이트, state: 'finish', 'current', 'upcoming'
  Future<void> updateMyBooksState(String bookId, String state) async {
    try {
      final Map<String, dynamic> updateData = {
        'bookId': bookId,
        'state': state,
      };

      // state가 'finish'인 경우에만 finishedAt 추가
      if (state == 'finish') {
        updateData['finishedAt'] = DateTime.now();
      }
      await _collectionRef
          .collection('user')
          .doc(GlobalUserInfo.uid)
          .collection('my_books')
          .doc(bookId)
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  /// my_books 컬렉션에서 책 삭제
  Future<void> deleteMyBooks(bookId) async {
    // print('나의 책 삭제');
    try {
      await _collectionRef
          .collection('user')
          .doc(GlobalUserInfo.uid)
          .collection('my_books')
          .doc(bookId)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  /// 감정 태그를 book 컬렉션에 저장
  Future<void> saveEmotionTags(String bookId, List<String> emotionTags) async {
    try {
      await _collectionRef.collection('book').doc(bookId).update({
        'emotionTags': emotionTags,
      });
    } catch (e) {
      print('Error saving emotion tags: $e');
    }
  }

  /// 이미 등록된 책인지 확인
  Future<bool> isBookExists(String userId, String bookId) async {
    try {
      final doc = await _collectionRef
          .collection('user')
          .doc(userId)
          .collection('my_books')
          .doc(bookId)
          .get();
      return doc.exists;
    } catch (e) {
      print('isBookExists 에러: $e');
      return false;
    }
  }
}
