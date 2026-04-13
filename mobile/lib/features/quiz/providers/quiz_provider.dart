import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/quiz_service.dart';
import '../../../core/api/api_client.dart';

class QuizQuestion {
  final String text;
  final List<QuizOption> options;

  const QuizQuestion({required this.text, required this.options});
}

class QuizOption {
  final String title;
  final String value;
  final String icon;

  const QuizOption({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class QuizState {
  final int currentStep;
  final Map<int, int> answers; // step → selected option index
  final bool isComplete;
  final bool isAnalyzing;
  final List<dynamic> recommendations;
  final String? errorMessage;

  const QuizState({
    this.currentStep = 0,
    this.answers = const {},
    this.isComplete = false,
    this.isAnalyzing = false,
    this.recommendations = const [],
    this.errorMessage,
  });

  int get totalSteps => questions.length;
  bool get canGoBack => currentStep > 0;

  QuizState copyWith({
    int? currentStep,
    Map<int, int>? answers,
    bool? isComplete,
    bool? isAnalyzing,
    List<dynamic>? recommendations,
    String? errorMessage,
  }) {
    return QuizState(
      currentStep: currentStep ?? this.currentStep,
      answers: answers ?? this.answers,
      isComplete: isComplete ?? this.isComplete,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      recommendations: recommendations ?? this.recommendations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  static const List<QuizQuestion> questions = [
    QuizQuestion(
      text: 'Dấu ấn này dành cho ai?',
      options: [
        QuizOption(title: 'Nam tính', value: 'MALE', icon: 'person'),
        QuizOption(title: 'Nữ tính', value: 'FEMALE', icon: 'favorite'),
        QuizOption(title: 'Phi giới tính', value: 'UNISEX', icon: 'people'),
      ],
    ),
    QuizQuestion(
      text: 'Bạn sẽ sử dụng mùi hương này khi nào?',
      options: [
        QuizOption(title: 'Hàng ngày', value: 'daily', icon: 'star'),
        QuizOption(title: 'Công sở', value: 'office', icon: 'business_center'),
        QuizOption(title: 'Hẹn hò', value: 'date', icon: 'calendar_month'),
        QuizOption(title: 'Tiệc tùng', value: 'party', icon: 'celebration'),
        QuizOption(title: 'Sự kiện đặc biệt', value: 'special_event', icon: 'auto_awesome'),
      ],
    ),
    QuizQuestion(
      text: 'Mức ngân sách bạn dự định đầu tư?',
      options: [
        QuizOption(title: '< 500K', value: '0-500000', icon: 'paid'),
        QuizOption(title: '500K – 1M', value: '500000-1000000', icon: 'savings'),
        QuizOption(title: '1M – 2M', value: '1000000-2000000', icon: 'currency_exchange'),
        QuizOption(title: '2M – 5M', value: '2000000-5000000', icon: 'payments'),
        QuizOption(title: '> 5M', value: '5000000-99999999', icon: 'workspace_premium'),
      ],
    ),
    QuizQuestion(
      text: 'Bạn yêu thích phong cách mùi hương nào?',
      options: [
        QuizOption(title: 'Tươi mát', value: 'Fresh', icon: 'air'),
        QuizOption(title: 'Hoa cỏ', value: 'Floral', icon: 'local_florist'),
        QuizOption(title: 'Gỗ', value: 'Woody', icon: 'park'),
        QuizOption(title: 'Phương đông', value: 'Oriental', icon: 'local_fire_department'),
        QuizOption(title: 'Thảo mộc', value: 'Aromatic', icon: 'spa'),
      ],
    ),
    QuizQuestion(
      text: 'Bạn kỳ vọng độ bám tỏa trong bao lâu?',
      options: [
        QuizOption(title: '2-4h (Nhẹ)', value: 'light', icon: 'schedule'),
        QuizOption(title: '4-6h (Vừa)', value: 'moderate', icon: 'timer'),
        QuizOption(title: '6-8h (Bền)', value: 'long_lasting', icon: 'hourglass'),
        QuizOption(title: '8h+ (Cực lâu)', value: 'very_long', icon: 'bolt'),
      ],
    ),
  ];
}

class QuizNotifier extends StateNotifier<QuizState> {
  final QuizService _service;

  QuizNotifier({required QuizService service})
      : _service = service,
        super(const QuizState());

  Future<void> selectOption(int optionIndex) async {
    final updated = Map<int, int>.from(state.answers);
    updated[state.currentStep] = optionIndex;

    if (state.currentStep < state.totalSteps - 1) {
      state = state.copyWith(
        answers: updated,
        currentStep: state.currentStep + 1,
      );
    } else {
      // Start analyzing
      state = state.copyWith(answers: updated, isAnalyzing: true);

      try {
        // Map indexed answers to values for API
        final Map<String, dynamic> payload = {};
        for (int i = 0; i < QuizState.questions.length; i++) {
          final q = QuizState.questions[i];
          final ansIndex = i == state.currentStep ? optionIndex : updated[i];
          if (ansIndex != null) {
            final opt = q.options[ansIndex];
            
            // Special handling for budget range
            if (i == 2) { // Budget index
              final parts = opt.value.split('-');
              payload['budgetMin'] = int.parse(parts[0]);
              payload['budgetMax'] = int.parse(parts[1]);
            } else if (i == 0) { // Gender
               payload['gender'] = opt.value;
            } else if (i == 1) { // Occasion
               payload['occasion'] = opt.value;
            } else if (i == 3) { // Family
               payload['preferredFamily'] = opt.value;
            } else if (i == 4) { // Longevity
               payload['longevity'] = opt.value;
            }
          }
        }

        // Simulating AI analysis UX (at least 3s like on web)
        final startTime = DateTime.now();
        final result = await _service.submitQuiz(payload);
        
        final elapsed = DateTime.now().difference(startTime).inSeconds;
        if (elapsed < 3) {
          await Future.delayed(Duration(seconds: 3 - elapsed));
        }

        state = state.copyWith(
          isAnalyzing: false,
          isComplete: true,
          recommendations: result['recommendations'] ?? [],
          errorMessage: null,
        );
      } on DioException catch (e) {
        final message = e.response?.data is Map 
            ? (e.response?.data['message'] ?? e.message)
            : e.message;
        state = state.copyWith(
          isAnalyzing: false,
          errorMessage: 'Lỗi API: $message',
        );
        print('Quiz API Error: $message');
      } catch (e) {
        state = state.copyWith(
          isAnalyzing: false,
          errorMessage: 'Đã có lỗi xảy ra: $e',
        );
        print('Quiz Error: $e');
      }
    }
  }

  void goBack() {
    if (state.canGoBack) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void reset() {
    state = const QuizState();
  }
}

final quizServiceProvider = Provider<QuizService>((ref) {
  final client = ref.watch(apiClientProvider);
  return QuizService(client: client);
});

final quizProvider = StateNotifierProvider.autoDispose<QuizNotifier, QuizState>((ref) {
  final service = ref.watch(quizServiceProvider);
  return QuizNotifier(service: service);
});
