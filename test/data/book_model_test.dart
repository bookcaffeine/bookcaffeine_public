import 'dart:convert';

import 'package:bookcaffeine/data/model/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleJsonString = '''{
      "authors": [
        "나쓰메 소세키"
      ],
      "contents": "단단한 번역, 꼼꼼한 편집과 디자인으로 새롭게 읽는「나쓰메 소세키 소설 전집」 제1권 『나는 고양이로소이다』. 일본 근대 문학의 출발인 나쓰메 소세키의 장편소설을 만나볼 수 있는 전집 가운데 첫 번째 작품으로 38세라는 늦은 나이에 발표한 나쓰메 소세키의 첫 소설 《나는 고양이로소이다》를 선정하였다. 나쓰메 소세키의 등단작이자 출세작인 이 작품은 당대의 삶과 사회를 생생하고 우스꽝스럽게 그려내 호평과 반향을 일으켰다.  고양이를 1인칭 관찰자 시점의",
      "datetime": "2013-09-10T00:00:00.000+09:00",
      "isbn": "8932316759 9788932316758",
      "price": 15000,
      "publisher": "현암사",
      "sale_price": 13500,
      "status": "정상판매",
      "thumbnail": "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F501731%3Ftimestamp%3D20240511113019",
      "title": "나는 고양이로소이다",
      "translators": [
        "송태욱"
      ],
      "url": "https://search.daum.net/search?w=bookpage&bookId=501731&q=%EB%82%98%EB%8A%94+%EA%B3%A0%EC%96%91%EC%9D%B4%EB%A1%9C%EC%86%8C%EC%9D%B4%EB%8B%A4"
    }
    ''';

  final book = Book.fromJson(jsonDecode(sampleJsonString));
  final json = book.toJson();
  test('book.fromJson test', () {
    expect(book.authors, ['나쓰메 소세키']);
    expect(book.contents,
        "단단한 번역, 꼼꼼한 편집과 디자인으로 새롭게 읽는「나쓰메 소세키 소설 전집」 제1권 『나는 고양이로소이다』. 일본 근대 문학의 출발인 나쓰메 소세키의 장편소설을 만나볼 수 있는 전집 가운데 첫 번째 작품으로 38세라는 늦은 나이에 발표한 나쓰메 소세키의 첫 소설 《나는 고양이로소이다》를 선정하였다. 나쓰메 소세키의 등단작이자 출세작인 이 작품은 당대의 삶과 사회를 생생하고 우스꽝스럽게 그려내 호평과 반향을 일으켰다.  고양이를 1인칭 관찰자 시점의");
    expect(book.datetime, "2013-09-10T00:00:00.000+09:00");
    expect(book.isbn, "8932316759 9788932316758");
    expect(book.publisher, "현암사");
    expect(book.thumbnail,
        "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F501731%3Ftimestamp%3D20240511113019");
    expect(book.title, "나는 고양이로소이다");
  });

  test('book.toJson', () {
    expect(json['authors'], ["나쓰메 소세키"]);
    expect(json['contents'],
        "단단한 번역, 꼼꼼한 편집과 디자인으로 새롭게 읽는「나쓰메 소세키 소설 전집」 제1권 『나는 고양이로소이다』. 일본 근대 문학의 출발인 나쓰메 소세키의 장편소설을 만나볼 수 있는 전집 가운데 첫 번째 작품으로 38세라는 늦은 나이에 발표한 나쓰메 소세키의 첫 소설 《나는 고양이로소이다》를 선정하였다. 나쓰메 소세키의 등단작이자 출세작인 이 작품은 당대의 삶과 사회를 생생하고 우스꽝스럽게 그려내 호평과 반향을 일으켰다.  고양이를 1인칭 관찰자 시점의");

    expect(json['datetime'], "2013-09-10T00:00:00.000+09:00");
    expect(json['isbn'], "8932316759 9788932316758");
    expect(json['publisher'], "현암사");
    expect(json['thumbnail'],
        "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F501731%3Ftimestamp%3D20240511113019");
    expect(json['title'], "나는 고양이로소이다");
  });

  test('book.copyWith', () {
    final updatedBook = book.copyWith(
      authors: ['목진성', '신혜원'],
      title: '최강 미남 목진성, 최강 미녀 신혜원',
      contents: '목진성, 그의 잘생김은 끝은 어디까지인가? 신혜원 그녀는 20대 초반처럼 보인다.',
      publisher: '선남선녀',
    );
    expect(updatedBook.authors, ['목진성', '신혜원']);
    expect(
        updatedBook.contents, '목진성, 그의 잘생김은 끝은 어디까지인가? 신혜원 그녀는 20대 초반처럼 보인다.');
    expect(updatedBook.datetime, "2013-09-10T00:00:00.000+09:00");
    expect(updatedBook.isbn, "8932316759 9788932316758");
    expect(updatedBook.publisher, '선남선녀');
    expect(updatedBook.thumbnail,
        "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F501731%3Ftimestamp%3D20240511113019");
    expect(updatedBook.title, '최강 미남 목진성, 최강 미녀 신혜원');
  });
}
