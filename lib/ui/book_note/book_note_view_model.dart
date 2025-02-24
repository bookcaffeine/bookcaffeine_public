import 'package:bookcaffeine/data/model/book.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookNoteViewModelProvider =
    StateNotifierProvider<BookNoteViewModel, BookNoteState>((ref) {
  return BookNoteViewModel();
});

class BookNoteState {
  final List<BookNote> bookNotes;
  final bool isLoading;
  final String? error;

  BookNoteState({
    this.bookNotes = const [],
    this.isLoading = false,
    this.error,
  });

  BookNoteState copyWith({
    List<BookNote>? bookNotes,
    bool? isLoading,
    String? error,
  }) {
    return BookNoteState(
      bookNotes: bookNotes ?? this.bookNotes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BookNote {
  final String postId;
  final Book book;
  final DateTime createdAt;
  final String? review;

  BookNote({
    required this.postId,
    required this.book,
    required this.createdAt,
    this.review,
  });
}

class BookNoteViewModel extends StateNotifier<BookNoteState> {
  final _firestore = FirebaseFirestore.instance;

  BookNoteViewModel() : super(BookNoteState()) {
    loadBookNotes();
  }

  Future<void> loadBookNotes() async {
    try {
      state = state.copyWith(isLoading: true);

      final userId = GlobalUserInfo.uid;
      if (userId == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // 내가 작성한 모든 포스트 가져오기
      final postDocs = await _firestore
          .collection('post')
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .get();

      // bookId를 기준으로 모든 노트를 그룹화
      final Map<String, List<BookNote>> bookNotesMap = {};

      for (var postDoc in postDocs.docs) {
        final bookId = postDoc.data()['bookId'] as String;
        final bookDoc = await _firestore.collection('book').doc(bookId).get();

        if (bookDoc.exists) {
          final book = Book.fromJson(bookDoc.data()!);
          final createdAtData = postDoc.data()['createdAt'];

          final DateTime createdAt;
          if (createdAtData is Timestamp) {
            createdAt = createdAtData.toDate();
          } else if (createdAtData is String) {
            createdAt = DateTime.parse(createdAtData);
          } else {
            createdAt = DateTime.now();
          }

          final bookNote = BookNote(
            postId: postDoc.id,
            book: book,
            createdAt: createdAt,
            review: postDoc.data()['review'] as String?,
          );

          if (!bookNotesMap.containsKey(bookId)) {
            bookNotesMap[bookId] = [];
          }
          bookNotesMap[bookId]!.add(bookNote);
        }
      }

      // 각 책의 소감들을 최신순으로 정렬하고, 책도 최신 소감 기준으로 정렬
      final List<BookNote> allNotes = [];
      bookNotesMap.forEach((_, notes) {
        // 각 책의 소감들을 최신순으로 정렬
        notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        allNotes.addAll(notes);
      });

      // 전체 소감을 최신순으로 정렬
      allNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(
        bookNotes: allNotes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearState() {
    state = BookNoteState();
  }

  /// 사용자 프로필 이미지 가져오기
  Future<String?> fetchUserProfile() async {
    try {
      if (GlobalUserInfo.uid == null) return null;

      final userDoc =
          await _firestore.collection('user').doc(GlobalUserInfo.uid).get();

      if (!userDoc.exists) return null;

      return userDoc.data()?['profile'] as String?;
    } catch (e) {
      print('fetchUserProfile 에러: $e');
      return null;
    }
  }
}
