import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/core/app_text_style.dart';
import 'package:bookcaffeine/ui/book_detail/book_detail_view_model.dart';
import 'package:bookcaffeine/ui/profile/profile_page_view_model.dart';
import 'package:bookcaffeine/ui/write/write_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WritePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<WritePage> createState() => _WritePageState();
}

class _WritePageState extends ConsumerState<WritePage> {
  final TextEditingController _textController = TextEditingController();
  late bool isModify;
  late String bookId;
  late String? postId;
  String? review;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    isModify = args['isModify'] as bool;
    bookId = args['bookId'] as String;
    postId = args['postId'] as String?;
    review = args['review'] as String?;

    // 수정 모드일 경우 기존 텍스트 세팅
    if (isModify) {
      _textController.text = review ?? ""; // 수정 시 텍스트 필드에 기존 내용 채워넣기
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveReview(nickname, profile, bookId) async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('소감을 입력해주세요')),
      );
      return;
    }

    final success = isModify
        ? await ref
            .read(bookDetailViewModelProvider(bookId).notifier)
            .handleUpdatePost(
                nickname, profile, _textController.text, bookId, postId!)
        : await ref
            .read(writeViewModelProvider.notifier)
            .saveReview(nickname, profile, _textController.text, bookId);

    if (mounted) {
      if (success) {
        // 업데이트 후, 최신 posts를 가져와서 상태 갱신
        await ref
            .watch(bookDetailViewModelProvider(bookId).notifier)
            .fetchBookDetailInfo(bookId);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('소감 저장에 실패했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(writeViewModelProvider);
    final profileState = ref.read(profileViewModelProvider);

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isModify ? '소감 수정' : '소감 작성',
            style: AppTextStyle.heading4M.style.copyWith(
              color: AppColors.grey900,
            ),
          ),
          centerTitle: true,
          actions: [
            /// 작성중에도 controller 갱신
            ListenableBuilder(
              listenable: _textController,
              builder: (context, child) {
                return GestureDetector(
                    onTap: () {
                      _saveReview(
                          profileState.nickName, profileState.profile, bookId);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: Text(
                            '저장',
                            style: AppTextStyle.heading4R.style.copyWith(
                                color: _textController.text.isNotEmpty
                                    ? AppColors.brown500
                                    : AppColors.grey400),
                          ),
                        ),
                      ),
                    ));
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.always,
                      autofocus: true,
                      controller: _textController,
                      cursorColor: AppColors.brown500,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: isModify ? '' : '소감을 작성해 주세요.',
                        hintStyle: AppTextStyle.heading4M.style.copyWith(
                          color: AppColors.grey400,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.brown500),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.brown500),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.brown500),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
