import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/core/filled_buttons.dart';
import 'package:bookcaffeine/data/repository/user_repository.dart';
import 'package:bookcaffeine/ui/profile/profile_page_view_model.dart';
import 'package:bookcaffeine/ui/profile/widget/text_field.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:bookcaffeine/util/global_widgets/empty_profile_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final TextEditingController _nickNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      if (GlobalUserInfo.uid == null) {
        // 로그인되지 않은 상태 처리
        // print('로그인이 필요합니다.');
        return;
      }

      await ref.read(profileViewModelProvider.notifier).loadUserProfile();

      if (mounted) {
        final viewModel = ref.read(profileViewModelProvider);
        if (viewModel.nickName != null) {
          setState(() {
            _nickNameController.text = viewModel.nickName!;
          });
        }
      }
    } catch (e) {
      print('프로필 로드 실패: $e');
    }
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = ref.read(profileViewModelProvider);
    if (viewModel.nickName != null &&
        viewModel.nickName != _nickNameController.text) {
      setState(() {
        _nickNameController.text = viewModel.nickName!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isNewUser = arguments?['isNewUser'] as bool;

    final viewModel = ref.watch(profileViewModelProvider);
    final viewModelMethod = ref.watch(profileViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
          title: const Text('프로필 설정'),
          leading: isNewUser
              ? Container()
              : IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/chevron-left.svg',
                    width: 24,
                    height: 24,
                  ),
                )),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                await viewModelMethod.pickImage();
              },
              child: Center(
                child: ClipOval(
                  child: viewModel.profile != null
                      ? Image.network(
                          viewModel.profile!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              emptyProfileImg(),
                        )
                      : emptyProfileImg(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => viewModelMethod.pickImage(),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 82,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: AppColors.brown400,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '사진 등록',
                      style: AppTextStyle.heading5R.style.copyWith(
                        color: AppColors.brown500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 56),
            Text(
              '닉네임',
              style: AppTextStyle.heading5R.style
                  .copyWith(color: AppColors.grey900),
            ),
            SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: TextFieldWidget(
                  hintText: '닉네임을 입력해주세요',
                  controller: _nickNameController,
                  onChanged: (value) => ref
                      .read(profileViewModelProvider.notifier)
                      .updateNickName(value),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.grey300,
                width: 1,
              ),
            ),
          ),
          child: FilledButtons.h48(
            text: '저장하기',
            onPressed: () async {
              if (_nickNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('닉네임을 입력해주세요')),
                );
                return;
              }
              bool success = await ref
                  .read(profileViewModelProvider.notifier)
                  .saveProfile();
              if (success) {
                isNewUser
                    ? Navigator.pushReplacementNamed(context, '/home')
                    : Navigator.pop(context);
              }
            },
            backgroundColor: AppColors.brown500,
          ),
        ),
      ),
    );
  }
}
