import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/filled_buttons.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

SafeArea bookDetailBottom(BuildContext context, String bookId) {
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
      child: FilledButtons.h48(
        text: '소감쓰기',
        backgroundColor: AppColors.brown500,
        onPressed: () {
          FirebaseAnalytics.instance.logEvent(
            name: "POST_CREATE_EVENT",
          );
          Navigator.pushNamed(
            context,
            '/write',
            arguments: {
              'bookId': bookId,
              'postId': null,
              'isModify': false,
              'review': null,
            },
          );
        },
      ),
    ),
  );
}
