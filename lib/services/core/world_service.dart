import '../../config/world_config.dart';
import '../../config/worlds/girl_meets_college_world.dart';
import '../../config/worlds/guy_meets_college_world.dart';
import '../../models/user/bot_user.dart';
import '../admin/bot_settings_service.dart';

class WorldService {
  static final WorldService _instance = WorldService._internal();
  factory WorldService() => _instance;
  WorldService._internal();

  final BotSettingsService _botSettingsService = BotSettingsService();

  // All available worlds
  static const List<WorldConfig> _availableWorlds = [
    GirlMeetsCollegeWorld.config,
    GuyMeetsCollegeWorld.config,
  ];

  // Get all available worlds
  List<WorldConfig> getAllWorlds() {
    return List.from(_availableWorlds);
  }

  // Get world by ID with dynamic bot data for Girl World
  Future<WorldConfig> getWorldByIdAsync(String id) async {
    final baseConfig = _availableWorlds.firstWhere(
      (world) => world.id == id,
      orElse: () => GirlMeetsCollegeWorld.config,
    );

    if (id == 'girl-meets-college') {
      final botTable1 = await _botSettingsService.getBots(id, 1);
      final botTable2 = await _botSettingsService.getBots(id, 2);

      return WorldConfig(
        id: baseConfig.id,
        displayName: baseConfig.displayName,
        topicOfDay: baseConfig.topicOfDay,
        modalTitle: baseConfig.modalTitle,
        modalDescription: baseConfig.modalDescription,
        entryTileImage: baseConfig.entryTileImage,
        vibeSection: baseConfig.vibeSection,
        headingText: baseConfig.headingText,
        backgroundColorHue: baseConfig.backgroundColorHue,
        characterLimit: baseConfig.characterLimit,
        botTable1: botTable1,
        botTable2: botTable2,
      );
    }

    return baseConfig;
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
        config.botTable1.isEmpty ||
        config.botTable2.isEmpty) {
      return false;
    }

    // Check for duplicate bot IDs within all bot tables
    final allBots = [...config.botTable1, ...config.botTable2];
    final botIds = allBots.map((bot) => bot.botId).toSet();
    if (botIds.length != allBots.length) {
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
        'botTable1Count': world.botTable1.length,
        'botTable2Count': world.botTable2.length,
        'totalBots': world.botTable1.length + world.botTable2.length,
        'isValid': isValidWorldConfig(world),
      }).toList(),
    };
  }
}