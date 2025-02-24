import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/ui/login/login_view_model.dart';
import 'package:flutter/material.dart';

GestureDetector googleLoginBtn(LoginViewModel loginViewModel,
    void Function() changeRoute, BuildContext context) {
  return GestureDetector(
    onTap: () async {
      // print('Google 로그인 버튼 클릭');
      try {
        bool loginSuccess = await loginViewModel.googleLogin();
        if (loginSuccess) {
          changeRoute();
        } else {
          // 로그인 취소 또는 실패 시 로그인 페이지 유지
          print('사용자가 로그인 취소 또는 로그인 실패');
        }
      } catch (error) {
        // print('$error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed')),
        );
      }
    },
    child: SizedBox(
      height: 44,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 배경색
          borderRadius: BorderRadius.circular(4.0), // 모서리 둥글게
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              spreadRadius: 0.5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png',
              width: 20,
              height: 20,
            ),
            Spacer(),
            Text(
              '구글 로그인',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: AppTextStyle.heading5SBold.style.fontWeight,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    ),
  );
}
