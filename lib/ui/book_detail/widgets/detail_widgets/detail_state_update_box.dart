import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';
import 'package:bookcaffeine/ui/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DetailStateUpdateBoxWidget extends StatefulWidget {
  final bool isDetail;
  final BookDetailViewModel bookDetailVm;
  final HomeViewModel homeVm;
  final String bookId;
  final String? bookState;

  const DetailStateUpdateBoxWidget({
    super.key,
    required this.isDetail,
    required this.bookDetailVm,
    required this.homeVm,
    required this.bookId,
    this.bookState,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StateUpdateBoxWidgetState createState() => _StateUpdateBoxWidgetState();
}

class _StateUpdateBoxWidgetState extends State<DetailStateUpdateBoxWidget> {
  late String? selectedState;
  late String dbValue;

  final GlobalKey _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    selectedState = stateToDbValue.containsValue(widget.bookState)
        ? stateToDbValue.keys
            .firstWhere((key) => stateToDbValue[key] == widget.bookState)
        : '읽을 예정';
    dbValue = stateToDbValue[selectedState]!;
  }

  void updateState(newValue) {
    setState(() {
      selectedState = newValue;
      dbValue = stateToDbValue[newValue]!;
    });
  }

  final Map<String, String> stateToDbValue = {
    '읽는 중': 'current',
    '읽을 예정': 'upcoming',
    '독서 완료': 'finish',
  };

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
                    selectedState ?? "읽을 예정",
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
                  final RenderBox button = _dropdownKey.currentContext!
                      .findRenderObject() as RenderBox;
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
                    items: stateToDbValue.keys.map((String value) {
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
                    updateState(result);
                    widget.bookDetailVm
                        .handleUpdateMyBooksState(widget.bookId, dbValue);
                    widget.homeVm.fetchData();
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
