enum ReactionType {
  lmfaooo('LMFAOOO 😭'),
  soReal('so real 💅'),
  nahThatWild('nah that\'s wild 💀');

  const ReactionType(this.emoji);

  final String emoji;

  String get displayName {
    switch (this) {
      case ReactionType.lmfaooo:
        return 'LMFAOOO';
      case ReactionType.soReal:
        return 'So Real';
      case ReactionType.nahThatWild:
        return 'Nah That\'s Wild';
    }
  }

  static ReactionType? fromString(String value) {
    for (final reaction in ReactionType.values) {
      if (reaction.name == value) {
        return reaction;
      }
    }
    return null;
  }
}