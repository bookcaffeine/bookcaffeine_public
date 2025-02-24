import 'dart:io';

import 'package:bookcaffeine/data/repository/user_repository.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(UserRepository());
});

class ProfileState {
  final String? nickName;
  final String? profile;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  ProfileState({
    this.nickName,
    this.profile,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  bool get isValid {
    return nickName != null && profile != null;
  }

  ProfileState copyWith({
    String? nickName,
    String? profile,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    XFile? xFile,
  }) {
    return ProfileState(
      nickName: nickName ?? this.nickName,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  final UserRepository _repository;

  /// 프로필 페이지의 ViewModel 사용자 정보 초기화
  ProfileViewModel(this._repository) : super(ProfileState()) {
    _initializeWithCurrentUser();
  }

  void _initializeWithCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      state = state.copyWith(
        nickName: currentUser.displayName,
        profile: currentUser.photoURL,
      );

      try {
        final userDoc = await _repository.getProfileData(currentUser.uid);
        state = state.copyWith(
          nickName: userDoc['nickName'] as String? ?? currentUser.displayName,
          profile: userDoc['profile'] as String? ?? currentUser.photoURL,
        );
      } catch (e) {
        print('초기 프로필 로드 실패: $e');
      }
    }
  }

  void updateNickName(String value) {
    state = state.copyWith(nickName: value);
  }

  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  Future<bool> saveProfile() async {
    try {
      state = state.copyWith(
        isLoading: true,
        isSuccess: false,
      );

      final userInfo = GlobalUserInfo.getCurrentUserInfo();

      if (userInfo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      bool isSuccess = await _repository.saveProfileData(
        userId: userInfo.uid,
        nickName: state.nickName,
        profile: state.profile,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
      return isSuccess;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
      );
      return false;
    }
  }

  Future<void> loadUserProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final userDoc = await _repository.getProfileData(currentUser.uid);
        state = state.copyWith(
          nickName: userDoc['nickName'] as String? ?? currentUser.displayName,
          profile: userDoc['profile'] as String? ?? currentUser.photoURL,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  ///이미지픽커에서 이미지 갖고오기.
  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final xFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      state = state.copyWith(xFile: xFile);
      File file = File(xFile.path);
      final imageRef = FirebaseStorage.instance
          .ref()
          .child('profiles/${GlobalUserInfo.uid}');

      /// 이미지 userId로 storage에 올리기
      await imageRef.putFile(file);
      final uploadedUrl = await imageRef.getDownloadURL();
      state = state.copyWith(profile: uploadedUrl);
      // print('😶‍🌫️${uploadedUrl}');
    }
  }

  Future<void> clearState() async {
    state = ProfileState();
  }
}
