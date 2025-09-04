import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bot_user.dart';
import '../config/bot_pool.dart';

class BotAssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> assignBotsToUser(String anonId) async {
    print('DEBUG BotAssignmentService.assignBotsToUser: Starting bot assignment for user: $anonId');

    try {
      // Check if user already has bot assignments
      final existingAssignments = await _firestore
          .collection('users')
          .doc(anonId)
          .collection('assigned_bots')
          .get();

      if (existingAssignments.docs.isNotEmpty) {
        print('DEBUG BotAssignmentService.assignBotsToUser: User already has ${existingAssignments.docs.length} bot assignments, skipping');
        return;
      }

      // Generate seed based on anonId for consistent randomization per user
      final seed = anonId.hashCode.abs();
      final assignedBots = BotPool.getRandomBotSubset(6, seed: seed);

      print('DEBUG BotAssignmentService.assignBotsToUser: Assigning ${assignedBots.length} bots to user');

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
      print('DEBUG BotAssignmentService.assignBotsToUser: Successfully assigned bots to Firebase');
    } catch (e) {
      print('DEBUG BotAssignmentService.assignBotsToUser: ERROR - $e');
      throw Exception('Failed to assign bots to user: $e');
    }
  }

  Future<List<BotUser>> getAssignedBots(String anonId) async {
    print('DEBUG BotAssignmentService.getAssignedBots: Fetching assigned bots for user: $anonId');

    try {
      final assignmentsSnapshot = await _firestore
          .collection('users')
          .doc(anonId)
          .collection('assigned_bots')
          .get();

      if (assignmentsSnapshot.docs.isEmpty) {
        print('DEBUG BotAssignmentService.getAssignedBots: No bot assignments found for user');
        return [];
      }

      final List<BotUser> assignedBots = [];
      for (final doc in assignmentsSnapshot.docs) {
        final botId = doc.id;
        final bot = BotPool.getBotById(botId);
        if (bot != null) {
          assignedBots.add(bot);
        } else {
          print('DEBUG BotAssignmentService.getAssignedBots: WARNING - Bot with ID $botId not found in pool');
        }
      }

      print('DEBUG BotAssignmentService.getAssignedBots: Retrieved ${assignedBots.length} assigned bots');
      return assignedBots;
    } catch (e) {
      print('DEBUG BotAssignmentService.getAssignedBots: ERROR - $e');
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
      print('DEBUG BotAssignmentService.hasAssignedBots: ERROR - $e');
      return false;
    }
  }

  /// Ensures user has bot assignments, creates them if missing (for existing users)
  Future<void> ensureUserHasBots(String anonId) async {
    print('DEBUG BotAssignmentService.ensureUserHasBots: Checking bot assignments for user: $anonId');
    
    try {
      final hasAssignments = await hasAssignedBots(anonId);
      
      if (hasAssignments) {
        print('DEBUG BotAssignmentService.ensureUserHasBots: User already has bot assignments');
        return;
      }
      
      print('DEBUG BotAssignmentService.ensureUserHasBots: User has no assignments, creating new ones');
      await assignBotsToUser(anonId);
      print('DEBUG BotAssignmentService.ensureUserHasBots: Successfully assigned bots to existing user');
      
    } catch (e) {
      print('DEBUG BotAssignmentService.ensureUserHasBots: ERROR - $e');
      throw Exception('Failed to ensure user has bot assignments: $e');
    }
  }
}