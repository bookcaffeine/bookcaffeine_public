import 'dart:io';

import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/ui/login/login_view_model.dart';
import 'package:bookcaffeine/ui/login/widgets/agreement.dart';
import 'package:bookcaffeine/ui/login/widgets/apple_login_btn.dart';
import 'package:bookcaffeine/ui/login/widgets/google_login_btn.dart';
import 'package:bookcaffeine/ui/login/widgets/kakao_login_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginViewModel = ref.read(loginViewModelProvider.notifier);

    // ✅ `Platform.isIOS`를 build 함수 내에서 직접 호출하지 않도록 변수로 분리
    final bool isIOS = !kIsWeb && Platform.isIOS;

    // 전달받은 이미지 경로
    final String? imagePath =
        ModalRoute.of(context)?.settings.arguments as String?;

    Future<bool> checkUserExists() async {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) return false; // 로그인되지 않은 경우 false 반환

      final docRef = FirebaseFirestore.instance.collection('user').doc(uid);
      final docSnapshot = await docRef.get();

      return docSnapshot.exists; // 문서가 존재하면 true, 없으면 false
    }

    void changeRoute() async {
      bool userExists = await checkUserExists();
      if (userExists) {
        // 회원가입된 사용자는 홈 페이지로 이동
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // 회원가입 되어있지 않은 첫 방문 유저는 프로필 페이지로 이동
        Navigator.pushReplacementNamed(
          context,
          '/profile',
          arguments: {'isNewUser': true}, // 새로운 사용자임을 표시
        );
      }
    }

    // 'splash_page2.png'일 경우 텍스트 색상 변경
    final bool isSpecialImage = imagePath == 'assets/images/splash_page2.png';
    final textColor = isSpecialImage ? Colors.black : AppColors.white;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Stack 위젯이 화면 전체를 채우도록 설정
        children: [
          // 전달받은 이미지 배경
          imagePath != null && imagePath.isNotEmpty
              ? (imagePath == 'assets/images/splash_page2.png'
                  ? Image.asset(
                      'assets/images/splash_page2_1.png',
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ))
              : Image.asset(
                  'assets/images/splash_page1.png',
                  fit: BoxFit.cover,
                ),

          // 이미지 위에 올라갈 로그인 UI
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ✅ iOS에서만 카카오 로그인 버튼 표시
                  if (isIOS) ...[
                    // 카카오 로그인 버튼
                    kakaoLoginBtn(loginViewModel, changeRoute, context),
                    const SizedBox(height: 15),
                  ],

                  // 구글 로그인 버튼
                  googleLoginBtn(loginViewModel, changeRoute, context),
                  const SizedBox(height: 15),

                  // ✅ iOS에서만 애플 로그인 버튼 표시
                  if (isIOS) ...[
                    appleLoginBtn(loginViewModel, changeRoute, context),
                    const SizedBox(height: 15),
                  ],

                  agreement(textColor, context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
