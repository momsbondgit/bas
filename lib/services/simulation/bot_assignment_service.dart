import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user/bot_user.dart';
import '../core/world_service.dart';
import '../data/local_storage_service.dart';

class BotAssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> assignBotsToUser(String anonId) async {
    try {
      print('[BotAssignmentService] Starting bot assignment for user: $anonId');
      
      // Check if user already has bot assignments
      final existingAssignments = await _firestore
          .collection('users')
          .doc(anonId)
          .collection('assigned_bots')
          .get();

      if (existingAssignments.docs.isNotEmpty) {
        print('[BotAssignmentService] User already has ${existingAssignments.docs.length} bots assigned, skipping');
        return;
      }

      // Get user's world configuration
      final localStorageService = LocalStorageService();
      final worldService = WorldService();
      final userWorldName = await localStorageService.getWorldOrMigrateFromGender();
      final worldConfig = worldService.getWorldByDisplayName(userWorldName) ?? worldService.defaultWorld;

      // Generate seed based on anonId for consistent randomization per user
      final seed = anonId.hashCode.abs();
      
      print('[BotAssignmentService] 🆕 First-time user assignment:');
      print('[BotAssignmentService] - Total bots in world: ${worldConfig.botPool.length}');
      print('[BotAssignmentService] - Assigning 6 random bots');
      print('[BotAssignmentService] - Max possible fresh visits: ${(worldConfig.botPool.length / 6).floor()}');
      
      final assignedBots = _getRandomBotSubset(worldConfig.botPool, 6, seed: seed);
      
      print('[BotAssignmentService] Selected bots for first visit:');
      for (int i = 0; i < assignedBots.length; i++) {
        final bot = assignedBots[i];
        print('[BotAssignmentService] - ${i+1}. ${bot.nickname} (${bot.botId}) 🆕 NEW');
      }

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
      // Get the current session count to filter for current session's bots
      final localStorageService = LocalStorageService();
      final sessionCount = await localStorageService.getSessionCount();
      
      // Get assignments for current session (or all if first session)
      final assignmentsSnapshot = await _firestore
          .collection('users')
          .doc(anonId)
          .collection('assigned_bots')
          .orderBy('assignedAt', descending: true)
          .limit(6)  // Only get the most recent 6 bots
          .get();

      if (assignmentsSnapshot.docs.isEmpty) {
        return [];
      }

      // Get user's world configuration to find bots
      final worldService = WorldService();
      final userWorldName = await localStorageService.getWorldOrMigrateFromGender();
      final worldConfig = worldService.getWorldByDisplayName(userWorldName) ?? worldService.defaultWorld;

      final List<BotUser> assignedBots = [];
      for (final doc in assignmentsSnapshot.docs) {
        final botId = doc.id;
        final bot = _getBotById(worldConfig.botPool, botId);
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
      print('[BotAssignmentService] Ensuring user $anonId has bots');
      final hasAssignments = await hasAssignedBots(anonId);
      
      if (hasAssignments) {
        print('[BotAssignmentService] User already has bot assignments');
        return;
      }
      
      print('[BotAssignmentService] User needs bot assignments, assigning now...');
      await assignBotsToUser(anonId);
      
    } catch (e) {
      print('[BotAssignmentService] ERROR ensuring user has bots: $e');
      throw Exception('Failed to ensure user has bot assignments: $e');
    }
  }
  
  /// Reassigns fresh bots to returning users for a new experience
  Future<void> reassignBotsForReturningUser(String anonId, int sessionCount) async {
    try {
      print('[BotAssignmentService] Reassigning bots for returning user: $anonId (session $sessionCount)');
      
      // Get all bot IDs this user has ever had (not just current session)
      final allPreviousAssignments = await _firestore
          .collection('users')
          .doc(anonId)
          .collection('assigned_bots')
          .get();
      
      final previousBotIds = allPreviousAssignments.docs.map((doc) => doc.id).toSet();
      print('[BotAssignmentService] User has had ${previousBotIds.length} different bots before');
      
      // Get user's world configuration
      final localStorageService = LocalStorageService();
      final worldService = WorldService();
      final userWorldName = await localStorageService.getWorldOrMigrateFromGender();
      final worldConfig = worldService.getWorldByDisplayName(userWorldName) ?? worldService.defaultWorld;
      
      // Filter out bots the user has already had
      final availableBots = worldConfig.botPool.where((bot) => 
        !previousBotIds.contains(bot.botId)
      ).toList();
      
      print('[BotAssignmentService] Bot pool analysis:');
      print('[BotAssignmentService] - Total bots in world: ${worldConfig.botPool.length}');
      print('[BotAssignmentService] - Bots user has had before: ${previousBotIds.length}');
      print('[BotAssignmentService] - New bots available: ${availableBots.length}');
      print('[BotAssignmentService] - Visit number: $sessionCount');
      
      // Calculate how many fresh visits this user can have
      final maxFreshVisits = (worldConfig.botPool.length / 6).floor();
      final isRepeatingBots = availableBots.length < 6;
      
      print('[BotAssignmentService] - Max fresh visits possible: $maxFreshVisits');
      print('[BotAssignmentService] - User will get repeat bots: $isRepeatingBots');
      
      // If not enough new bots available, use all bots (user has seen them all)
      final botsToChooseFrom = availableBots.length >= 6 ? availableBots : worldConfig.botPool;
      
      if (isRepeatingBots) {
        print('[BotAssignmentService] ⚠️ User has seen most bots - using full pool for assignment');
      } else {
        print('[BotAssignmentService] ✅ User gets ${availableBots.length} completely new bots');
      }
      
      // Generate new seed based on anonId + session count for fresh randomization
      final seed = (anonId.hashCode.abs() + sessionCount).abs();
      final newAssignedBots = _getRandomBotSubset(botsToChooseFrom, 6, seed: seed);
      
      print('[BotAssignmentService] Selected bots for this visit:');
      for (int i = 0; i < newAssignedBots.length; i++) {
        final bot = newAssignedBots[i];
        final isNewBot = !previousBotIds.contains(bot.botId);
        final status = isNewBot ? '🆕 NEW' : '🔄 REPEAT';
        print('[BotAssignmentService] - ${i+1}. ${bot.nickname} (${bot.botId}) $status');
      }
      
      // Store new assignments in Firestore (keep old ones for history)
      final batch = _firestore.batch();
      for (final bot in newAssignedBots) {
        final docRef = _firestore
            .collection('users')
            .doc(anonId)
            .collection('assigned_bots')
            .doc(bot.botId);

        batch.set(docRef, {
          'nickname': bot.nickname,
          'assignedAt': FieldValue.serverTimestamp(),
          'sessionNumber': sessionCount, // Track which session these bots are for
        });
      }

      await batch.commit();
      print('[BotAssignmentService] ✅ Successfully reassigned bots for returning user');
      print('[BotAssignmentService] 📊 User statistics:');
      final totalUniqueBots = previousBotIds.union(newAssignedBots.map((b) => b.botId).toSet());
      print('[BotAssignmentService] - Total unique bots experienced: ${totalUniqueBots.length}');
      print('[BotAssignmentService] - Visits completed: $sessionCount');
      print('[BotAssignmentService] - Fresh visits remaining: ${maxFreshVisits - sessionCount + 1}');
    } catch (e) {
      throw Exception('Failed to reassign bots for returning user: $e');
    }
  }

  /// Helper method to get random subset from world-specific bot pool
  List<BotUser> _getRandomBotSubset(List<BotUser> botPool, int count, {int? seed}) {
    if (count > botPool.length) {
      throw ArgumentError('Cannot select $count bots from pool of ${botPool.length}');
    }

    final List<BotUser> shuffled = List.from(botPool);
    if (seed != null) {
      shuffled.shuffle(Random(seed));
    } else {
      shuffled.shuffle();
    }
    
    return shuffled.take(count).toList();
  }

  /// Helper method to get bot by ID from world-specific bot pool
  BotUser? _getBotById(List<BotUser> botPool, String botId) {
    try {
      return botPool.firstWhere((bot) => bot.botId == botId);
    } catch (e) {
      return null;
    }
  }
}