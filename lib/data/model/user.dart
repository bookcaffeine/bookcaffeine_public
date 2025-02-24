import 'package:bookcaffeine/data/model/my_books.dart';

class User {
  final String nickName;
  final String profile;
  final String snsType;
  final MyBooks myBooks;

  User({
    required this.nickName,
    required this.profile,
    required this.snsType,
    required this.myBooks,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nickName: json['nickName'] ?? '',
      profile: json['profile'] ?? '',
      snsType: json['snsType'] ?? '',
      myBooks: MyBooks.fromJson(json['myBooks'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickName': nickName,
      'profile': profile,
      'snsType': snsType,
      'myBooks': myBooks.toJson(),
    };
  }

  User copyWith({
    String? nickName,
    String? profile,
    String? snsType,
    MyBooks? myBooks,
  }) {
    return User(
      nickName: nickName ?? this.nickName,
      profile: profile ?? this.profile,
      snsType: snsType ?? this.snsType,
      myBooks: myBooks ?? this.myBooks,
    );
  }
}
