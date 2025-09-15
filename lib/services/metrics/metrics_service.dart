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
      final messagesSnapshot = await _firestore.collection('ritual_messages').get();

      final users = <UserCompassMetrics>[];

      for (final accountDoc in accountsSnapshot.docs) {
        final accountData = accountDoc.data();
        final userId = accountDoc.id;

        // Get user info
        final nickname = accountData['nickname'] ?? 'Anonymous';
        final visitCount = accountData['visitCount'] ?? 1;
        final hasReturned = visitCount > 1;
        final lastUpdated = accountData['lastUpdated'] as Timestamp?;
        final lastVisit = lastUpdated?.toDate();

        // Count posts by this user
        final userPosts = postsSnapshot.docs.where((doc) => doc.data()['userId'] == userId).length;

        // Count sessions for this user (simplified - count unique sessionIds in messages)
        final userMessages = messagesSnapshot.docs.where((doc) => doc.data()['userId'] == userId);
        final sessionIds = userMessages.map((doc) => doc.data()['sessionId'] ?? '').where((id) => id.isNotEmpty).toSet();
        final totalSessions = sessionIds.length;

        // Count completed sessions (sessions with goodbye messages)
        int completedSessions = 0;
        for (final sessionId in sessionIds) {
          final hasGoodbye = userMessages.any((doc) {
            final data = doc.data();
            return data['sessionId'] == sessionId && (data['type'] == 'goodbye' || data['type'] == 'session_end');
          });
          if (hasGoodbye) completedSessions++;
        }

        // Estimate reactions given (placeholder)
        final reactionsGiven = userPosts * 2; // Rough estimate

        users.add(UserCompassMetrics(
          userId: userId,
          nickname: nickname,
          hasReturned: hasReturned,
          sessionsCompleted: completedSessions,
          totalSessions: totalSessions,
          postsCreated: userPosts,
          reactionsGiven: reactionsGiven,
          lastVisit: lastVisit,
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