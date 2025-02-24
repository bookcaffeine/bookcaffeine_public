import 'dart:io';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationRepository {
  final _auth = firebase_auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // 구글 로그인 처리 함수
  Future<bool> googleLogin() async {
    try {
      // 구글 로그인 시도
      final googleUser = await GoogleSignIn().signIn();
      // print('googleUser: $googleUser');

      if (googleUser == null) {
        // 사용자가 로그인 취소한 경우
        // print('사용자가 구글 로그인을 취소했습니다.');
        return false; // ❌ 로그인 실패 또는 취소 반환
      }

      // Firebase Auth를 위한 인증 정보 가져오기
      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Auth를 사용해 로그인
      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // print('구글 로그인 성공: ${googleUser.displayName}, ${googleUser.photoUrl}');
        // Firebase 사용자 정보 업데이트
        await user.updateProfile(
          displayName: googleUser.displayName,
          photoURL: googleUser.photoUrl,
        );
        // 정보 업데이트 후 반드시 reload
        await user.reload();

        // ✅ 로그인 성공 시 UID를 전역 변수에 저장
        // googleuser.id 로 하면 애플과 분리 됌 => 카카오도 분리되어 있기 때문에 우선 분리하는 방식으로
        // user.uid 로 하면 애플과 동기화됌
        GlobalUserInfo.uid = googleUser.id;
        // print('✅ 전역 변수에 저장된 UID: ${GlobalUserInfo.uid}');
        return true; // ✅ 로그인 성공 반환
      }
      // 예외 처리 없이 user가 null일 경우 대비
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Firebase 인증 관련 예외 처리
      // print('Firebase 인증 오류: ${e.message}');
      throw Exception('Firebase 인증에 실패했습니다: ${e.message}');
    } on SocketException {
      // 네트워크 문제 처리
      // print('네트워크 연결 오류: 인터넷 연결을 확인하세요.');
      throw Exception('네트워크 연결에 문제가 있습니다. 인터넷을 확인하세요.');
    } on Exception catch (e) {
      // 기타 모든 예외 처리
      // print('구글 로그인 실패: $e');
      throw Exception('구글 로그인에 실패했습니다.');
    }
  }

  Future<bool> kakaoLogin() async {
    try {
      // 1. KakaoTalk이 설치되어 있으면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
      final isInstalled = await isKakaoTalkInstalled();
      final kakaoLoginResult = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      // 2. 카카오 프로필 정보 가져오기
      final kakaoUser = await UserApi.instance.me();
      final String? nickname = kakaoUser.kakaoAccount?.profile?.nickname;
      final String? profileImageUrl =
          kakaoUser.kakaoAccount?.profile?.thumbnailImageUrl;

      // 3. Kakao에서 받은 accessToken을 Firebase Functions로 보내서 Custom Token 생성
      final customTokenResponse = await Client().post(
        Uri.parse('https://kakaologin-3ur24ugj5q-uc.a.run.app'),
        body: {'idToken': kakaoLoginResult.idToken},
      );

      if (customTokenResponse.statusCode != 200) {
        // print("Custom token 생성 실패: ${customTokenResponse.body}");
        return false;
      }

      final customToken = customTokenResponse.body;

      // 4. Firebase Custom Token으로 로그인
      final result = await firebase_auth.FirebaseAuth.instance
          .signInWithCustomToken(customToken);
      final user = result.user;

      if (user != null) {
        // Firebase 사용자 정보 업데이트
        await user.updateProfile(
          displayName: nickname,
          photoURL: profileImageUrl,
        );

        // 정보 업데이트 후 반드시 reload
        await user.reload();

        // ✅ 로그인 성공 시 UID를 전역 변수에 저장
        GlobalUserInfo.uid = user.uid;
        // print('✅ 전역 변수에 저장된 UID: ${GlobalUserInfo.uid}');

        return true;
      }
      return false;
    } on KakaoAuthException catch (e) {
      print("카카오 로그인 실패: ${e.message}");
    } on KakaoClientException catch (e) {
      print("카카오 클라이언트 에러: ${e.message}");
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Firebase 로그인 실패: ${e.message}");
    } catch (e) {
      print("알 수 없는 에러 발생: $e");
    }
    return false; // 예외 발생 시 false 반환
  }

  // Apple 로그인 처리
  Future<bool> signInWithApple() async {
    try {
      // Apple 로그인 인증
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
        ],
      );

      // Firebase에서 Apple ID로 로그인
      final firebase_auth.OAuthCredential appleCredential =
          firebase_auth.OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Firebase 인증
      final firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth.instance
          .signInWithCredential(appleCredential);
      final user = userCredential.user;

      // 사용자 정보 업데이트
      if (user != null) {
        // Apple 로그인에서 가져온 이메일
        final email = credential.email ?? user.email;

        // Firebase 사용자 정보 업데이트
        await user.updateProfile(
          displayName: email,
        );
        // 정보 업데이트 후 반드시 reload
        await user.reload();

        // ✅ 로그인 성공 시 UID를 전역 변수에 저장
        GlobalUserInfo.uid = user.uid;
        // print('✅ 전역 변수에 저장된 UID: ${GlobalUserInfo.uid}');

        return true;
      }
      return false;
    } on SignInWithAppleAuthorizationException catch (e) {
      // Apple 로그인 인증 관련 예외 처리
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          // print('사용자가 Apple 로그인을 취소했습니다.');
          break;
        case AuthorizationErrorCode.failed:
          // print('Apple 로그인 실패: ${e.message}');
          break;
        case AuthorizationErrorCode.invalidResponse:
          // print('Apple 로그인에서 잘못된 응답을 받았습니다.');
          break;
        case AuthorizationErrorCode.notHandled:
          // print('Apple 로그인 요청이 처리되지 않았습니다.');
          break;
        case AuthorizationErrorCode.unknown:
          // print('Apple 로그인에서 알 수 없는 오류가 발생했습니다.');
          break;
        case AuthorizationErrorCode.notInteractive:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
      throw Exception('Apple 로그인 실패: ${e.message}');
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Firebase 인증 관련 예외 처리
      // print('Firebase 인증 오류: ${e.message}');
      throw Exception('Firebase 인증에 실패했습니다: ${e.message}');
    } on SocketException {
      // 네트워크 오류 처리
      // print('네트워크 연결 오류: 인터넷 연결을 확인하세요.');
      throw Exception('네트워크 연결에 문제가 있습니다. 인터넷을 확인하세요.');
    } catch (e) {
      // 기타 예외 처리
      // print('Apple 로그인 중 알 수 없는 오류 발생: $e');
      throw Exception('Apple 로그인 중 오류가 발생했습니다.');
    }
  }

  Future<firebase_auth.UserCredential?> signInWithGoogle() async {
    try {
      // Google Sign In Flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Auth로 로그인
      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);

      // GlobalUserInfo 업데이트
      await GlobalUserInfo.getCurrentUserInfo();

      // print('구글 로그인 성공 - 현재 사용자: ${GlobalUserInfo.nickName}');

      return userCredential;
    } catch (e) {
      print('구글 로그인 중 에러 발생: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // 모든 로그인 정보 클리어
      await GoogleSignIn().signOut();
      await firebase_auth.FirebaseAuth.instance.signOut();

      // GlobalUserInfo 초기화
      GlobalUserInfo.clearUserInfo();

      // print('모든 로그인 정보가 삭제되었습니다.');
    } catch (e) {
      // print('로그아웃 중 에러 발생: $e');
      rethrow;
    }
  }

  // 회원 탈퇴
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // 1️⃣ Firestore에서 사용자 관련 모든 데이터 삭제
        await deleteUserData(user.uid);

        // 2️⃣ Firebase Authentication에서 사용자 삭제
        await user.delete();
      }
    } catch (e) {
      // print('회원 탈퇴 실패: $e');
      throw Exception('회원 탈퇴 실패: $e');
    }
  }

  // Firestore에서 사용자 데이터 삭제 함수
  Future<void> deleteUserData(String userId) async {
    try {
      final userRef = _firestore.collection('user').doc(userId);
      final myBooksRef = userRef.collection('my_books');
      final postRef = _firestore.collection('post');

      // 1️⃣ my_books 하위 컬렉션의 모든 문서 삭제
      final myBooksSnapshot = await myBooksRef.get();

      for (final doc in myBooksSnapshot.docs) {
        await doc.reference.delete();
      }
      // print('my_books 컬렉션 삭제 완료');

      // 2️⃣ post 컬렉션에서 userId가 동일한 문서 isDeleted = true로 변경
      final postsSnapshot =
          await postRef.where('userId', isEqualTo: userId).get();

      for (final doc in postsSnapshot.docs) {
        await doc.reference.update({'isDeleted': true});
      }

      // 3️⃣ user 문서 삭제
      await userRef.delete();
      // print('user 문서 삭제 완료');
    } catch (e) {
      // print('사용자 데이터 삭제 실패: $e');
      throw Exception('사용자 데이터 삭제 실패: $e');
    }
  }
}
