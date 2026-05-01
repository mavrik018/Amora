enum RelationshipIntent {
  casual,
  serious,
  openToBoth;

  String get label {
    switch (this) {
      case RelationshipIntent.casual:
        return 'Casual';
      case RelationshipIntent.serious:
        return 'Serious';
      case RelationshipIntent.openToBoth:
        return 'Open to Both';
    }
  }

  static RelationshipIntent fromString(String value) {
    return RelationshipIntent.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => RelationshipIntent.casual,
    );
  }
}
