import 'package:bookcaffeine/data/model/book.dart';
import 'package:bookcaffeine/data/model/book_detail.dart';
import 'package:bookcaffeine/data/model/post.dart';
import 'package:bookcaffeine/data/repository/book_repository.dart';
import 'package:bookcaffeine/data/repository/post_repository.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// PostRepository 참조
class MyLikeState {
  final List<BookDetail> likedBooks;
  final bool isLoading;
  final String? error;

  MyLikeState({
    this.likedBooks = const [],
    this.isLoading = false,
    this.error,
  });

  MyLikeState copyWith({
    List<BookDetail>? likedBooks,
    bool? isLoading,
    String? error,
  }) {
    return MyLikeState(
      likedBooks: likedBooks ?? this.likedBooks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MyLikeViewModel extends Notifier<MyLikeState> {
  final _firestore = FirebaseFirestore.instance;
  final _bookRepository = BookRepository();
  final _postRepository = PostRepository();

  @override
  MyLikeState build() {
    // 초기 상태 설정 후 데이터 로드
    Future.microtask(() => fetchLikedPosts());
    return MyLikeState();
  }

  Future<void> fetchLikedPosts() async {
    if (GlobalUserInfo.uid == null) {
      state = state.copyWith(
        error: '로그인이 필요합니다.',
        isLoading: false,
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      // 1. 내가 좋아요한 post ID들 가져오기
      final likedPostsSnapshot = await _firestore
          .collection('user')
          .doc(GlobalUserInfo.uid)
          .collection('my_like')
          .orderBy('createdAt', descending: true)
          .get();

      if (likedPostsSnapshot.docs.isEmpty) {
        state = state.copyWith(
          likedBooks: [],
          isLoading: false,
        );
        return;
      }

      // 2. 각 post의 상세 정보와 해당 책 정보 가져오기
      final likedPostsData = await Future.wait(
        likedPostsSnapshot.docs.map((doc) async {
          final postId = doc.id;
          final postDoc = await _firestore.collection('post').doc(postId).get();

          // 게시물이 없거나 isDeleted가 true인 경우 null 반환
          if (!postDoc.exists || postDoc.data()?['isDeleted'] == true) {
            return null;
          }

          final likedAt = (doc.data()['createdAt'] as Timestamp).toDate();
          final post = Post.fromFirestore(postDoc, postId: postId);
          final likeCount = await _postRepository.getLikeCount(postId);
          final book = await _bookRepository.fetchBook(post.bookId);

          return {
            'post': post.copyWith(likeCount: likeCount),
            'book': book,
            'likedAt': likedAt,
          };
        }),
      );

      // null 값 제거 및 likedAt 기준으로 정렬
      final validPostsData = likedPostsData
          .where((data) => data != null)
          .map((data) => data!)
          .toList()
        ..sort((a, b) =>
            (b['likedAt'] as DateTime).compareTo(a['likedAt'] as DateTime));

      // 책별로 포스트 그룹화
      final Map<String, BookDetail> bookDetailsMap = {};
      for (var data in validPostsData) {
        final post = data['post'] as Post;
        final book = data['book'] as Book?;
        if (book == null) continue;

        final isbn = book.isbn;

        if (!bookDetailsMap.containsKey(isbn)) {
          bookDetailsMap[isbn] = BookDetail(
            bookInfo: book,
            posts: [],
            emotionTags: book.emotionTags,
          );
        }
        bookDetailsMap[isbn]!.posts.add(post);
      }

      state = state.copyWith(
        likedBooks: bookDetailsMap.values.toList(),
        isLoading: false,
      );
    } catch (e) {
      print('fetchLikedPosts 에러: $e');
      state = state.copyWith(
        error: '좋아요한 소감을 불러오는데 실패했습니다.',
        isLoading: false,
      );
    }
  }

  /// 좋아요 취소
  Future<void> unlikePost(String postId) async {
    try {
      // 데이터베이스에서 좋아요 상태 업데이트
      await _postRepository.toggleLike(postId, GlobalUserInfo.uid!);

      // 상태 업데이트 - 해당 포스트를 목록에서 제거
      final updatedBooks = state.likedBooks
          .map((bookDetail) {
            final updatedPosts = bookDetail.posts
                .where((post) => post.postId != postId)
                .toList();
            return BookDetail(
              bookInfo: bookDetail.bookInfo,
              posts: updatedPosts,
              emotionTags: bookDetail.bookInfo?.emotionTags ?? [],
            );
          })
          .where((bookDetail) => bookDetail.posts.isNotEmpty)
          .toList(); // 포스트가 없는 책은 제거

      state = state.copyWith(likedBooks: updatedBooks);
    } catch (e) {
      print('unlikePost 에러: $e');
      throw Exception('좋아요 취소 중 오류가 발생했습니다.');
    }
  }

  Future<void> addLikedPost(String postId) async {
    try {
      final postDoc = await _firestore.collection('post').doc(postId).get();
      if (!postDoc.exists) return;

      final post = Post.fromFirestore(postDoc, postId: postId);
      final likeCount = await _postRepository.getLikeCount(postId);
      final book = await _bookRepository.fetchBook(post.bookId);

      final newBookDetail = BookDetail(
        bookInfo: book,
        posts: [
          post.copyWith(
            isLiked: true,
            likeCount: likeCount ?? 0,
          )
        ],
        emotionTags: book?.emotionTags ?? [],
      );

      // 기존 책 목록에서 같은 책이 있는지 확인
      final existingBookIndex = state.likedBooks
          .indexWhere((detail) => detail.bookInfo?.isbn == book?.isbn);

      if (existingBookIndex != -1) {
        // 같은 책이 있으면 posts 배열에 추가
        final updatedBooks = List.of(state.likedBooks);
        final existingBook = updatedBooks[existingBookIndex];
        updatedBooks[existingBookIndex] = BookDetail(
          bookInfo: existingBook.bookInfo,
          posts: [...existingBook.posts, ...newBookDetail.posts],
          emotionTags: existingBook.bookInfo?.emotionTags ?? [],
        );
        state = state.copyWith(likedBooks: updatedBooks);
      } else {
        // 새로운 책이면 목록에 추가
        state = state.copyWith(
          likedBooks: [...state.likedBooks, newBookDetail],
        );
      }
    } catch (e) {
      print('addLikedPost 에러: $e');
    }
  }

  Future<void> reportPost(String userId, String postId) async {
    try {
      final reportDoc = await _firestore.collection('report').doc(userId).get();

      if (reportDoc.exists) {
        final reportedPosts =
            (reportDoc.data()?['postId'] as List<dynamic>? ?? [])
                .map((item) => item['postId'] as String)
                .toList();

        if (!reportedPosts.contains(postId)) {
          await _firestore.collection('report').doc(userId).update({
            'postId': FieldValue.arrayUnion([
              {
                'postId': postId,
                'reportedAt': DateTime.now().toIso8601String(),
              }
            ])
          });
        }
      } else {
        await _firestore.collection('report').doc(userId).set({
          'postId': [
            {
              'postId': postId,
              'reportedAt': DateTime.now().toIso8601String(),
            }
          ],
          'reporterId': userId,
        });
      }
    } catch (e) {
      print('신고 처리 중 에러 발생: $e');
    }
  }
}

final myLikeViewModelProvider = NotifierProvider<MyLikeViewModel, MyLikeState>(
  () => MyLikeViewModel(),
);
