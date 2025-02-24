import 'package:bookcaffeine/ui/home/home_view_model.dart';
import 'package:bookcaffeine/ui/sns_my_page/sns_my_page_view_model.dart';
import 'package:bookcaffeine/util/global_widgets/empty_book_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinishBooks extends ConsumerWidget {
  final String userId;
  final bool isMySns;

  const FinishBooks({super.key, required this.userId, required this.isMySns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final snsMyPageState = ref.watch(snsMyPageViewModelProvider(userId));

    var state = isMySns ? snsMyPageState : homeState;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 109 / 164,
        ),
        itemCount: state.finishedBook.length,
        itemBuilder: (context, index) {
          final book = state.finishedBook[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/book_detail',
                arguments: book,
              );
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: (book?.thumbnail != null && book!.thumbnail!.isNotEmpty)
                  ? Image.network(
                      book.thumbnail!,
                      fit: BoxFit.cover,
                    )
                  : emptyBookCover(book?.title),
            ),
          );
        },
      ),
    );
  }
}
