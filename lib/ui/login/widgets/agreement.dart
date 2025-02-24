import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Text agreement(Color textColor, BuildContext context) {
  return Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '로그인 시, ',
          style: AppTextStyle.heading6.style.copyWith(
            color: textColor,
          ),
        ),
        TextSpan(
          text: '이용약관/개인정보처리방침',
          style: AppTextStyle.heading6.style.copyWith(
            color: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.pushNamed(context, '/agreement');
            },
        ),
        TextSpan(
          text: '이 적용됩니다.',
          style: AppTextStyle.heading6.style.copyWith(
            color: textColor,
          ),
        ),
      ],
    ),
  );
}
