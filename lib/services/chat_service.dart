import 'package:dio/dio.dart';
import '../config.dart'; // Import the Config class

class ApiService {
  final Dio _dio = Dio();

  // Use getters from Config instead of hardcoded values
  String get _apiKey => Config.apiKey;
  String get _baseUrl => Config.baseUrl;
  Future<String> getGeminiResponse(String prompt) async {
    try {
      final response = await _dio.post(
        '$_baseUrl?key=$_apiKey',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'response_mime_type': 'text/plain'},
        },
      );

      if (response.statusCode == 200) {
        return response.data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}