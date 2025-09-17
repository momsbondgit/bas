class UserCompassMetrics {
  final String userId;
  final String? nickname;
  final int returnCount;
  final int sessionsCompleted;
  final int totalSessions;
  final int postsCreated;
  final int reactionsGiven;
  final String status;
  final DateTime? lastVisit;
  final String? goodbyeMessage;

  const UserCompassMetrics({
    required this.userId,
    this.nickname,
    required this.returnCount,
    required this.sessionsCompleted,
    required this.totalSessions,
    required this.postsCreated,
    required this.reactionsGiven,
    required this.status,
    this.lastVisit,
    this.goodbyeMessage,
  });
}

class CompassMetricsList {
  final List<UserCompassMetrics> users;
  final DateTime lastUpdated;

  const CompassMetricsList({
    required this.users,
    required this.lastUpdated,
  });

  factory CompassMetricsList.empty() {
    return CompassMetricsList(
      users: [],
      lastUpdated: DateTime.now(),
    );
  }
}