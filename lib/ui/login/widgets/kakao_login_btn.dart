import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/ui/login/login_view_model.dart';
import 'package:flutter/material.dart';

GestureDetector kakaoLoginBtn(LoginViewModel loginViewModel,
    void Function() changeRoute, BuildContext context) {
  return GestureDetector(
    onTap: () async {
      try {
        bool loginSuccess = await loginViewModel.kakaoLogin();
        if (loginSuccess) {
          changeRoute();
        } else {
          // 로그인 취소 또는 실패 시 로그인 페이지 유지
          // print('사용자가 로그인 취소 또는 로그인 실패');
        }
      } catch (error) {
        // print('$error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed')),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: Color(0xFFFEE500),
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/kakao_logo.png',
            width: 20,
            height: 20,
          ),
          const Spacer(),
          Text(
            '카카오 로그인',
            style: TextStyle(
              fontSize: 16,
              fontWeight: AppTextStyle.heading5SBold.style.fontWeight,
            ),
          ),
          const Spacer(),
        ],
      ),
    ),
  );
}
