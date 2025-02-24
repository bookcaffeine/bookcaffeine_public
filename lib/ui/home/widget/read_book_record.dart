import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:flutter/material.dart';

class ReadBookRecord extends StatelessWidget {
  /// homepage 기간 별로 읽은 책수
  ReadBookRecord({
    super.key,
    required this.readBooks,
    required this.dateUnit,
  });

  /// (월간, 연간, 누적) 읽은 책수
  int? readBooks = 0;

  /// 월간독서, 연간독서, 누적독서
  String dateUnit;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: Text(
            '$readBooks',
            style: AppTextStyle.heading3.style.copyWith(
              color: AppColors.grey800,
            ),
          ),
        ),
        SizedBox(
          child: Text(
            dateUnit,
            style: AppTextStyle.heading6R.style.copyWith(
              color: AppColors.grey700,
            ),
          ),
        ),
      ],
    );
  }
}
