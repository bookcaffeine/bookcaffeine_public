import 'package:bookcaffeine/ui/mypage/widget/current_books.dart';
import 'package:bookcaffeine/ui/mypage/widget/finish_books.dart';
import 'package:bookcaffeine/ui/mypage/widget/upcoming_books.dart';
import 'package:flutter/material.dart';

TabBarView tabBarView(String userId) {
  return TabBarView(
    children: [
      CurrentBooks(
        userId: userId,
        isMySns: true,
      ),
      UpcomingBooks(
        userId: userId,
        isMySns: true,
      ),
      FinishBooks(
        userId: userId,
        isMySns: true,
      ),
    ],
  );
}
