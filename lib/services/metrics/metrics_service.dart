import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/metrics/compass_metrics.dart';

class MetricsService {
  static final MetricsService _instance = MetricsService._internal();
  factory MetricsService() => _instance;
  MetricsService._internal();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<CompassMetricsList> getUserCompassMetrics() async {
    try {
      final accountsSnapshot = await _firestore.collection('accounts').get();
      final postsSnapshot = await _firestore.collection('posts').get();

      final users = <UserCompassMetrics>[];

      for (final accountDoc in accountsSnapshot.docs) {
        final accountData = accountDoc.data();
        final userId = accountDoc.id;

        // Skip bot users - only include real users
        final isBot = accountData['isBot'] ?? false;
        if (isBot) continue;

        // Get user info
        final nickname = accountData['nickname'] ?? 'Anonymous';

        // North - Belonging: Use worldVisitCount field
        final worldVisitCount = accountData['worldVisitCount'] ?? 1;
        final returnCount = worldVisitCount > 1 ? worldVisitCount - 1 : 0;

        // East - Flow: Read from account fields (will be updated by session services)
        final sessionsCompleted = accountData['sessionsCompleted'] ?? 0;
        final totalSessions = accountData['totalSessions'] ?? 0;

        // South - Voice: Count posts by this user
        final userPosts = postsSnapshot.docs.where((doc) => doc.data()['userId'] == userId).length;

        // West - Affection: Read from account field (will be updated by reaction services)
        final reactionsGiven = accountData['reactionsGiven'] ?? 0;

        // Get goodbye message if user sent one
        final goodbyeMessage = accountData['goodbyeMessage'] as String?;

        // Get last visit timestamp
        final lastUpdated = accountData['lastUpdated'] as Timestamp?;
        final lastVisit = lastUpdated?.toDate();

        // Determine user status
        String status = 'Active';
        if (returnCount > 0) {
          status = 'Returning';
        }
        if (sessionsCompleted == totalSessions && totalSessions > 0) {
          status = 'Completed';
        }

        users.add(UserCompassMetrics(
          userId: userId,
          nickname: nickname,
          returnCount: returnCount,
          sessionsCompleted: sessionsCompleted,
          totalSessions: totalSessions,
          postsCreated: userPosts,
          reactionsGiven: reactionsGiven,
          status: status,
          lastVisit: lastVisit,
          goodbyeMessage: goodbyeMessage,
        ));
      }

      return CompassMetricsList(
        users: users,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return CompassMetricsList.empty();
    }
  }

}