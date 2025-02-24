import 'dart:convert';

import 'package:bookcaffeine/data/model/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const samplePostJsonString = '''{
"bookId": "UCagUeKfy1IwDa6RVqAR",
"createdAt": "2025-01-21T15:51:14.151193",
"like":"3",
"review": "목진성은 대한민국 최고 미남입니다.",
"userId": "PcnobaKwgMxanaxVI3cZ"
}
''';
  final post = Post.fromJson(jsonDecode(samplePostJsonString));
  final json = post.toJson();
  test('post.fromJson', () {
    expect(post.bookId, "UCagUeKfy1IwDa6RVqAR");
    expect(post.createdAt.toIso8601String(), '2025-01-21T15:51:14.151193');
    expect(post.review, "목진성은 대한민국 최고 미남입니다.");
    expect(post.userId, "PcnobaKwgMxanaxVI3cZ");
  });

  test('post.toJson', () {
    expect(json['bookId'], "UCagUeKfy1IwDa6RVqAR");
    expect(json['createdAt'].toString(), "2025-01-21T15:51:14.151193");
    expect(json['review'], "목진성은 대한민국 최고 미남입니다.");
    expect(json['userId'], "PcnobaKwgMxanaxVI3cZ");
  });

  test('post.copyWith', () {
    final updatedPost = post.copyWith(review: '신혜원은 대한민국 최고의 미녀입니다.');
    expect(updatedPost.bookId, "UCagUeKfy1IwDa6RVqAR");
    expect(
        updatedPost.createdAt.toIso8601String(), "2025-01-21T15:51:14.151193");
    expect(updatedPost.review, "신혜원은 대한민국 최고의 미녀입니다.");
    expect(updatedPost.userId, "PcnobaKwgMxanaxVI3cZ");
  });
}
