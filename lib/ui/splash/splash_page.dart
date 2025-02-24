import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentImageIndex = 0;

  final List<String> _images = [
    'assets/images/splash_page1.png',
    'assets/images/splash_page2.png',
    'assets/images/splash_page3.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadImageIndex(); // SharedPreferences에서 이미지 인덱스 불러오기
    _navigateToNextScreen(); // 네비게이션 처리
  }

  // SharedPreferences에서 이미지 인덱스를 불러오는 함수
  void _loadImageIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int? storedIndex = prefs.getInt('splash_image_index'); // 저장된 인덱스 가져오기

    if (storedIndex == null) {
      // 첫 실행이라면 첫 번째 이미지부터 시작
      storedIndex = 0;
    } else {
      // 인덱스를 순차적으로 업데이트
      storedIndex = (storedIndex + 1) % _images.length;
    }

    // 상태를 업데이트하여 화면에 반영
    setState(() {
      _currentImageIndex = storedIndex!;
    });

    // 인덱스를 저장
    prefs.setInt('splash_image_index', storedIndex);
  }

  Future<bool> checkUserExists() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return false;

    final docRef = FirebaseFirestore.instance.collection('user').doc(uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      // 사용자 문서가 없으면 로그아웃 처리
      // print("해당 UID의 문서가 존재하지 않아 로그아웃 처리합니다.");
      await FirebaseAuth.instance.signOut();
      return false;
    }

    return true;
  }

  // 2초 후에 화면 전환
  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 2));

    if (!context.mounted) return;

    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushReplacementNamed(context, '/login',
          arguments: _images[_currentImageIndex]);
    } else {
      bool userExists = await checkUserExists();
      if (userExists) {
        // print("해당 UID의 문서가 존재합니다.");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // print("해당 UID의 문서가 존재하지 않습니다.");
        Navigator.pushReplacementNamed(context, '/login',
            arguments: _images[_currentImageIndex]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Image.asset(
          _images[_currentImageIndex],
          width: double.infinity, // 화면 너비에 맞게
          height: double.infinity, // 화면 높이에 맞게
          fit: BoxFit.cover, // 이미지를 화면에 꽉 차게 표시
        ),
      ),
    );
  }
}
