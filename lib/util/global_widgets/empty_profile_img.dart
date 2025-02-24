import 'package:flutter/material.dart';

Container emptyProfileImg({bool post = false}) {
  return Container(
    width: post ? 32 : 100,
    height: post ? 32 : 100,
    color: Colors.grey[200], // 원하는 색상으로 배경 설정
    child: Icon(
      Icons.person, // 기본 아이콘, 원하는 아이콘으로 변경 가능
      size: post ? 20 : 40,
      color: Colors.grey[600], // 아이콘 색상
    ),
  );
}
