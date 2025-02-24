import 'package:bookcaffeine/data/model/book.dart';
import 'package:bookcaffeine/data/model/book_detail.dart';
import 'package:bookcaffeine/data/model/post.dart';
import 'package:bookcaffeine/data/model/report.dart';
import 'package:bookcaffeine/data/repository/book_repository.dart';
import 'package:bookcaffeine/data/repository/post_repository.dart';
import 'package:bookcaffeine/ui/mypage/my_like_view_model.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:bookcaffeine/data/repository/gpt_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookDetailViewModel
    extends AutoDisposeFamilyNotifier<BookDetail?, String> {
  final bookRepository = BookRepository();
  final postRepository = PostRepository();
  final gptRepository = GptRepository();

  /// 감정 태그 업데이트가 필요한지 확인하는 임계값 리스트
  final List<int> emotionAnalysisThresholds = [
    10,
    30,
    50,
    100,
    200,
    300,
    500,
    1000,
  ];

  /// 200개 단위로 추가 임계값을 생성
  int getNextThreshold(int currentCount) {
    if (currentCount > 1000) {
      return ((currentCount / 1000).ceil() * 1000);
    }
    return -1; // 300 이하일 경우 기본 임계값 사용
  }

  /// 감정 분석이 필요한지 확인
  bool needsEmotionAnalysis(int reviewCount) {
    // print('감정 분석 체크 - 현재 리뷰 수: $reviewCount'); // 로그 추가

    // 기본 임계값 체크
    if (emotionAnalysisThresholds.contains(reviewCount)) {
      // print('임계값 포함됨: $reviewCount'); // 로그 추가
      return true;
    }
    // 300개 이상일 경우 200개 단위로 체크
    if (reviewCount > 300) {
      // print('300개 이상 체크: $reviewCount'); // 로그 추가
      return reviewCount % 200 == 0;
    }
    // print('분석 불필요'); // 로그 추가
    return false;
  }

  @override
  BookDetail? build(String arg) {
    fetchBookDetailInfo(arg);
    return BookDetail(bookInfo: null, posts: [], emotionTags: []);
  }

  /// 책 상세 페이지에서 사용되는 book과 posts 데이터 묶어서 반환
  Future<void> fetchBookDetailInfo(String isbn) async {
    try {
      final bookInfo = await bookRepository.fetchBook(isbn);
      final posts =
          await postRepository.getPostsByBookIdWithoutReported(isbn) ?? [];

      // 각 post의 좋아요 상태와 개수를 즉시 가져옴
      final updatedPosts = await Future.wait(
        posts.map((post) async {
          final isLiked = await postRepository.checkIsLiked(
              post.postId ?? '', GlobalUserInfo.uid ?? '');
          final likeCount = await postRepository.getLikeCount(post.postId!);

          return post.copyWith(
            isLiked: isLiked,
            likeCount: likeCount,
          );
        }),
      );

      state = BookDetail(
        bookInfo: bookInfo,
        posts: updatedPosts,
        emotionTags: bookInfo?.emotionTags ?? [],
      );
    } catch (e) {
      print('Error fetching book details: $e');
      state = null;
    }
  }

  /// 현재 소감 수에 해당하는 임계값 가져오기
  int getCurrentThreshold(int reviewCount) {
    // 현재 리뷰 수에 해당하는 가장 큰 임계값 찾기
    for (int i = emotionAnalysisThresholds.length - 1; i >= 0; i--) {
      if (reviewCount >= emotionAnalysisThresholds[i]) {
        if (reviewCount > 300) {
          // 300개 이상일 경우 200단위로 계산
          return (reviewCount ~/ 200) * 200;
        }
        return emotionAnalysisThresholds[i];
      }
    }
    return 0;
  }

  /// 마지막으로 분석된 임계값 가져오기
  int getLastAnalyzedThreshold(List<String> emotionTags, int reviewCount) {
    if (emotionTags.isEmpty) return 0;

    // 현재 리뷰 수보다 작은 가장 큰 임계값 찾기
    for (int i = emotionAnalysisThresholds.length - 1; i >= 0; i--) {
      if (emotionAnalysisThresholds[i] < reviewCount) {
        return emotionAnalysisThresholds[i];
      }
    }
    return 0;
  }

  /// 감정 분석 수행 및 저장
  Future<void> analyzeAndSaveEmotions(String bookId, List<Post> posts) async {
    try {
      // print('감정 분석 시작 - bookId: $bookId');
      final reviews = posts
          .where((post) => post.review != null && post.review!.isNotEmpty)
          .map((post) => post.review!)
          .toList();

      // print('분석할 리뷰 개수: ${reviews.length}개');

      if (reviews.isNotEmpty) {
        final emotionTags = await gptRepository.analyzeEmotions(reviews);
        // print('생성된 감정 태그: $emotionTags');
        await bookRepository.saveEmotionTags(bookId, emotionTags);

        // 현재 상태 업데이트
        if (state != null && state!.bookInfo != null) {
          state = state!.copyWith(
              bookInfo: state!.bookInfo!.copyWith(emotionTags: emotionTags));
        }
      }
    } catch (e) {
      print('감정 분석 에러: $e');
    }
  }

  /// isbn 기준으로 해당 책에 소속된 posts 문서 가져오기
  Future<void> handlegetPostsByBookId(String postId) async {
    try {
      final posts =
          await postRepository.getPostsByBookIdWithoutReported(postId);

      // 기존의 bookInfo와 emotionTags는 유지하고 posts만 갱신
      state = BookDetail(
        bookInfo: state?.bookInfo,
        posts: posts ?? [], // posts가 null일 경우 빈 리스트로 처리
        emotionTags: state?.emotionTags ?? [],
      );
    } catch (e) {
      // print('Error handlegetPostsByBookId: $e');
      state = null;
    }
  }

  /// 파이어베이스에서 post 문서 생성
  Future<void> handleInsertPost(Post post) async {
    try {
      await postRepository.insertPost(post);
      // 상태 갱신 (GPT 호출 없이)
      await fetchBookDetailInfo(post.bookId);
    } catch (e) {
      // print('Error handleInsertPost: $e');
      state = null;
    }
  }

  /// 파이어베이스에서 post 문서 수정
  Future<bool> handleUpdatePost(String nickName, String profile, String review,
      String bookId, String postId) async {
    try {
      final updatePost = Post(
        bookId: bookId,
        createdAt: DateTime.now(),
        review: review,
        userId: GlobalUserInfo.uid,
        profileImg: profile,
        nickName: nickName,
        public: true, // 기본값 true로 설정
      );

      await postRepository.updatePost(updatePost, postId);

      return true;
    } catch (e) {
      // print('Error handleUpdatePost: $e');
      state = null;
      return false;
    }
  }

  /// 이미 등록된 책인지 확인
  Future<bool> handleIsBookExists(String userId, String bookId) async {
    try {
      final bookExists = await bookRepository.isBookExists(userId, bookId);
      return bookExists;
    } catch (e) {
      // print('Error handleDeletePost: $e');
      state = null;
      return false;
    }
  }

  /// 파이어베이스에서 post 문서 삭제
  Future<void> handleDeletePost(String postId) async {
    try {
      await postRepository.deletePost(postId);
    } catch (e) {
      // print('Error handleDeletePost: $e');
      state = null;
    }
  }

  /// 책 등록(book과 user컬렉션에 동시 저장)
  Future<void> handleinsertBook(Book book, String state) async {
    try {
      await bookRepository.insertBook(book, state);
    } catch (e) {
      print('Error handleInsertPost: $e');
    }
  }

  /// my_books 컬렉션에서 state 업데이트(state: 'finish', 'current', 'upcoming')
  Future<void> handleUpdateMyBooksState(String bookId, String state) async {
    try {
      await bookRepository.updateMyBooksState(bookId, state);
    } catch (e) {
      print('Error handleDeleUpdateMyBooksState: $e');
    }
  }

  /// my_books 컬렉션에서 책 삭제
  Future<void> handleDeleteMyBooks(String bookId) async {
    try {
      await bookRepository.deleteMyBooks(bookId);
    } catch (e) {
      // print('Error handleDeleteMyBooks: $e');
      state = null;
    }
  }

  /// 신고 기능
  Future<void> handleReportPost(String userId, String postId) async {
    try {
      final report = Report(
        postId: [
          ReportItem(
            postId: postId,
            reportedAt: DateTime.now(),
          ),
        ],
        reporterId: userId,
      );

      await postRepository.reportPost(report, userId);
    } catch (e) {
      // print('Error handleReportPost: $e');
      state = null;
    }
  }

  /// 좋아요 토글
  Future<void> toggleLike(String postId, WidgetRef ref) async {
    try {
      if (GlobalUserInfo.uid == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 현재 상태를 기반으로 UI 즉시 업데이트
      final currentPost =
          state!.posts.firstWhere((post) => post.postId == postId);
      final newIsLiked = !currentPost.isLiked;

      // 백그라운드에서 실제 데이터 업데이트
      await postRepository.toggleLike(postId, GlobalUserInfo.uid!);

      // 실제 좋아요 개수 가져오기
      final actualLikeCount = await postRepository.getLikeCount(postId);

      // UI 업데이트
      final updatedPosts = state!.posts.map((post) {
        if (post.postId == postId) {
          return post.copyWith(
            isLiked: newIsLiked,
            likeCount: actualLikeCount ?? 0,
          );
        }
        return post;
      }).toList();
      state = state!.copyWith(posts: updatedPosts);

      // MyLikeViewModel 상태 업데이트
      if (newIsLiked) {
        // 좋아요를 누른 경우
        await ref.read(myLikeViewModelProvider.notifier).addLikedPost(postId);
      } else {
        // 좋아요를 취소한 경우
        await ref.read(myLikeViewModelProvider.notifier).unlikePost(postId);
      }
    } catch (e) {
      print('toggleLike 에러: $e');
      throw Exception('좋아요 처리 중 오류가 발생했습니다.');
    }
  }

  /// 초기 좋아요 상태 로드
  Future<void> loadLikeStates() async {
    if (GlobalUserInfo.uid == null) return;

    final updatedPosts = await Future.wait(
      state!.posts.map((post) async {
        final isLiked = await postRepository.checkIsLiked(
            post.postId ?? '', GlobalUserInfo.uid!);
        final likeCount = await postRepository.getLikeCount(post.postId ?? '');

        return post.copyWith(
          isLiked: isLiked,
          likeCount: likeCount ?? 0,
        );
      }),
    );

    state = state!.copyWith(posts: updatedPosts);
  }
}

final bookDetailViewModelProvider = NotifierProvider.autoDispose
    .family<BookDetailViewModel, BookDetail?, String>(
  () => BookDetailViewModel(),
);
