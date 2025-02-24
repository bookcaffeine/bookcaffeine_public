import 'dart:ui';

import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';
import 'package:bookcaffeine/ui/book_detail/widgets/detail_widgets/book_delete_menu_item.dart';
import 'package:bookcaffeine/ui/home/home_view_model.dart';
import 'package:bookcaffeine/util/global_widgets/empty_book_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

SizedBox bookCover(BuildContext context, bool isDetail, HomeViewModel homeVm,
    BookDetailViewModel bookDetailVm, String? thumbnail, String bookId) {
  return SizedBox(
    height: MediaQuery.of(context).size.height / 2.8,
    child: Stack(
      children: [
        // ✅ 배경 이미지 + 블러 효과
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: thumbnail == null || thumbnail.isEmpty
                ? null // 배경 이미지는 설정하지 않음
                : DecorationImage(
                    image: NetworkImage(thumbnail), // 실제 썸네일 이미지
                    fit: BoxFit.cover,
                  ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              alignment: Alignment.center,
              child: (thumbnail == null || thumbnail.isEmpty)
                  ? emptyBookCover("책 표지가 없습니다.")
                  : Image.network(thumbnail), // 네트워크 이미지
            ),
          ),
        ),

        Positioned(
          top: 10,
          left: 10,
          child: SafeArea(
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/chevron-left.svg',
                width: 24,
                height: 24,
              ),
              onPressed: () async {
                await homeVm.fetchData();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
            ),
          ),
        ),

        // 상세 페이지일 경우에만 우측 상단 삭제 버튼 생성
        isDetail
            ? Positioned(
                top: 10,
                right: 10,
                child: SafeArea(
                  child: PopupMenuButton(
                    icon: SvgPicture.asset(
                      'assets/icons/arrow-right.svg',
                    ),
                    iconColor: AppColors.black,
                    position: PopupMenuPosition.over,
                    color: Colors.white,
                    itemBuilder: (context) {
                      return [
                        topMenuItem(context, bookId, homeVm, bookDetailVm),
                      ];
                    },
                  ),
                ),
              )
            : Container()
      ],
    ),
  );
}
