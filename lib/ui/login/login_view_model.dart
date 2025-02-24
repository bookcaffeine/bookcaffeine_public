import 'package:bookcaffeine/data/model/user.dart';
import 'package:bookcaffeine/data/repository/authentication_repository.dart';
import 'package:bookcaffeine/data/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginViewModel extends Notifier<User?> {
  @override
  User? build() {
    return null;
  }

  User? _user;

  User? get user => _user;

  final authenticationRepository = AuthenticationRepository();
  final userRepository = UserRepository();

  /// 구글 로그인
  Future<bool> googleLogin() async {
    try {
      return await authenticationRepository.googleLogin(); // boolean 반환
    } catch (e) {
      // print('googleLogin 실패: $e');
      return false; // 실패 시 false 반환
    }
  }

  /// 카카오 로그인
  Future<bool> kakaoLogin() async {
    try {
      return await authenticationRepository.kakaoLogin(); // boolean 반환
    } catch (e) {
      // print('kakaoLogin 실패: $e');
      return false; // 실패 시 false 반환
    }
  }

  /// 애플 로그인
  Future<bool> appleLogin() async {
    try {
      return await authenticationRepository.signInWithApple(); // boolean 반환
    } catch (e) {
      // print('appleLogin 실패: $e');
      return false; // 실패 시 false 반환
    }
  }

  // 로그아웃 처리
  Future<void> signOut() async {
    await authenticationRepository.signOut();
    _user = null;
  }
}

final loginViewModelProvider = NotifierProvider<LoginViewModel, User?>(() {
  return LoginViewModel();
});
