import 'package:flutter/material.dart';

Center divider(BuildContext context) {
  return Center(
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.9, // 가로 길이 80%
      child: Divider(
        color:
            Colors.grey[200], // 연한 회색 (Colors.grey[300] ~ Colors.grey[400] 추천)
        thickness: 1, // 선 두께 (필요하면 조절 가능)
      ),
    ),
  );
}
