import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookcaffeine/data/repository/post_repository.dart';
import 'package:bookcaffeine/data/model/post.dart';

final writeViewModelProvider =
    StateNotifierProvider<WriteViewModel, WriteState>((ref) {
  return WriteViewModel(PostRepository());
});

class WriteState {
  final bool isLoading;
  final String? error;

  WriteState({
    this.isLoading = false,
    this.error,
  });

  WriteState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return WriteState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class WriteViewModel extends StateNotifier<WriteState> {
  final PostRepository _repository;

  WriteViewModel(this._repository) : super(WriteState());

  Future<bool> saveReview(
      String nickName, String profile, String review, String bookId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final post = Post(
          bookId: bookId,
          createdAt: DateTime.now(),
          review: review,
          profileImg: profile,
          userId: GlobalUserInfo.uid,
          nickName: nickName,
          public: true, // 기본값 true로 설정
          isDeleted: false); // 기본값 false로 설정

      await _repository.insertPost(post);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
