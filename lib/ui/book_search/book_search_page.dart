import 'dart:async';

import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_icons.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/ui/book_search/book_search_page_view_model.dart';
import 'package:bookcaffeine/ui/book_search/widget/book_list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class BookSearchPage extends ConsumerStatefulWidget {
  const BookSearchPage({super.key});

  @override
  ConsumerState<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends ConsumerState<BookSearchPage> {
  final controller = TextEditingController();

  /// debounce(자동 검색)을 위한 시간
  Timer? _debounce;
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    _debounce?.cancel();
  }

  /// textfield 지우기 method
  void textfieldClear() {
    controller.clear();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// 타이핑 도중 자동완성 함수
  void onSearchChanged(String query) {
    // 함수가 실행되는데 타이머가 돌아가고 있으면 기존 타이머 취소 후 다시 실행됨
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (query.trim().isNotEmpty) {
        ref.read(bookSearchViewModel.notifier).searchBooks(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(bookSearchViewModel.notifier);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset(
              'assets/icons/chevron-left.svg',
              width: 24,
              height: 24,
            ),
          ),
          title: Text(
            '책 검색',
            style: AppTextStyle.heading4M.style.copyWith(
              color: AppColors.grey900,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 32),
              TextFormField(
                cursorColor: AppColors.brown500,
                onFieldSubmitted: vm.searchBooks,
                autofocus: true,
                onChanged: onSearchChanged,
                autovalidateMode: AutovalidateMode.always,
                controller: controller,
                validator: (value) {
                  // 문자열 앞뒤 제거
                  if (value?.trim().isEmpty ?? true) {
                    return '';
                  }
                  // 유효성 검사 성공
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                        top: 12, bottom: 12, left: 12, right: 8),
                    child: AppIcons.search,
                  ),
                  labelText: '읽고 계신 책을 검색해보세요!',
                  labelStyle: AppTextStyle.heading4M.style
                      .copyWith(color: AppColors.grey800),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: '책, 제목, 작가 이름, ISBN 중 입력',
                  hintStyle: AppTextStyle.heading4M.style
                      .copyWith(color: AppColors.grey500),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: AppColors.grey600,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: AppColors.brown500,
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: AppColors.grey600,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: AppColors.brown500,
                      width: 1,
                    ),
                  ),
                  suffixIcon: controller.text != ''
                      ? IconButton(
                          onPressed: textfieldClear,
                          icon: const Icon(
                            CupertinoIcons.clear_circled_solid,
                            color: Colors.grey,
                          ),
                        )
                      : SizedBox(),
                ),
              ),
              SizedBox(height: 8),
              BookListView(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
