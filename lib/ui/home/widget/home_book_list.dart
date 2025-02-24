import 'package:bookcaffeine/data/model/home_state.dart';
import 'package:bookcaffeine/util/global_widgets/empty_book_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeBookList extends StatelessWidget {
  const HomeBookList({
    super.key,
    required this.homeState,
  });
  final HomeState homeState;
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: homeState.currentBooks.length,
              separatorBuilder: (context, index) => SizedBox(width: 16),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/book_detail',
                        arguments: homeState.currentBooks[index]);
                  },
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: (homeState.currentBooks[index]?.thumbnail != null &&
                            homeState
                                .currentBooks[index]!.thumbnail!.isNotEmpty)
                        ? Image.network(
                            homeState.currentBooks[index]!.thumbnail!)
                        : emptyBookCover(homeState.currentBooks[index]!.title),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
