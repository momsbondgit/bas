import 'queue_user.dart';
import 'message.dart';

enum QueuePhase {
  waiting,
  typing,
  submitted,
  rotating,
}

class RitualQueueState {
  const RitualQueueState({
    required this.activeUserId,
    required this.activeDisplayName,
    required this.phase,
    required this.remainingTime,
    required this.userQueue,
    this.currentMessage,
    this.showRotationBanner = false,
    this.rotationTargetDisplayName,
  });

  final String activeUserId;
  final String activeDisplayName;
  final QueuePhase phase;
  final Duration remainingTime;
  final List<QueueUser> userQueue;
  final Message? currentMessage;
  final bool showRotationBanner;
  final String? rotationTargetDisplayName;

  bool get isActiveUserTyping => phase == QueuePhase.typing;
  bool get hasCurrentMessage => currentMessage != null;
  bool get reactionsEnabled => phase == QueuePhase.submitted;

  RitualQueueState copyWith({
    String? activeUserId,
    String? activeDisplayName,
    QueuePhase? phase,
    Duration? remainingTime,
    List<QueueUser>? userQueue,
    Message? currentMessage,
    bool? showRotationBanner,
    String? rotationTargetDisplayName,
  }) {
    return RitualQueueState(
      activeUserId: activeUserId ?? this.activeUserId,
      activeDisplayName: activeDisplayName ?? this.activeDisplayName,
      phase: phase ?? this.phase,
      remainingTime: remainingTime ?? this.remainingTime,
      userQueue: userQueue ?? this.userQueue,
      currentMessage: currentMessage ?? this.currentMessage,
      showRotationBanner: showRotationBanner ?? this.showRotationBanner,
      rotationTargetDisplayName: rotationTargetDisplayName ?? this.rotationTargetDisplayName,
    );
  }

  RitualQueueState clearCurrentMessage() {
    return copyWith(
      currentMessage: null,
      phase: QueuePhase.waiting,
    );
  }

  RitualQueueState startTyping() {
    return copyWith(
      phase: QueuePhase.typing,
      currentMessage: null,
    );
  }

  RitualQueueState submitMessage(Message message) {
    return copyWith(
      phase: QueuePhase.submitted,
      currentMessage: message,
    );
  }

  RitualQueueState startRotation(String nextDisplayName) {
    return copyWith(
      phase: QueuePhase.rotating,
      showRotationBanner: true,
      rotationTargetDisplayName: nextDisplayName,
    );
  }

  RitualQueueState completeRotation(String newActiveUserId, String newActiveDisplayName, List<QueueUser> newQueue) {
    return copyWith(
      activeUserId: newActiveUserId,
      activeDisplayName: newActiveDisplayName,
      userQueue: newQueue,
      phase: QueuePhase.waiting,
      currentMessage: null,
      showRotationBanner: false,
      rotationTargetDisplayName: null,
    );
  }

  RitualQueueState dismissRotationBanner() {
    return copyWith(
      showRotationBanner: false,
      rotationTargetDisplayName: null,
    );
  }

  RitualQueueState updateReactions(Map<String, ReactionType> reactions) {
    if (currentMessage == null) return this;
    
    return copyWith(
      currentMessage: currentMessage!.copyWith(reactions: reactions),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activeUserId': activeUserId,
      'activeDisplayName': activeDisplayName,
      'phase': phase.name,
      'remainingTimeMs': remainingTime.inMilliseconds,
      'userQueue': userQueue.map((user) => user.toMap()).toList(),
      'currentMessage': currentMessage?.toMap(),
      'showRotationBanner': showRotationBanner,
      'rotationTargetDisplayName': rotationTargetDisplayName,
    };
  }

  factory RitualQueueState.fromMap(Map<String, dynamic> map) {
    return RitualQueueState(
      activeUserId: map['activeUserId'] as String,
      activeDisplayName: map['activeDisplayName'] as String,
      phase: QueuePhase.values.firstWhere((p) => p.name == map['phase']),
      remainingTime: Duration(milliseconds: map['remainingTimeMs'] as int),
      userQueue: (map['userQueue'] as List<dynamic>)
          .map((userMap) => QueueUser.fromMap(userMap as Map<String, dynamic>))
          .toList(),
      currentMessage: map['currentMessage'] != null
          ? Message.fromMap(map['currentMessage'] as Map<String, dynamic>)
          : null,
      showRotationBanner: map['showRotationBanner'] as bool? ?? false,
      rotationTargetDisplayName: map['rotationTargetDisplayName'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RitualQueueState &&
        other.activeUserId == activeUserId &&
        other.activeDisplayName == activeDisplayName &&
        other.phase == phase &&
        other.remainingTime == remainingTime &&
        other.showRotationBanner == showRotationBanner &&
        other.rotationTargetDisplayName == rotationTargetDisplayName;
  }

  @override
  int get hashCode {
    return activeUserId.hashCode ^
        activeDisplayName.hashCode ^
        phase.hashCode ^
        remainingTime.hashCode ^
        showRotationBanner.hashCode ^
        rotationTargetDisplayName.hashCode;
  }

  @override
  String toString() {
    return 'RitualQueueState(activeUserId: $activeUserId, activeDisplayName: $activeDisplayName, phase: $phase, remainingTime: $remainingTime, userQueue: ${userQueue.length}, hasMessage: ${currentMessage != null}, showBanner: $showRotationBanner)';
  }
}