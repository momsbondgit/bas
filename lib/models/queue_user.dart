class QueueUser {
  const QueueUser({
    required this.userId,
    required this.displayName,
    required this.isActive,
    required this.position,
    this.avatarUrl,
  });

  final String userId;
  final String displayName;
  final bool isActive;
  final int position;
  final String? avatarUrl;

  QueueUser copyWith({
    String? userId,
    String? displayName,
    bool? isActive,
    int? position,
    String? avatarUrl,
  }) {
    return QueueUser(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      isActive: isActive ?? this.isActive,
      position: position ?? this.position,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'isActive': isActive,
      'position': position,
      'avatarUrl': avatarUrl,
    };
  }

  factory QueueUser.fromMap(Map<String, dynamic> map) {
    return QueueUser(
      userId: map['userId'] as String,
      displayName: map['displayName'] as String,
      isActive: map['isActive'] as bool,
      position: map['position'] as int,
      avatarUrl: map['avatarUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QueueUser &&
        other.userId == userId &&
        other.displayName == displayName &&
        other.isActive == isActive &&
        other.position == position &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        displayName.hashCode ^
        isActive.hashCode ^
        position.hashCode ^
        avatarUrl.hashCode;
  }

  @override
  String toString() {
    return 'QueueUser(userId: $userId, displayName: $displayName, isActive: $isActive, position: $position, avatarUrl: $avatarUrl)';
  }
}