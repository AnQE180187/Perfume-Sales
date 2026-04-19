import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/journal.dart';

class JournalService {
  final ApiClient _apiClient;

  JournalService(this._apiClient);

  Future<List<Journal>> getJournals() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.journals);
      if (response.data is List) {
        return (response.data as List)
            .map((e) => Journal.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      // Mock data for development
      return [
        Journal(
          id: '1',
          title: 'The Art of Scent Layering',
          excerpt: 'Discover how to create your own unique olfactory signature by combining different fragrances.',
          mainImage: 'https://images.unsplash.com/photo-1592303637753-ce1e6b8a0ffb?w=800',
          category: 'Tips',
          priority: 1,
          createdAt: DateTime.now(),
        ),
        Journal(
          id: '2',
          title: 'Seasonal Fragrance Guide: Summer 2024',
          excerpt: 'Bright, citrusy, and aquatic scents to keep you fresh during the warmest months.',
          mainImage: 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=800',
          category: 'Trends',
          priority: 2,
          createdAt: DateTime.now(),
        ),
      ];
    }
  }

  Future<Journal> getJournalById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.journalById(id));
      return Journal.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Mock detail
      return Journal(
        id: id,
        title: 'The Art of Scent Layering',
        excerpt: 'Discover how to create your own unique olfactory signature by combining different fragrances.',
        mainImage: 'https://images.unsplash.com/photo-1592303637753-ce1e6b8a0ffb?w=800',
        category: 'Tips',
        priority: 1,
        createdAt: DateTime.now(),
        sections: [
          const JournalSection(
            id: 's1',
            subtitle: 'Why Layering Matters',
            content: 'Fragment layering is an ancient technique allows you to customize your scent to match your mood, outfit, or occasion.',
            order: 1,
          ),
          const JournalSection(
            id: 's2',
            subtitle: 'The Golden Rules',
            content: 'Always start with the heaviest scent as your base. Lighter, floral, or citrusy notes should be applied on top to prevent them from being overwhelmed.',
            imageUrl: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?w=800',
            order: 2,
          ),
        ],
      );
    }
  }
}
