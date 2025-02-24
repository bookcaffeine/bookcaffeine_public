import 'package:bookcaffeine/data/repository/post_repository.dart';
import 'package:bookcaffeine/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final postRepository = PostRepository();
  test(
      'getPostsByBookId should return posts by bookId in descending order of createdAt',
      () async {
    //bookId가 필요함.
    return postRepository.getPostsByBookIdWithoutReported('');
  });
}
