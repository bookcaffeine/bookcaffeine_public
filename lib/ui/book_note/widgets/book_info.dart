import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/data/model/book.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookInfo extends StatelessWidget {
  final Book book;
  final DateTime createdAt;
  final VoidCallback? onTap;

  const BookInfo({
    super.key,
    required this.book,
    required this.createdAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              // 책 표지
              Image.network(
                book.thumbnail ?? '',
                width: 68,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 68,
                  height: 100,
                  color: AppColors.grey200,
                  child: Container(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 책 제목
                    Text(
                      book.title ?? '',
                      style: AppTextStyle.heading5SBold.style.copyWith(
                        color: AppColors.grey900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 저자
                    Text.rich(
                      TextSpan(
                        style: AppTextStyle.heading6.style.copyWith(
                          color: AppColors.grey700,
                        ),
                        children: _buildAuthorTextSpans(
                          book.authors.map((e) => e ?? '').toList(),
                          book.translators.map((e) => e ?? '').toList(),
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),
                    // 출판사
                    Text(
                      book.publisher ?? '',
                      style: AppTextStyle.heading6.style.copyWith(
                        color: AppColors.grey700,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 작성일
                    Text(
                      DateFormat('yyyy.MM.dd').format(createdAt),
                      style: AppTextStyle.heading6.style.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildAuthorTextSpans(
      List<String> authors, List<String> translators) {
    final List<TextSpan> spans = [];

    if (authors.isNotEmpty) {
      spans.add(TextSpan(text: authors.join(', ')));
      spans.add(TextSpan(
        text: ' 저',
        style: TextStyle(color: AppColors.grey500),
      ));
    }

    if (translators.isNotEmpty) {
      if (spans.isNotEmpty) {
        spans.add(TextSpan(text: ' / '));
      }
      spans.add(TextSpan(text: translators.join(', ')));
      spans.add(TextSpan(
        text: ' 역',
        style: TextStyle(color: AppColors.grey500),
      ));
    }

    return spans;
  }
}
