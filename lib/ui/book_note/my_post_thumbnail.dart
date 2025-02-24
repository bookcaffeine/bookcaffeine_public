import 'package:bookcaffeine/core/app_colors.dart';
import 'package:bookcaffeine/ui/book_note/book_note_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookcaffeine/ui/book_note/widgets/book_info.dart';

class MyPostThumbnail extends ConsumerStatefulWidget {
  const MyPostThumbnail({super.key});

  @override
  ConsumerState<MyPostThumbnail> createState() => _MyPostThumbnail();
}

class _MyPostThumbnail extends ConsumerState<MyPostThumbnail> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(bookNoteViewModelProvider.notifier).loadBookNotes());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookNoteViewModelProvider);

    // 책별로 소감 그룹화
    Map<String, List<BookNote>> groupedNotes = {};
    for (var note in state.bookNotes) {
      final bookId = note.book.bookId;
      if (!groupedNotes.containsKey(bookId)) {
        groupedNotes[bookId] = [];
      }
      groupedNotes[bookId]!.add(note);
    }

    // 각 그룹 내에서 소감을 최신순으로 정렬
    groupedNotes.forEach((_, notes) {
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

    // 책들을 가장 최근 소감 기준으로 정렬
    final sortedBooks = groupedNotes.entries.toList()
      ..sort(
          (a, b) => b.value.first.createdAt.compareTo(a.value.first.createdAt));

    return Scaffold(
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('에러: ${state.error}'))
              : state.bookNotes.isEmpty
                  ? const Center(child: Text('작성한 소감이 없습니다.'))
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: sortedBooks.length,
                      itemBuilder: (context, index) {
                        final bookNotes = sortedBooks[index].value;
                        final book = bookNotes.first.book;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 1,
                                      color: AppColors.grey300,
                                    ),
                                  ),
                                ),
                                child: BookInfo(
                                  book: book,
                                  createdAt: book.datetime != null
                                      ? DateTime.parse(book.datetime!)
                                      : DateTime.now(),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/book_note',
                                      arguments: bookNotes.first,
                                    ).then((_) {
                                      ref
                                          .read(bookNoteViewModelProvider
                                              .notifier)
                                          .loadBookNotes();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
