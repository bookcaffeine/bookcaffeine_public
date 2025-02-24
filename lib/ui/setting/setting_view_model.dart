import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookcaffeine/data/repository/authentication_repository.dart';
import 'package:bookcaffeine/ui/home/home_view_model.dart';
import 'package:bookcaffeine/ui/profile/profile_page_view_model.dart';
import 'package:bookcaffeine/ui/book_note/book_note_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookcaffeine/util/global_user_info.dart';

class SettingState {
  final bool isLoading;
  final String? error;

  SettingState({
    this.isLoading = false,
    this.error,
  });

  SettingState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return SettingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final settingViewModelProvider =
    StateNotifierProvider<SettingViewModel, SettingState>((ref) {
  return SettingViewModel(
    AuthenticationRepository(),
    ref,
  );
});

class SettingViewModel extends StateNotifier<SettingState> {
  final AuthenticationRepository _repository;
  final Ref ref;

  SettingViewModel(this._repository, this.ref) : super(SettingState());

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.deleteAccount();

      ref.read(homeViewModelProvider.notifier).clearState();
      ref.read(profileViewModelProvider.notifier).clearState();
      ref.read(bookNoteViewModelProvider.notifier).clearState();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateNickname(String newNickname) async {
    try {
      // print(
      //     '닉네임 업데이트 시작 - 현재 GlobalUserInfo.nickName: ${GlobalUserInfo.nickName}');

      // Firebase Auth 업데이트
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newNickname);
      // print('Firebase Auth 업데이트 완료');

      // Firestore 업데이트
      await FirebaseFirestore.instance
          .collection('user')
          .doc(GlobalUserInfo.uid)
          .update({'nickName': newNickname});
      // print('Firestore 업데이트 완료');

      // GlobalUserInfo 업데이트
      GlobalUserInfo.updateUserInfo(newNickname);
      // print('GlobalUserInfo 업데이트 후 nickName: ${GlobalUserInfo.nickName}');

      // 현재 사용자 정보 새로고침
      GlobalUserInfo.getCurrentUserInfo();
      // print(
      //     '사용자 정보 새로고침 완료 - GlobalUserInfo.nickName: ${GlobalUserInfo.nickName}');
    } catch (e) {
      print('닉네임 업데이트 실패: $e');
    }
  }
}
