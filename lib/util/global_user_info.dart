import 'package:bookcaffeine/data/model/join_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalUserInfo {
  static String? uid;
  static String? nickName;

  /// 사용자 정보 업데이트
  static void updateUserInfo(String? newNickName) {
    nickName = newNickName;

    // 현재 사용자 정보 새로 가져오기
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;
      nickName = currentUser.displayName;
    }
  }

  static JoinUser? getCurrentUserInfo() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // 전역 변수에 uid, nickName 저장
      uid = currentUser.uid;
      nickName = currentUser.displayName;

      return JoinUser.fromFirebaseUser(currentUser);
    } else {
      // print('No user is currently signed in.');
      return null;
    }
  }

  /// 사용자 정보 초기화
  static void clearUserInfo() {
    uid = null;
    nickName = null;
  }
}
