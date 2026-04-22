import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../services/journal_service.dart';
import '../models/journal.dart';

final journalServiceProvider = Provider<JournalService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return JournalService(apiClient);
});

final journalsProvider = FutureProvider<List<Journal>>((ref) async {
  final service = ref.watch(journalServiceProvider);
  return service.getJournals();
});

final journalDetailProvider = FutureProvider.family<Journal, String>((ref, id) async {
  final service = ref.watch(journalServiceProvider);
  return service.getJournalById(id);
});
