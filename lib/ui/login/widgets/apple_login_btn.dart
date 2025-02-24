import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/ui/login/login_view_model.dart';
import 'package:flutter/material.dart';

GestureDetector appleLoginBtn(LoginViewModel loginViewModel,
    void Function() changeRoute, BuildContext context) {
  return GestureDetector(
    onTap: () async {
      try {
        bool loginSuccess = await loginViewModel.appleLogin();
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
    child: SizedBox(
      height: 44,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/apple_logo.png',
              width: 20,
              height: 20,
            ),
            const Spacer(),
            const Text(
              '애플 로그인',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                fontFamily: "SF Pro",
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    ),
  );
}
