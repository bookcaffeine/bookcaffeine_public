import 'package:firebase_auth/firebase_auth.dart';

/// 회원가입 시 가지고오는 데이터 모델
class JoinUser {
  final String uid;
  final String nickName;
  final String photoURL;
  final DateTime signUpTime;

  JoinUser({
    required this.uid,
    required this.nickName,
    required this.photoURL,
    required this.signUpTime,
  });

  factory JoinUser.fromFirebaseUser(User user) {
    // Firebase User의 metadata.creationTime을 가져옴
    DateTime creationTime = user.metadata.creationTime ?? DateTime.now();

    return JoinUser(
      uid: user.uid,
      nickName: user.displayName ?? 'Unknown',
      photoURL: user.photoURL ?? '',
      signUpTime: creationTime.add(Duration(hours: 9)),
    );
  }
}
