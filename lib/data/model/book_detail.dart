import 'package:bookcaffeine/data/model/book.dart';
import 'package:bookcaffeine/data/model/post.dart';

class BookDetail {
  final Book? bookInfo;
  final List<Post> posts;
  final List<String> emotionTags;

  BookDetail({
    this.bookInfo,
    this.posts = const [],
    this.emotionTags = const [],
  });

  BookDetail copyWith({
    Book? bookInfo,
    List<Post>? posts,
    List<String>? emotionTags,
  }) {
    return BookDetail(
      bookInfo: bookInfo ?? this.bookInfo,
      posts: posts ?? this.posts,
      emotionTags: emotionTags ?? this.emotionTags,
    );
  }
}
