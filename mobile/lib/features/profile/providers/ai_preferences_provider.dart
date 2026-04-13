import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_preferences.dart';
import '../services/ai_preferences_service.dart';

class AiPreferencesNotifier extends StateNotifier<AsyncValue<AiPreferences>> {
  final AiPreferencesService _service;

  AiPreferencesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getPreferences());
  }

  Future<void> updatePreferences({
    double? riskLevel,
    List<String>? preferredNotes,
    List<String>? avoidedNotes,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updatedData = <String, dynamic>{};
    if (riskLevel != null) updatedData['riskLevel'] = riskLevel;
    if (preferredNotes != null) updatedData['preferredNotes'] = preferredNotes;
    if (avoidedNotes != null) updatedData['avoidedNotes'] = avoidedNotes;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _service.updatePreferences(updatedData);
    });
  }
}

final aiPreferencesProvider =
    StateNotifierProvider<AiPreferencesNotifier, AsyncValue<AiPreferences>>((ref) {
  return AiPreferencesNotifier(ref.watch(aiPreferencesServiceProvider));
});

final scentNotesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(aiPreferencesServiceProvider).listScentNotes();
});
