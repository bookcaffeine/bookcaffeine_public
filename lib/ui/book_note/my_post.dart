import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/ui/book_note/my_post_text.dart';
import 'package:bookcaffeine/ui/book_note/my_post_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MyPost extends StatefulWidget {
  const MyPost({super.key});

  @override
  State<MyPost> createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  bool isThumbnailView = true; // 썸네일 뷰 형식 여부를 저장하는 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text('내가 쓴 소감', style: AppTextStyle.heading4M.style),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            width: 24,
            height: 24,
            color: AppColors.grey800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isThumbnailView = !isThumbnailView; // 뷰 형식 전환
                });
              },
              child: Icon(
                isThumbnailView
                    ? Icons.view_agenda_outlined
                    : Icons.menu_book_outlined,
                color: AppColors.grey800,
              ),
            ),
          ),
        ],
      ),
      body: isThumbnailView
          ? const MyPostThumbnail() // 썸네일 뷰
          : const MyPostText(), // 텍스트 뷰
    );
  }
}
