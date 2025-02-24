import 'dart:convert';
import 'package:bookcaffeine/data/model/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'UserModel : fromJson test',
    () {
      const sampleJsonString = """
   {
        "nickName": "Jane",
        "gender": "Female",
        "ageRange": "30대",
        "job": "Writer",
        "mbti": "INFJ",
        "profile": "profile_url",
        "snsType": "twitter",
        "state": {
          "currentBooks": ["Book X", "Book Y"],
          "finishedBooks": ["Book Z"],
          "upcomingBooks": ["Book W"]
        },
        "interests": ["Writing", "Traveling"],
        "agreement": { 
          "essential": true,
          "generatingAI": false,
          "marketing": false,
          "publishingProfileImpression": false,
          "storingAnalyzingData": false
        }
      }
""";
      final user = User.fromJson(jsonDecode(sampleJsonString));

      // 테스트 검증
      expect(user.nickName, "Jane");
      // expect(user.state.currentBooks, ["Book X", "Book Y"]);
      // expect(user.state.finishedBooks, ["Book Z"]);
      // expect(user.state.upcomingBooks, ["Book W"]);
    },
  );
}
