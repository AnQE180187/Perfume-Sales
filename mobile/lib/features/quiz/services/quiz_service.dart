import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../providers/quiz_provider.dart';

class QuizService {
  final ApiClient _client;

  QuizService({required ApiClient client}) : _client = client;

  Future<Map<String, dynamic>> submitQuiz(Map<String, dynamic> answers) async {
    final response = await _client.post(
      ApiEndpoints.quizSubmit,
      data: {'answers': answers},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getQuizResult(String quizId) async {
    final response = await _client.get(ApiEndpoints.quizResult(quizId));
    return response.data as Map<String, dynamic>;
  }
}
