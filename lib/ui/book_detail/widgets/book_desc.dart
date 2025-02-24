import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:expandable_text/expandable_text.dart';

ExpandableText bookDesc(String? contents) {
  // $amp; 를 &로 치환
  String processedContents = contents?.replaceAll('&amp;', '&') ?? "책 소개 없음";

  return ExpandableText(
    processedContents,
    expandText: '더보기',
    collapseText: '접기',
    maxLines: 3,
    linkColor: AppColors.brown500,
    style: AppTextStyle.body2Regular.style.copyWith(
      color: AppColors.grey900,
    ),
  );
}
