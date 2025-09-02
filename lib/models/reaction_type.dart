enum ReactionType {
  heart('❤️'),
  laugh('😂'),
  wow('😮'),
  sad('😢'),
  angry('😠'),
  thumbsUp('👍'),
  thumbsDown('👎');

  const ReactionType(this.emoji);

  final String emoji;

  String get displayName {
    switch (this) {
      case ReactionType.heart:
        return 'Heart';
      case ReactionType.laugh:
        return 'Laugh';
      case ReactionType.wow:
        return 'Wow';
      case ReactionType.sad:
        return 'Sad';
      case ReactionType.angry:
        return 'Angry';
      case ReactionType.thumbsUp:
        return 'Thumbs Up';
      case ReactionType.thumbsDown:
        return 'Thumbs Down';
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