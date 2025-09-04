import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bot_user.dart';
import '../config/bot_pool.dart';

class BotAssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> assignBotsToUser(String anonId) async {
    try {
      // Check if user already has bot assignments
      final existingAssignments = await _firestore
          .collection('users')
          .doc(anonId)
          .collection('assigned_bots')
          .get();

      if (existingAssignments.docs.isNotEmpty) {
        return;
      }

      // Generate seed based on anonId for consistent randomization per user
      final seed = anonId.hashCode.abs();
      final assignedBots = BotPool.getRandomBotSubset(6, seed: seed);

      // Store assignments in Firestore using batch write for efficiency
      final batch = _firestore.batch();
      for (final bot in assignedBots) {
        final docRef = _firestore
            .collection('users')
            .doc(anonId)
            .collection('assigned_bots')
            .doc(bot.botId);

        batch.set(docRef, {
          'nickname': bot.nickname,
          'assignedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to assign bots to user: $e');
    }
  }

  Future<List<BotUser>> getAssignedBots(String anonId) async {
    try {
      final assignmentsSnapshot = await _firestore
          .collection('users')
          .doc(anonId)
          .collection('assigned_bots')
          .get();

      if (assignmentsSnapshot.docs.isEmpty) {
        return [];
      }

      final List<BotUser> assignedBots = [];
      for (final doc in assignmentsSnapshot.docs) {
        final botId = doc.id;
        final bot = BotPool.getBotById(botId);
        if (bot != null) {
          assignedBots.add(bot);
        }
      }

      return assignedBots;
    } catch (e) {
      throw Exception('Failed to retrieve assigned bots: $e');
    }
  }

  Future<bool> hasAssignedBots(String anonId) async {
    try {
      final assignmentsSnapshot = await _firestore
          .collection('users')
          .doc(anonId)
          .collection('assigned_bots')
          .limit(1)
          .get();

      return assignmentsSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Ensures user has bot assignments, creates them if missing (for existing users)
  Future<void> ensureUserHasBots(String anonId) async {
    try {
      final hasAssignments = await hasAssignedBots(anonId);
      
      if (hasAssignments) {
        return;
      }
      
      await assignBotsToUser(anonId);
      
    } catch (e) {
      throw Exception('Failed to ensure user has bot assignments: $e');
    }
  }
}