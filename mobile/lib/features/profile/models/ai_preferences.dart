class AiPreferences {
  final String id;
  final String userId;
  final double riskLevel;
  final List<String> preferredNotes;
  final List<String> avoidedNotes;

  AiPreferences({
    required this.id,
    required this.userId,
    required this.riskLevel,
    required this.preferredNotes,
    required this.avoidedNotes,
  });

  factory AiPreferences.fromJson(Map<String, dynamic> json) {
    return AiPreferences(
      id: json['id'] as String,
      userId: json['userId'] as String,
      riskLevel: (json['riskLevel'] as num).toDouble(),
      preferredNotes: List<String>.from(json['preferredNotes'] as List),
      avoidedNotes: List<String>.from(json['avoidedNotes'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'riskLevel': riskLevel,
      'preferredNotes': preferredNotes,
      'avoidedNotes': avoidedNotes,
    };
  }

  AiPreferences copyWith({
    double? riskLevel,
    List<String>? preferredNotes,
    List<String>? avoidedNotes,
  }) {
    return AiPreferences(
      id: id,
      userId: userId,
      riskLevel: riskLevel ?? this.riskLevel,
      preferredNotes: preferredNotes ?? this.preferredNotes,
      avoidedNotes: avoidedNotes ?? this.avoidedNotes,
    );
  }
}
