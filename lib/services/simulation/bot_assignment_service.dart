import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user/bot_user.dart';
import '../data/local_storage_service.dart';
import '../core/world_service.dart';
import '../auth/auth_service.dart';

class BotAssignmentService {
  final LocalStorageService _localStorageService = LocalStorageService();
  final WorldService _worldService = WorldService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Assigns bots based on vibe check answers with uniqueness tracking
  Future<List<BotUser>> assignBotsBasedOnVibeCheck(Map<int, String> vibeAnswers) async {
    print('🤖 [BotAssignment] Starting bot assignment process...');

    // Get current world and user ID
    final currentWorldName = await _localStorageService.getCurrentWorld();
    var worldConfig = _worldService.getWorldByDisplayName(currentWorldName) ?? _worldService.defaultWorld;

    // Fetch dynamic bot data for Girl World
    if (worldConfig.id == 'girl-meets-college') {
      worldConfig = await _worldService.getWorldByIdAsync(worldConfig.id);
    }

    final anonId = await _authService.getOrCreateAnonId();

    print('🌍 [BotAssignment] World: $currentWorldName (${worldConfig.id})');
    print('👤 [BotAssignment] User ID: $anonId');
    print('📝 [BotAssignment] Vibe answers: $vibeAnswers');

    // Check if user already has assigned bots (returning user)
    print('🔍 [BotAssignment] Checking for existing assignment...');
    final existingAssignment = await _getExistingBotAssignment(anonId, worldConfig.id);
    if (existingAssignment.isNotEmpty) {
      print('✅ [BotAssignment] Found existing assignment: ${existingAssignment.map((b) => b.botId).toList()}');
      return existingAssignment;
    }
    print('❌ [BotAssignment] No existing assignment found');

    // Count A vs B answers to determine table
    int aCount = 0;
    vibeAnswers.forEach((_, answer) {
      if (answer == 'A') {
        aCount++;
      }
    });

    print('🔢 [BotAssignment] A answers count: $aCount out of ${vibeAnswers.length}');

    // Determine table based on majority (≥2 answers wins)
    String tableId;
    List<BotUser> tableBots;

    if (aCount >= 2) {
      // Majority A answers (2-3 A's) = Table 1 (chaotic/edgy)
      tableId = '1';
      tableBots = worldConfig.botTable1;
      print('⚡ [BotAssignment] Assigned to Table 1 (chaotic/edgy) - ${tableBots.length} bots available');
    } else {
      // Majority B answers (2-3 B's) = Table 2 (chill/soft)
      tableId = '2';
      tableBots = worldConfig.botTable2;
      print('😊 [BotAssignment] Assigned to Table 2 (chill/soft) - ${tableBots.length} bots available');
    }

    // Check if table has space (max 2 users per table)
    print('🏗️ [BotAssignment] Checking table capacity...');
    final canAssign = await _canAssignBotsToTable(tableId, worldConfig.id);
    if (!canAssign) {
      print('🚫 [BotAssignment] Table $tableId is FULL (2 users max)');
      return [];
    }
    print('✅ [BotAssignment] Table $tableId has space available');

    // Get available bots (not assigned to other users)
    print('🔍 [BotAssignment] Finding available bots in table $tableId...');
    final availableBots = await _getAvailableBotsInTable(tableId, worldConfig.id, tableBots);
    print('📊 [BotAssignment] Available bots: ${availableBots.map((b) => b.botId).toList()} (${availableBots.length} total)');

    if (availableBots.length < 5) {
      print('⚠️ [BotAssignment] Not enough bots available (need 5, have ${availableBots.length})');
      return [];
    }

    // Take first 5 available bots (these are already filtered to exclude assigned ones)
    final assignedBots = availableBots.take(5).toList();
    final assignedBotIds = assignedBots.map((bot) => bot.botId).toList();
    print('✨ [BotAssignment] Assigning available bots: $assignedBotIds');

    // Store assignment in Firestore (using existing accounts collection)
    print('💾 [BotAssignment] Storing assignment in Firestore...');
    await _storeBotAssignment(anonId, assignedBotIds, tableId, worldConfig.id);

    // Save to local storage for quick access
    print('💾 [BotAssignment] Saving to local storage...');
    await _localStorageService.setTableId(tableId);
    await _localStorageService.setVibeAnswers(vibeAnswers);
    await _localStorageService.setAssignedBots(assignedBotIds);

    print('🎉 [BotAssignment] Assignment complete! Returning ${assignedBots.length} bots');
    return assignedBots;
  }

  /// Get assigned bots for a user
  Future<List<BotUser>> getAssignedBots() async {
    try {
      // Get saved bot IDs from local storage
      final botIds = await _localStorageService.getAssignedBots();
      if (botIds == null || botIds.isEmpty) {
        // No bots assigned yet
        return [];
      }

      // Get current world and table ID
      final currentWorldName = await _localStorageService.getCurrentWorld();
      var worldConfig = _worldService.getWorldByDisplayName(currentWorldName) ?? _worldService.defaultWorld;

      // Fetch dynamic bot data for Girl World
      if (worldConfig.id == 'girl-meets-college') {
        worldConfig = await _worldService.getWorldByIdAsync(worldConfig.id);
      }

      final tableId = await _localStorageService.getTableId();
      if (tableId == null) {
        return [];
      }

      // Get the appropriate bot table from current world
      List<BotUser> allTableBots;
      if (tableId == '1') {
        allTableBots = worldConfig.botTable1;
      } else {
        // Default to Table 2 for any non-1 table ID
        allTableBots = worldConfig.botTable2;
      }

      // Filter to only return the specific bots that were assigned to this user
      final assignedBots = allTableBots.where((bot) => botIds.contains(bot.botId)).toList();
      print('🎯 [GetAssignedBots] User has ${assignedBots.length} assigned bots: ${assignedBots.map((b) => b.botId).toList()}');

      return assignedBots;
    } catch (e) {
      // Principle: Graceful degradation - When bot assignment fails, system continues with empty bot list rather than crashing user experience
      return [];
    }
  }

  /// Check if user has assigned bots
  Future<bool> hasAssignedBots() async {
    final botIds = await _localStorageService.getAssignedBots();
    return botIds != null && botIds.isNotEmpty;
  }

  /// Get bot table by ID for current world
  Future<List<BotUser>> getBotTable(String tableId) async {
    final currentWorldName = await _localStorageService.getCurrentWorld();
    var worldConfig = _worldService.getWorldByDisplayName(currentWorldName) ?? _worldService.defaultWorld;

    // Fetch dynamic bot data for Girl World
    if (worldConfig.id == 'girl-meets-college') {
      worldConfig = await _worldService.getWorldByIdAsync(worldConfig.id);
    }

    if (tableId == '1') {
      return worldConfig.botTable1;
    } else {
      // Default to Table 2 for any non-1 table ID
      return worldConfig.botTable2;
    }
  }

  /// Get specific bot by ID from current world
  Future<BotUser?> getBotById(String botId) async {
    final currentWorldName = await _localStorageService.getCurrentWorld();
    var worldConfig = _worldService.getWorldByDisplayName(currentWorldName) ?? _worldService.defaultWorld;

    // Fetch dynamic bot data for Girl World
    if (worldConfig.id == 'girl-meets-college') {
      worldConfig = await _worldService.getWorldByIdAsync(worldConfig.id);
    }

    // Check table 1
    for (final bot in worldConfig.botTable1) {
      if (bot.botId == botId) {
        return bot;
      }
    }

    // Check table 2
    for (final bot in worldConfig.botTable2) {
      if (bot.botId == botId) {
        return bot;
      }
    }

    return null;
  }

  /// Clear assigned bots (for testing/reset)
  Future<void> clearAssignedBots() async {
    await _localStorageService.setAssignedBots([]);
    await _localStorageService.setTableId('');
  }

  /// Get existing bot assignment for returning user
  Future<List<BotUser>> _getExistingBotAssignment(String anonId, String worldId) async {
    try {
      print('🔍 [ExistingAssignment] Checking Firestore for user: $anonId in world: $worldId');
      final doc = await _firestore.collection('accounts').doc(anonId).get();

      if (doc.exists) {
        print('📄 [ExistingAssignment] Document found');
        final data = doc.data();
        final assignedBotIds = data?['assignedBots'] as List<dynamic>?;
        final storedWorldId = data?['worldId'] as String?;
        final tableId = data?['tableId'] as String?;

        print('📊 [ExistingAssignment] Data: botIds=$assignedBotIds, worldId=$storedWorldId, tableId=$tableId');

        if (assignedBotIds != null && storedWorldId == worldId) {
          print('✅ [ExistingAssignment] Found matching assignment for this world');
          final botIds = assignedBotIds.cast<String>();
          final bots = <BotUser>[];

          for (final botId in botIds) {
            final bot = await getBotById(botId);
            if (bot != null) {
              bots.add(bot);
            }
          }

          if (bots.length == botIds.length) {
            print('✅ [ExistingAssignment] All bots found, syncing to local storage');
            await _localStorageService.setAssignedBots(botIds);
            await _localStorageService.setTableId(tableId ?? '');
            return bots;
          } else {
            print('⚠️ [ExistingAssignment] Some bots missing, got ${bots.length} of ${botIds.length}');
          }
        } else {
          print('❌ [ExistingAssignment] No matching assignment (wrong world or no bots)');
        }
      } else {
        print('❌ [ExistingAssignment] No document found for user');
      }
    } catch (e) {
      print('🚨 [ExistingAssignment] Error: $e');
    }
    return [];
  }

  /// Check if table has space for new user (max 2 users per table)
  Future<bool> _canAssignBotsToTable(String tableId, String worldId) async {
    try {
      print('🏗️ [TableCapacity] Checking capacity for table $tableId in world $worldId');
      final querySnapshot = await _getTableUsers(tableId, worldId);

      final currentUsers = querySnapshot.docs.length;
      final canAssign = currentUsers < 2;
      print('📊 [TableCapacity] Current users in table: $currentUsers/2, can assign: $canAssign');

      // Log existing users for debugging
      if (querySnapshot.docs.isNotEmpty) {
        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          print('👤 [TableCapacity] Existing user: ${doc.id}, bots: ${data['assignedBots']}');
        }
      }

      return canAssign;
    } catch (e) {
      print('🚨 [TableCapacity] Error checking capacity: $e');
      return true;
    }
  }

  /// Get available bots in table (not assigned to other users)
  Future<List<BotUser>> _getAvailableBotsInTable(String tableId, String worldId, List<BotUser> tableBots) async {
    try {
      print('🔍 [AvailableBots] Finding available bots for table $tableId in world $worldId');
      print('🤖 [AvailableBots] Total bots in table: ${tableBots.map((b) => b.botId).toList()}');

      final querySnapshot = await _getTableUsers(tableId, worldId);
      print('👥 [AvailableBots] Found ${querySnapshot.docs.length} users with assignments in this table');

      // Collect all assigned bot IDs
      final assignedBotIds = <String>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final botIds = data['assignedBots'] as List<dynamic>?;
        if (botIds != null) {
          final userBotIds = botIds.cast<String>();
          assignedBotIds.addAll(userBotIds);
          print('👤 [AvailableBots] User ${doc.id} has bots: $userBotIds');
        }
      }

      print('🚫 [AvailableBots] Already assigned bot IDs: ${assignedBotIds.toList()}');

      // Filter out assigned bots
      final availableBots = tableBots.where((bot) => !assignedBotIds.contains(bot.botId)).toList();
      print('✅ [AvailableBots] Available bots: ${availableBots.map((b) => b.botId).toList()}');

      return availableBots;
    } catch (e) {
      print('🚨 [AvailableBots] Error getting available bots: $e');
      return tableBots;
    }
  }

  /// Get all users assigned to a specific table in a world
  Future<QuerySnapshot<Map<String, dynamic>>> _getTableUsers(String tableId, String worldId) async {
    return _firestore
        .collection('accounts')
        .where('worldId', isEqualTo: worldId)
        .where('tableId', isEqualTo: tableId)
        .where('assignedBots', isNotEqualTo: null)
        .get();
  }

  /// Store bot assignment in Firestore
  Future<void> _storeBotAssignment(String anonId, List<String> botIds, String tableId, String worldId) async {
    try {
      print('💾 [StoreAssignment] Storing in Firestore: user=$anonId, bots=$botIds, table=$tableId, world=$worldId');
      await _firestore.collection('accounts').doc(anonId).set({
        'assignedBots': botIds,
        'tableId': tableId,
        'worldId': worldId,
        'botAssignmentTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ [StoreAssignment] Successfully stored assignment');
    } catch (e) {
      print('🚨 [StoreAssignment] Error storing assignment: $e');
    }
  }
}