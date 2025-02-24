import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:flutter/cupertino.dart';

class BooksItem extends StatelessWidget {
  /// homepage 읽고 있는책 문구 표시
  const BooksItem({
    super.key,
    required this.text,
    required this.numbers,
    required this.readingState,
  });
  final String text;
  final int? numbers;

  /// 독서 상태: currentBooks-독서중, finishedBooks-독서완료, upcomingBooks-읽을 책
  final String? readingState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            text,
            style: AppTextStyle.heading5SBold.style.copyWith(
              color: AppColors.grey900,
            ),
          ),
          SizedBox(width: 6),
          Container(
            width: 25,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.brown500,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: Text(
                '$numbers',
                style: TextStyle(
                  color: AppColors.brown50,
                  fontSize: 12,
                  height: 1.50,
                ),
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
