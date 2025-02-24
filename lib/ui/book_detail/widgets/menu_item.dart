import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:flutter/material.dart';

PopupMenuItem menuItem(String text, BuildContext context, String postId,
    String bookId, final BookDetailViewModel bookDetailVm, String? review) {
  return PopupMenuItem(
    enabled: true,
    onTap: () async {
      if (text == "신고") {
        await Future.wait([
          bookDetailVm.handleReportPost(GlobalUserInfo.uid!, postId),
          bookDetailVm.fetchBookDetailInfo(bookId),
        ]);
      } else if (text == "수정") {
        Navigator.pushNamed(
          context,
          '/write',
          arguments: {
            'isModify': true,
            'postId': postId,
            'bookId': bookId,
            'review': review,
          },
        );
      } else if (text == "삭제") {
        await Future.wait([
          bookDetailVm.handleDeletePost(postId),
          bookDetailVm.fetchBookDetailInfo(bookId),
        ]);
      }
    },
    child: Center(child: Text(text)),
  );
}
