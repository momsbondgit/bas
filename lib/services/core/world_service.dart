import '../../config/world_config.dart';
import '../../config/worlds/girl_meets_college_world.dart';
import '../../config/worlds/guy_meets_college_world.dart';

class WorldService {
  static final WorldService _instance = WorldService._internal();
  factory WorldService() => _instance;
  WorldService._internal();

  // All available worlds
  static const List<WorldConfig> _availableWorlds = [
    GirlMeetsCollegeWorld.config,
    GuyMeetsCollegeWorld.config,
  ];

  // Get all available worlds
  List<WorldConfig> getAllWorlds() {
    return List.from(_availableWorlds);
  }

  // Get world by ID
  WorldConfig? getWorldById(String id) {
    try {
      return _availableWorlds.firstWhere((world) => world.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get world by display name
  WorldConfig? getWorldByDisplayName(String displayName) {
    try {
      return _availableWorlds.firstWhere((world) => world.displayName == displayName);
    } catch (e) {
      return null;
    }
  }

  // Check if world exists
  bool worldExists(String id) {
    return _availableWorlds.any((world) => world.id == id);
  }

  // Get world count
  int get worldCount => _availableWorlds.length;

  // Get default world (Girl Meets College for backward compatibility)
  WorldConfig get defaultWorld => GirlMeetsCollegeWorld.config;

  // Validate world configuration
  bool isValidWorldConfig(WorldConfig config) {
    if (config.id.isEmpty || 
        config.displayName.isEmpty ||
        config.topicOfDay.isEmpty ||
        config.modalTitle.isEmpty ||
        config.entryTileImage.isEmpty ||
        config.botPool.isEmpty) {
      return false;
    }

    // Check for duplicate bot IDs within the world
    final botIds = config.botPool.map((bot) => bot.botId).toSet();
    if (botIds.length != config.botPool.length) {
      return false; // Duplicate bot IDs found
    }

    return true;
  }

  // Get worlds summary for logging/debugging
  Map<String, dynamic> getWorldsSummary() {
    return {
      'totalWorlds': worldCount,
      'worlds': _availableWorlds.map((world) => {
        'id': world.id,
        'displayName': world.displayName,
        'botCount': world.botPool.length,
        'isValid': isValidWorldConfig(world),
      }).toList(),
    };
  }
}