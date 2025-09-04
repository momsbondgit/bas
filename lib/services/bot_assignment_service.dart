import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bot_user.dart';
import '../config/world_config.dart';
import '../services/world_service.dart';
import '../services/local_storage_service.dart';

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

      // Get user's world configuration
      final localStorageService = LocalStorageService();
      final worldService = WorldService();
      final userWorldName = await localStorageService.getWorldOrMigrateFromGender();
      final worldConfig = worldService.getWorldByDisplayName(userWorldName) ?? worldService.defaultWorld;

      // Generate seed based on anonId for consistent randomization per user
      final seed = anonId.hashCode.abs();
      final assignedBots = _getRandomBotSubset(worldConfig.botPool, 6, seed: seed);

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

      // Get user's world configuration to find bots
      final localStorageService = LocalStorageService();
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
      final hasAssignments = await hasAssignedBots(anonId);
      
      if (hasAssignments) {
        return;
      }
      
      await assignBotsToUser(anonId);
      
    } catch (e) {
      throw Exception('Failed to ensure user has bot assignments: $e');
    }
  }
  
  /// Reassigns fresh bots to returning users for a new experience
  Future<void> reassignBotsForReturningUser(String anonId, int sessionCount) async {
    try {
      // Delete existing bot assignments
      final existingAssignments = await _firestore
          .collection('users')
          .doc(anonId)
          .collection('assigned_bots')
          .get();

      if (existingAssignments.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in existingAssignments.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Get user's world configuration
      final localStorageService = LocalStorageService();
      final worldService = WorldService();
      final userWorldName = await localStorageService.getWorldOrMigrateFromGender();
      final worldConfig = worldService.getWorldByDisplayName(userWorldName) ?? worldService.defaultWorld;

      // Generate new seed based on anonId + session count for fresh randomization
      final seed = (anonId.hashCode.abs() + sessionCount).abs();
      final newAssignedBots = _getRandomBotSubset(worldConfig.botPool, 6, seed: seed);

      // Store new assignments in Firestore
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