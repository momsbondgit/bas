import 'reaction_type.dart';

class Message {
  const Message({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.content,
    required this.timestamp,
    required this.reactions,
  });

  final String id;
  final String userId;
  final String displayName;
  final String content;
  final DateTime timestamp;
  final Map<String, ReactionType> reactions;

  Message copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? content,
    DateTime? timestamp,
    Map<String, ReactionType>? reactions,
  }) {
    return Message(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      reactions: reactions ?? this.reactions,
    );
  }

  Message addReaction(String userId, ReactionType reaction) {
    final newReactions = Map<String, ReactionType>.from(reactions);
    newReactions[userId] = reaction;
    return copyWith(reactions: newReactions);
  }

  Message removeReaction(String userId) {
    final newReactions = Map<String, ReactionType>.from(reactions);
    newReactions.remove(userId);
    return copyWith(reactions: newReactions);
  }

  int getReactionCount(ReactionType reactionType) {
    return reactions.values.where((r) => r == reactionType).length;
  }

  bool hasUserReacted(String userId) {
    return reactions.containsKey(userId);
  }

  ReactionType? getUserReaction(String userId) {
    return reactions[userId];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'displayName': displayName,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'reactions': reactions.map((key, value) => MapEntry(key, value.name)),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    final reactionsMap = <String, ReactionType>{};
    final reactionsData = map['reactions'] as Map<String, dynamic>? ?? {};
    
    for (final entry in reactionsData.entries) {
      final reaction = ReactionType.fromString(entry.value as String);
      if (reaction != null) {
        reactionsMap[entry.key] = reaction;
      }
    }

    return Message(
      id: map['id'] as String,
      userId: map['userId'] as String,
      displayName: map['displayName'] as String,
      content: map['content'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      reactions: reactionsMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.userId == userId &&
        other.displayName == displayName &&
        other.content == content &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        displayName.hashCode ^
        content.hashCode ^
        timestamp.hashCode;
  }

  @override
  String toString() {
    return 'Message(id: $id, userId: $userId, displayName: $displayName, content: $content, timestamp: $timestamp, reactions: ${reactions.length})';
  }
}