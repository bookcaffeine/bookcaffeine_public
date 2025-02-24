import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? postId;
  final String bookId;
  final String? review;
  final String? userId;
  final String? profileImg;
  final String nickName;
  final bool public;
  final DateTime createdAt;
  final bool isLiked;
  final bool isDeleted;
  final int likeCount;

  Post({
    this.postId,
    required this.bookId,
    required this.review,
    required this.userId,
    required this.profileImg,
    required this.nickName,
    this.public = true,
    required this.createdAt,
    this.isLiked = false,
    this.isDeleted = false,
    this.likeCount = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final createdAtData = json['createdAt'];
    final DateTime createdAt;

    if (createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else if (createdAtData is String) {
      createdAt = DateTime.parse(createdAtData);
    } else {
      createdAt = DateTime.now();
    }

    return Post(
      postId: json['postId'] ?? '',
      bookId: json['bookId'] ?? '',
      review: json['review'] ?? '',
      profileImg: json['profileImg'] ?? '',
      userId: json['userId'] ?? '',
      nickName: json['nickName'] ?? '',
      public: json['public'] ?? true,
      createdAt: createdAt,
      isLiked: json['isLiked'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      likeCount: json['likeCount'] ?? 0,
    );
  }

  factory Post.fromFirestore(DocumentSnapshot doc, {required String postId}) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAtData = data['createdAt'];
    final DateTime createdAt;

    if (createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else if (createdAtData is String) {
      createdAt = DateTime.parse(createdAtData);
    } else {
      createdAt = DateTime.now();
    }

    return Post(
      postId: postId,
      bookId: data['bookId'] ?? '',
      review: data['review'] ?? '',
      userId: data['userId'] ?? '',
      nickName: data['nickName'] ?? '',
      profileImg: data['profileImg'] ?? '',
      public: data['public'] ?? true,
      createdAt: createdAt,
      isLiked: data['isLiked'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      likeCount: data['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'bookId': bookId,
      'review': review,
      'userId': userId,
      'nickName': nickName,
      'profileImg': profileImg,
      'public': public,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
      'isDeleted': isDeleted,
      'likeCount': likeCount,
    };
  }

  Post copyWith({
    String? postId,
    String? bookId,
    DateTime? createdAt,
    String? review,
    String? profileImg,
    String? userId,
    String? nickName,
    bool? public,
    bool? isLiked,
    bool? isDeleted,
    int? likeCount,
  }) {
    return Post(
      postId: postId ?? this.postId,
      bookId: bookId ?? this.bookId,
      createdAt: createdAt ?? this.createdAt,
      review: review ?? this.review,
      profileImg: profileImg ?? this.profileImg,
      userId: userId ?? this.userId,
      nickName: nickName ?? this.nickName,
      public: public ?? this.public,
      isLiked: isLiked ?? this.isLiked,
      isDeleted: isDeleted ?? this.isDeleted,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}
