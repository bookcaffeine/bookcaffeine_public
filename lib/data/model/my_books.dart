class MyBooks {
  /// isbn
  final String? bookId;

  /// 독서 상태 읽기 전,읽는 중, 읽은 후
  final String? state;

  /// 독서완료 시각
  final DateTime? finishedAt;

  // 책 등록 시각
  final DateTime? registeredAt;

  // 책 표지 이미지
  final String? thumbnail;

  /// 책id& state
  MyBooks({
    required this.bookId,
    required this.state,
    required this.finishedAt,
    required this.registeredAt,
    required this.thumbnail,
  });

  factory MyBooks.fromJson(Map<String, dynamic> json) {
    return MyBooks(
        bookId: json['bookId'] ?? '',
        state: json['state'] ?? '',
        finishedAt: json['finishedAt'] ?? '',
        registeredAt: json['registeredAt'] ?? '',
        thumbnail: json['thumbnail'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'state': state,
      'finishedAt': finishedAt,
      'registeredAt': registeredAt,
      'thumbnail': thumbnail,
    };
  }

  MyBooks copyWith(
      {String? bookId,
      String? state,
      DateTime? finishedAt,
      DateTime? registeredAt,
      String? thumbnail}) {
    return MyBooks(
      bookId: bookId ?? this.bookId,
      state: state ?? this.state,
      finishedAt: finishedAt ?? this.finishedAt,
      registeredAt: registeredAt ?? this.registeredAt,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
