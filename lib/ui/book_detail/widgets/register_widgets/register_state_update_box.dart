import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_svg/flutter_svg.dart';

class RegisterStateUpdateBox extends StatefulWidget {
  final Function(String) updateState;
  final String selectedState;
  final Map<String, String> stateToDbValue;

  const RegisterStateUpdateBox(
      {required this.updateState,
      required this.selectedState,
      required this.stateToDbValue});

  @override
  _RegisterStateUpdateBoxState createState() => _RegisterStateUpdateBoxState();
}

class _RegisterStateUpdateBoxState extends State<RegisterStateUpdateBox> {
  final GlobalKey _dropdownKey =
      GlobalKey(); // ✅ GlobalKey를 StatefulWidget에서 관리

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _dropdownKey, // GlobalKey 등록
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.brown400,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 체크 아이콘 + 상태 텍스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check,
                    color: const Color(0xFF00B650),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.selectedState,
                    style: AppTextStyle.heading5SBold.style.copyWith(
                      color: AppColors.brown500,
                    ),
                  ),
                ],
              ),
            ),
            // 구분선
            Container(
              width: 1,
              color: AppColors.brown400,
            ),
            // 드롭다운 버튼
            SizedBox(
              height: 36,
              width: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: SvgPicture.asset(
                  'assets/icons/chevron-down.svg',
                  colorFilter:
                      ColorFilter.mode(AppColors.brown400, BlendMode.srcIn),
                ),
                onPressed: () async {
                  final RenderBox? button = _dropdownKey.currentContext
                      ?.findRenderObject() as RenderBox?;

                  if (button == null) {
                    // print("Error: Dropdown button is not found.");
                    return;
                  }

                  final RenderBox overlay = Overlay.of(context)
                      .context
                      .findRenderObject() as RenderBox;

                  // 정확한 위치 계산
                  final position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(button.size.bottomLeft(Offset.zero),
                          ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero),
                          ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );

                  final result = await showMenu<String>(
                    context: context,
                    position: position,
                    color: Colors.white, // 드롭다운 배경색
                    items: widget.stateToDbValue.keys.map((String value) {
                      return PopupMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              color: const Color(0xFF00B650),
                              size: 20,
                            ),
                            const SizedBox(width: 8), // 아이콘과 텍스트 간격
                            Text(
                              value,
                              style: AppTextStyle.heading5SBold.style.copyWith(
                                color: AppColors.brown500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );

                  if (result != null) {
                    widget.updateState(result);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
