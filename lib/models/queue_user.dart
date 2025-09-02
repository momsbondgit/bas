enum QueueUserType {
  real,
  dummy,
}

enum QueueUserState {
  waiting,
  active,
  posted,
  completed,
}

enum TypingState {
  idle,
  typing,
}

class QueueUser {
  final String id;
  final String displayName;
  final QueueUserType type;
  final QueueUserState state;
  final TypingState typingState;
  final DateTime? turnStartTime;
  final DateTime? lastActiveTime;
  final DateTime? typingStartTime;
  final DateTime? reactionStartTime;
  final int floor;
  final String gender;

  const QueueUser({
    required this.id,
    required this.displayName,
    required this.type,
    required this.state,
    this.typingState = TypingState.idle,
    this.turnStartTime,
    this.lastActiveTime,
    this.typingStartTime,
    this.reactionStartTime,
    required this.floor,
    required this.gender,
  });

  QueueUser copyWith({
    String? id,
    String? displayName,
    QueueUserType? type,
    QueueUserState? state,
    TypingState? typingState,
    DateTime? turnStartTime,
    DateTime? lastActiveTime,
    DateTime? typingStartTime,
    DateTime? reactionStartTime,
    int? floor,
    String? gender,
  }) {
    return QueueUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      state: state ?? this.state,
      typingState: typingState ?? this.typingState,
      turnStartTime: turnStartTime ?? this.turnStartTime,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      typingStartTime: typingStartTime ?? this.typingStartTime,
      reactionStartTime: reactionStartTime ?? this.reactionStartTime,
      floor: floor ?? this.floor,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'type': type.name,
      'state': state.name,
      'typingState': typingState.name,
      'turnStartTime': turnStartTime?.millisecondsSinceEpoch,
      'lastActiveTime': lastActiveTime?.millisecondsSinceEpoch,
      'typingStartTime': typingStartTime?.millisecondsSinceEpoch,
      'reactionStartTime': reactionStartTime?.millisecondsSinceEpoch,
      'floor': floor,
      'gender': gender,
    };
  }

  factory QueueUser.fromMap(Map<String, dynamic> map) {
    return QueueUser(
      id: map['id'] as String,
      displayName: map['displayName'] as String,
      type: QueueUserType.values.firstWhere((e) => e.name == map['type']),
      state: QueueUserState.values.firstWhere((e) => e.name == map['state']),
      typingState: map['typingState'] != null 
          ? TypingState.values.firstWhere((e) => e.name == map['typingState'])
          : TypingState.idle,
      turnStartTime: map['turnStartTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['turnStartTime'] as int)
          : null,
      lastActiveTime: map['lastActiveTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastActiveTime'] as int)
          : null,
      typingStartTime: map['typingStartTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['typingStartTime'] as int)
          : null,
      reactionStartTime: map['reactionStartTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reactionStartTime'] as int)
          : null,
      floor: map['floor'] as int,
      gender: map['gender'] as String,
    );
  }

  bool get isActive => state == QueueUserState.active;
  bool get hasPosted => state == QueueUserState.posted;
  bool get isReal => type == QueueUserType.real;
  bool get isDummy => type == QueueUserType.dummy;
  bool get isTyping => typingState == TypingState.typing;

  int get remainingTurnSeconds {
    if (turnStartTime == null) return 0;
    const turnDurationSeconds = 60;
    final elapsed = DateTime.now().difference(turnStartTime!).inSeconds;
    final remaining = turnDurationSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  int get remainingReactionSeconds {
    if (reactionStartTime == null) return 0;
    const reactionDurationSeconds = 60;
    final elapsed = DateTime.now().difference(reactionStartTime!).inSeconds;
    final remaining = reactionDurationSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  @override
  String toString() {
    return 'QueueUser(id: $id, displayName: $displayName, type: $type, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QueueUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}