import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:flutter/material.dart';

final theme = ThemeData(
  scaffoldBackgroundColor: AppColors.backgroundColor,
  primarySwatch: Colors.brown,
  fontFamily: 'Pretendard',
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.backgroundColor,
    titleTextStyle: AppTextStyle.heading4M.style.copyWith(
      color: AppColors.grey800,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.grey900,
      size: 24,
    ),
  ),
);
