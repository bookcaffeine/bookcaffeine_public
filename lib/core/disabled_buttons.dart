import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:flutter/material.dart';

/// FilledButtons.h48(text: '예시입니다.',onPressed: () {}}
class LinedButtons extends StatelessWidget {
  LinedButtons.h56({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
  })  : height = 56,
        textStyle = AppTextStyle.heading5R.style.copyWith(
          color: AppColors.white,
        );

  LinedButtons.h48({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
  })  : height = 48,
        textStyle = AppTextStyle.heading5R.style.copyWith(
          color: AppColors.white,
        );

  LinedButtons.h40({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
  })  : height = 40,
        textStyle = AppTextStyle.heading5R.style.copyWith(
          color: AppColors.white,
        );

  LinedButtons.h36({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
  })  : height = 36,
        textStyle = AppTextStyle.heading6.style.copyWith(
          color: AppColors.white,
        );

  LinedButtons.h32({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
  })  : height = 32,
        textStyle = AppTextStyle.heading6.style.copyWith(
          color: AppColors.white,
        );

  LinedButtons.h28({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
  })  : height = 28,
        textStyle = AppTextStyle.heading6.style.copyWith(
          color: AppColors.white,
        );

  final String text;
  final double? height;
  final void Function()? onPressed;
  final Color? backgroundColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey300,
      ),
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }
}
