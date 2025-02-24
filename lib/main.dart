import 'dart:async';

import 'package:bookcaffeine/core/them.dart';
import 'package:bookcaffeine/firebase_options.dart';
import 'package:bookcaffeine/ui/book_detail/book_detail_page.dart';
import 'package:bookcaffeine/ui/book_detail/book_register_page.dart';
import 'package:bookcaffeine/ui/book_note/book_note_page.dart';
import 'package:bookcaffeine/ui/book_note/my_post.dart';
import 'package:bookcaffeine/ui/book_note/my_post_text.dart';
import 'package:bookcaffeine/ui/book_note/my_post_thumbnail.dart';
import 'package:bookcaffeine/ui/book_search/book_search_page.dart';
import 'package:bookcaffeine/ui/home/home_page.dart';
import 'package:bookcaffeine/ui/login/login_page.dart';
import 'package:bookcaffeine/ui/mypage/my_like_page.dart';
import 'package:bookcaffeine/ui/mypage/my_page.dart';
import 'package:bookcaffeine/ui/profile/profile_page.dart';
import 'package:bookcaffeine/ui/setting/agreement/widget/personal_info.dart';
import 'package:bookcaffeine/ui/setting/agreement/widget/service_info.dart';
import 'package:bookcaffeine/ui/setting/notice/notice_page.dart';
import 'package:bookcaffeine/ui/setting/agreement/agreement_page.dart';
import 'package:bookcaffeine/ui/setting/alert/alert_settings_page.dart';
import 'package:bookcaffeine/ui/setting/question/question_page.dart';
import 'package:bookcaffeine/ui/setting/setting_page.dart';
import 'package:bookcaffeine/ui/sns_my_page/sns_my_page.dart';
import 'package:bookcaffeine/ui/splash/splash_page.dart';
import 'package:bookcaffeine/ui/write/write_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

void main() async {
  // runZonedGuarded로 전체 초기화 과정을 감싸기
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Firebase Crashlytics 설정
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // 소셜 로그인 SDK 초기화
    KakaoSdk.init(nativeAppKey: dotenv.env["KAKAO_API_KEY"]);
    // Google Sign In은 Firebase.initializeApp()만으로 자동 초기화됨
    // Apple Sign In은 별도 초기화 필요 없음

    // 환경변수 로드
    await dotenv.load(fileName: ".env");

    // 앱 실행
    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/agreement': (context) => const AgreementPage(),
        '/personal_info': (context) => const PersonalInfoPage(),
        '/service_info': (context) => const ServiceInfoPage(),
        '/mypage': (context) => const MyPage(),
        '/setting': (context) => const SettingPage(),
        '/book_detail': (context) => const BookDetailPage(),
        '/book_register': (context) => const BookRegisterPage(),
        '/book_search': (context) => const BookSearchPage(),
        '/profile': (context) => const ProfilePage(),
        '/write': (context) => WritePage(),
        '/alert_settings': (contest) => const AlertSettingsPage(),
        '/notice': (context) => const NoticePage(),
        '/question': (context) => const QuestionPage(),
        '/book_note': (context) => const BookNotePage(),
        '/my_post': (context) => const MyPost(),
        '/my_post_text': (context) => const MyPostText(),
        '/my_post_thumbnail': (context) => const MyPostThumbnail(),
        '/my_like': (context) => const MyLikePage(),
        '/sns_my_page': (context) => const SnsMyPage(),
      },
      title: 'Home Page',
      theme: theme,
      home: const SplashScreen(),
    );
  }
}
