import '../../features/product/models/product.dart';

int calculateMatchPercentage(Product product, List<String> preferredNotes, [List<String> avoidedNotes = const []]) {
  if (preferredNotes.isEmpty && avoidedNotes.isEmpty) return 0;
  
  final productNotes = product.notes.map((n) => n.toLowerCase().trim()).toSet();
  int matches = 0;
  int penalties = 0;
  
  // Count matches
  for (var note in preferredNotes) {
    final cleanNote = note.split(' (')[0].toLowerCase().trim();
    if (productNotes.any((pn) => pn.startsWith(cleanNote) || cleanNote.startsWith(pn.split(' (')[0].toLowerCase().trim()))) {
      matches++;
    }
  }
  
  // Count penalties
  for (var note in avoidedNotes) {
    final cleanNote = note.split(' (')[0].toLowerCase().trim();
    if (productNotes.any((pn) => pn.startsWith(cleanNote) || cleanNote.startsWith(pn.split(' (')[0].toLowerCase().trim()))) {
      penalties++;
    }
  }
  
  if (matches == 0 && penalties == 0) return 0;
  if (matches == 0 && penalties > 0) return 10; // Explicitly low if only penalties found
  
  // New weighted calculation for more realistic results
  // Base 70% for first match, +10% for others
  int score = 70 + (matches * 10);
  
  // Penalty: -40% for each avoided note (very aggressive)
  score -= (penalties * 40);
  
  return score.clamp(5, 99);
}

List<String> getMatchingNotes(Product product, List<String> preferredNotes) {
  if (preferredNotes.isEmpty) return [];
  final productNotes = product.notes.map((n) => n.toLowerCase().trim()).toSet();
  final matched = <String>[];
  
  for (var prefNote in preferredNotes) {
    final cleanPref = prefNote.split(' (')[0].toLowerCase().trim();
    final match = product.notes.firstWhere(
      (pn) {
        final cleanPn = pn.toLowerCase().trim();
        return cleanPn.startsWith(cleanPref) || cleanPref.startsWith(cleanPn.split(' (')[0].toLowerCase().trim());
      },
      orElse: () => '',
    );
    if (match.isNotEmpty) matched.add(match);
  }
  return matched;
}

List<String> getAvoidedNotesFound(Product product, List<String> avoidedNotes) {
  if (avoidedNotes.isEmpty) return [];
  final productNotes = product.notes.map((n) => n.toLowerCase().trim()).toSet();
  final found = <String>[];
  
  for (var avoidNote in avoidedNotes) {
    final cleanAvoid = avoidNote.split(' (')[0].toLowerCase().trim();
    final match = product.notes.firstWhere(
      (pn) {
        final cleanPn = pn.toLowerCase().trim();
        return cleanPn.startsWith(cleanAvoid) || cleanAvoid.startsWith(cleanPn.split(' (')[0].toLowerCase().trim());
      },
      orElse: () => '',
    );
    if (match.isNotEmpty) found.add(match);
  }
  return found;
}
