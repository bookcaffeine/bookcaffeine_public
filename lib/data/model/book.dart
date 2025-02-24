import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final List<String?> authors;
  final String? contents;
  final String? datetime;
  final String isbn;
  final String? publisher;
  final String? thumbnail;
  final String? title;
  final String? state;
  final List<String?> translators;
  final List<String> emotionTags;

  Book({
    required this.authors,
    required this.contents,
    required this.datetime,
    required this.isbn,
    required this.publisher,
    required this.thumbnail,
    required this.title,
    required this.state,
    required this.translators,
    this.emotionTags = const [],
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      authors: List<String>.from(json['authors'] ?? []),
      contents: json['contents'] ?? '',
      datetime: json['datetime'] ?? '',
      isbn: json['isbn'] ?? '',
      publisher: json['publisher'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      title: json['title'] ?? '',
      state: json['state'] ?? '',
      translators: List<String>.from(json['translators'] ?? []),
      emotionTags: List<String>.from(json['emotionTags'] ?? []),
    );
  }

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      authors: List<String>.from(data['authors'] ?? []),
      contents: data['contents'],
      datetime: data['datetime'],
      isbn: data['isbn'],
      publisher: data['publisher'],
      thumbnail: data['thumbnail'],
      title: data['title'],
      state: data['state'],
      translators: List<String>.from(data['translators'] ?? []),
      emotionTags: List<String>.from(data['emotionTags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authors': authors,
      'contents': contents,
      'datetime': datetime,
      'isbn': isbn,
      'publisher': publisher,
      'thumbnail': thumbnail,
      'translators': translators,
      'title': title,
      'state': state,
      'emotionTags': emotionTags,
    };
  }

  Book copyWith({
    List<String>? authors,
    String? contents,
    String? datetime,
    String? isbn,
    String? publisher,
    String? thumbnail,
    String? title,
    String? state,
    List<String>? translators,
    List<String>? emotionTags,
  }) {
    return Book(
      authors: authors ?? this.authors,
      contents: contents ?? this.contents,
      datetime: datetime ?? this.datetime,
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      thumbnail: thumbnail ?? this.thumbnail,
      title: title ?? this.title,
      state: state ?? this.state,
      translators: translators ?? this.translators,
      emotionTags: emotionTags ?? this.emotionTags,
    );
  }

  String get bookId => isbn;
}
