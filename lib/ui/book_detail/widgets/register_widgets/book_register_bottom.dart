import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/filled_buttons.dart';
import 'package:bookcaffeine/data/model/book.dart';
import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';
import 'package:bookcaffeine/ui/home/home_view_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

Widget registerBottom(
    BuildContext context,
    Book book,
    BookDetailViewModel bookDetailVm,
    HomeViewModel homeVm,
    String dbState,
    bool isBookRegistered) {
  return SafeArea(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.grey300,
            width: 1,
          ),
        ),
      ),
      child: isBookRegistered
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center, // 수평 중앙 정렬
              children: [
                Text(
                  '이미 등록되어있는 책입니다.',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold), // 필요한 스타일 적용
                ),
              ],
            )
          : FilledButtons.h48(
              text: '책 추가하기',
              backgroundColor: AppColors.brown500,
              onPressed: () async {
                FirebaseAnalytics.instance.logEvent(
                  name: "BOOK_REGISTER_EVENT",
                );
                await bookDetailVm.handleinsertBook(book, dbState);
                await homeVm.fetchData();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
              },
            ),
    ),
  );
}
