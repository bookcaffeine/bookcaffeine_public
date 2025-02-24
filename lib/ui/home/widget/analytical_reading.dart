import 'package:bookcaffeine/data/model/home_state.dart';
import 'package:bookcaffeine/ui/home/widget/read_book_record.dart';
import 'package:flutter/material.dart';

Row analyticalReading(HomeState state) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ReadBookRecord(
        readBooks: state.monthlyReadBooks.length,
        dateUnit: '월간 독서',
      ),
      ReadBookRecord(
        readBooks: state.yearlyReadBooks.length,
        dateUnit: '연간 독서',
      ),
      ReadBookRecord(
        readBooks: state.totalReadBooks.length,
        dateUnit: '누적 독서',
      ),
    ],
  );
}
