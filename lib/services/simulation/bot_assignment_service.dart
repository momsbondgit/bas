import '../../models/user/bot_user.dart';
import '../data/local_storage_service.dart';
import '../core/world_service.dart';

class BotAssignmentService {
  final LocalStorageService _localStorageService = LocalStorageService();
  final WorldService _worldService = WorldService();

  /// Assigns bots based on vibe check answers
  Future<List<BotUser>> assignBotsBasedOnVibeCheck(Map<int, String> vibeAnswers) async {
    // Get current world
    final currentWorldName = await _localStorageService.getCurrentWorld();
    final worldConfig = _worldService.getWorldByDisplayName(currentWorldName) ?? _worldService.defaultWorld;

    // Count A vs B answers
    int aCount = 0;

    vibeAnswers.forEach((_, answer) {
      if (answer == 'A') {
        aCount++;
      }
    });

    // Determine table based on vibe answers
    String tableId;
    List<BotUser> assignedBots;

    if (aCount == 3) {
      // Pure A answers = Table 1 (chaotic/edgy)
      tableId = '1';
      assignedBots = worldConfig.botTable1;
    } else if (aCount == 0) {
      // Pure B answers = Table 2 (goofy/soft)
      tableId = '2';
      assignedBots = worldConfig.botTable2;
    } else {
      // Mixed answers (1A/2B or 2A/1B) = Table 3 (balanced/mixed)
      tableId = '3';
      assignedBots = worldConfig.botTable3;
    }

    // Save table ID and assigned bots to local storage
    await _localStorageService.setTableId(tableId);
    await _localStorageService.setVibeAnswers(vibeAnswers);
    await _localStorageService.setAssignedBots(assignedBots.map((bot) => bot.botId).toList());

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
      final worldConfig = _worldService.getWorldByDisplayName(currentWorldName) ?? _worldService.defaultWorld;

      final tableId = await _localStorageService.getTableId();
      if (tableId == null) {
        return [];
      }

      // Return the appropriate bot table from current world
      if (tableId == '1') {
        return worldConfig.botTable1;
      } else if (tableId == '2') {
        return worldConfig.botTable2;
      } else {
        return worldConfig.botTable3;
      }
    } catch (e) {
      print('[BotAssignmentService] Error getting assigned bots: $e');
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
    final worldConfig = _worldService.getWorldByDisplayName(currentWorldName) ?? _worldService.defaultWorld;

    if (tableId == '1') {
      return worldConfig.botTable1;
    } else if (tableId == '2') {
      return worldConfig.botTable2;
    } else {
      return worldConfig.botTable3;
    }
  }

  /// Get specific bot by ID from current world
  Future<BotUser?> getBotById(String botId) async {
    final currentWorldName = await _localStorageService.getCurrentWorld();
    final worldConfig = _worldService.getWorldByDisplayName(currentWorldName) ?? _worldService.defaultWorld;

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

    // Check table 3
    for (final bot in worldConfig.botTable3) {
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
}