import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/ui/home/home_view_model.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookcaffeine/ui/setting/setting_view_model.dart';
import 'package:flutter_svg/svg.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  @override
  void initState() {
    super.initState();
    // 프로필 설정 페이지 진입 시 GlobalUserInfo 상태 확인
    print(
        '프로필 설정 페이지 진입 - GlobalUserInfo.nickName: ${GlobalUserInfo.nickName}');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(settingViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            width: 24,
            height: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 280,
                child: Column(
                  children: [
                    _setting(
                      context: context,
                      icon: 'assets/icons/user.svg',
                      title: '프로필 설정',
                      route: '/profile',
                      arguments: {
                        'isNewUser': false,
                      },
                    ),
                    _setting(
                      context: context,
                      icon: 'assets/icons/headphones.svg',
                      title: '1:1 문의',
                      route: '/question',
                    ),
                    // _setting(
                    //   context: context,
                    //   icon: 'assets/icons/clock.svg',
                    //   title: '알림 설정',
                    //   route: '/alert_settings',
                    // ),
                    _setting(
                      context: context,
                      icon: 'assets/icons/bell.svg',
                      title: '공지사항',
                      route: '/notice',
                    ),
                    _setting(
                      context: context,
                      icon: 'assets/icons/file.svg',
                      title: '약관 동의',
                      route: '/agreement',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              _authenticationBtn(
                context: context,
                ref: ref,
                title: '로그아웃',
              ),
              const SizedBox(height: 16),
              _authenticationBtn(
                context: context,
                ref: ref,
                title: '회원탈퇴',
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Center(
                  child: Text(
                    '현재 버전 1.1.0',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          if (viewModel.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _authenticationBtn({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
  }) {
    return GestureDetector(
      onTap: () async {
        if (title == '로그아웃') {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                '로그아웃',
                textAlign: TextAlign.center,
                style: AppTextStyle.heading5SBold.style,
              ),
              content: Text(
                '정말로 로그아웃 하시겠습니까?',
                textAlign: TextAlign.center,
                style: AppTextStyle.heading6R.style,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              actionsPadding: EdgeInsets.zero,
              actions: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.grey900,
                            padding: const EdgeInsets.symmetric(
                                vertical: 11, horizontal: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          child: Text(
                            '로그아웃',
                            style: AppTextStyle.heading6R.style.copyWith(
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 52,
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                vertical: 11, horizontal: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: AppTextStyle.heading6R.style.copyWith(
                              color: Color(0xFFFF3B30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            try {
              await ref.read(settingViewModelProvider.notifier).signOut();
              await ref.read(homeViewModelProvider.notifier).clearState();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('로그아웃 실패: $e')),
                );
              }
            }
          }
        } else if (title == '회원탈퇴') {
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                '회원탈퇴',
                textAlign: TextAlign.center,
                style: AppTextStyle.heading5SBold.style,
              ),
              content: Text(
                '정말 탈퇴하시겠습니까?\n모든 데이터가 삭제됩니다.',
                textAlign: TextAlign.center,
                style: AppTextStyle.heading6R.style,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              actionsPadding: EdgeInsets.zero,
              actions: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => {
                            FirebaseAnalytics.instance.logEvent(
                              name: "ACCOUNT_DELETION_EVENT",
                            ),
                            Navigator.pop(context, true)
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.grey900,
                            padding: const EdgeInsets.symmetric(
                                vertical: 11, horizontal: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          child: Text(
                            '회원탈퇴',
                            style: AppTextStyle.heading6R.style.copyWith(
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 52,
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                vertical: 11, horizontal: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: AppTextStyle.heading6R.style.copyWith(
                              color: Color(0xFFFF3B30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          if (shouldDelete == true) {
            try {
              await ref.read(settingViewModelProvider.notifier).deleteAccount();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('회원탈퇴 실패: $e')),
                );
              }
            }
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text(title),
        ),
      ),
    );
  }

  Widget _setting({
    required BuildContext context,
    required String icon,
    required String title,
    required String route,
    Map<String, dynamic>? arguments,
  }) {
    return GestureDetector(
      onTap: () {
        print('Navigating to $route with arguments: $arguments'); // 디버깅용
        Navigator.of(context).pushNamed(
          route,
          arguments: arguments,
        );
      },
      child: _agreement(icon, title),
    );
  }

  Container _agreement(String icon, String title) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: AppColors.grey200, width: 1),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.grey800,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
          const Spacer(),
          SvgPicture.asset(
            'assets/icons/chevron-right.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.grey900,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
