import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';
import 'package:bookcaffeine/ui/home/home_view_model.dart';
import 'package:flutter/material.dart';

PopupMenuItem topMenuItem(
  BuildContext context,
  String bookId,
  final HomeViewModel homeVm,
  final BookDetailViewModel bookDetailVm,
) {
  return PopupMenuItem(
    enabled: true,
    onTap: () async {
      await bookDetailVm.handleDeleteMyBooks(bookId);
      await homeVm.fetchData();
      // 팝업 메뉴 닫기
      Navigator.pop(context);
    },
    child: Center(child: Text('삭제')),
  );
}
