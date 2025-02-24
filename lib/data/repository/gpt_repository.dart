import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GptRepository {
  final String apiKey = dotenv.env['GPT_API_KEY'] ?? '';
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<List<String>> analyzeEmotions(List<String> reviews) async {
    try {
      final String combinedReviews = reviews.join(' ');
      // print('GPT 분석 시작: ${reviews.length}개의 리뷰');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  '당신은 텍스트의 감정을 분석하고 5개의 감성 태그를 생성하는 AI입니다. 응답은 태그1 태그2 태그3 태그4 태그5 형식으로만 반환해주세요.'
            },
            {
              'role': 'user',
              'content':
                  '다음 리뷰들의 전반적인 키워드를 분석해서 5개의 태그를 만들어주세요: $combinedReviews'
            }
          ],
          'temperature': 0.5,
          'max_tokens': 70,
        }),
      );

      // print('GPT 응답: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        final tags = content.split(' ');
        // print('생성된 태그: $tags');
        return tags;
      }
      return [];
    } catch (e) {
      // print('GPT API Error: $e');
      return [];
    }
  }
}
