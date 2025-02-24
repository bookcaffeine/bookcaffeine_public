import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:flutter/material.dart';

Column bookNameAuthors(String? title, String? authors) {
  return Column(
    children: [
      Text(
        title ?? '책 제목 없음',
        style: AppTextStyle.heading1.style.copyWith(
          color: AppColors.brown500,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        authors ?? '작가 정보 없음',
        style: AppTextStyle.heading6.style.copyWith(
          color: AppColors.grey800,
        ),
      ),
    ],
  );
}
