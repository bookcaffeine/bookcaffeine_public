import 'package:bookcaffeine/core/app_colors.dart';
import 'package:flutter/material.dart';

/// 글자쓰기 Text("글자 예시 입니다.", style: AppTextStyle.heading1.style);

enum AppTextStyle {
  /// Pretendard, Semibold, 24, 1.35
  heading1(
    TextStyle(
      fontSize: 24,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
  ),

  ///Pretendard, Semibold, 22, 1.35
  heading2(
    TextStyle(
      fontSize: 22,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
  ),

  ///(default) Pretendard, Semibold 20, 1.40
  heading3(
    TextStyle(
      fontSize: 20,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      height: 1.40,
    ),
  ),

  /// Pretendard, Medium 18, 1.45
  heading4M(
    TextStyle(
      fontSize: 18,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      height: 1.45,
    ),
  ),

  /// Pretendard, Regular 18, 1.45
  heading4R(TextStyle(
    fontSize: 18,
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400,
    height: 1.45,
  )),

  /// Pretendard, Semibold 16, 1.50
  heading5SBold(
    TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      height: 1.50,
    ),
  ),

  /// Pretendard, Regular 16, 1.50
  heading5R(
    TextStyle(
      color: AppColors.white,
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      height: 1.50,
    ),
  ),

  /// Pretendard, Medium 14, 14, 1.40
  heading6(
    TextStyle(
      fontSize: 14,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      height: 1.40,
    ),
  ),

  ///Pretendard, Medium 14, 14, 1.40
  ///
  heading6R(
    TextStyle(
      fontSize: 14,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      height: 1.40,
      letterSpacing: 14 * 0.005,
    ),
  ),

  /// Pretendard, Medium, 12, 1.50
  heading7(
    TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      height: 1.50,
    ),
  ),

  /// Eulyou1945, SemiBold 16, 1.50
  body1Bold(
    TextStyle(
      fontSize: 16,
      fontFamily: 'Eulyoo1945',
      fontWeight: FontWeight.w600,
      height: 1.50,
    ),
  ),

  /// Eulyou1945, Regular 16, 1.50
  body1Regular(
    TextStyle(
      fontSize: 16,
      fontFamily: 'Eulyoo1945',
      fontWeight: FontWeight.w400,
      height: 1.50,
    ),
  ),

  /// Eulyou1945, Semibold 14, 1.55
  body2Semibold(
    TextStyle(
      fontSize: 14,
      fontFamily: 'Eulyoo1945',
      fontWeight: FontWeight.w600,
      height: 1.55,
    ),
  ),

  /// Eulyou1945, Regular 14, 1.55
  body2Regular(
    TextStyle(
      fontSize: 14,
      fontFamily: 'Eulyoo1945',
      fontWeight: FontWeight.w400,
      height: 1.55,
    ),
  ),

  /// Pretendard, Bold 12, 1.50
  detailSemibold(
    TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w700,
      height: 1.50,
    ),
  ),

  /// Pretendard, Regular 12, 1.50
  detailRegular(
    TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      height: 1.50,
    ),
  );

  final TextStyle style;
  const AppTextStyle(this.style);
}
