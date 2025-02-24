import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/data/model/book_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Padding emotionTagBox(BookDetail bookDetailInfo, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('소감 키워드',
                  style: AppTextStyle.heading5SBold.style.copyWith(
                    color: AppColors.grey900,
                  )),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      actionsPadding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                      content: Text(
                        '소감 키워드는 독자들의 독서 소감을\n분석하여 AI가 만들어 주는 키워드입니다.',
                        style: AppTextStyle.heading5SBold.style.copyWith(
                          color: AppColors.grey800,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            '확인',
                            style: AppTextStyle.heading5SBold.style.copyWith(
                              color: AppColors.brown500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: SvgPicture.asset('assets/icons/question.svg'),
              )
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 9,
            children: (bookDetailInfo.bookInfo?.emotionTags ?? []).isEmpty
                ? [
                    Text(
                      '키워드를 분석할 소감이 부족합니다',
                      style: AppTextStyle.body2Regular.style.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                  ]
                : bookDetailInfo.bookInfo!.emotionTags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.brown500,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: AppColors.brown500,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
          ),
        ],
      ),
    ),
  );
}
