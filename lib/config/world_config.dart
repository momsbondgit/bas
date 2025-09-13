import '../models/user/bot_user.dart';

class WorldConfig {
  final String id;                    // "girl-meets-college"
  final String displayName;          // "Girl Meets College"
  final String topicOfDay;          // "confess your college experiences"
  final String modalTitle;          // "join the world bestie ✨"
  final String? modalDescription;    // world-specific copy
  final String entryTileImage;      // path to world image
  final List<BotUser> botTable1;   // Chaotic/Edgy personality bots
  final List<BotUser> botTable2;   // Goofy/Soft personality bots
  final List<BotUser> botTable3;   // Balanced/Mixed personality bots
  final String vibeSection;         // "The vibe" section content
  final String headingText;         // "tea topic of the day" or similar
  final int backgroundColorHue;     // HSL hue value for background gradient
  final int characterLimit;         // world-specific character limit for messages

  const WorldConfig({
    required this.id,
    required this.displayName,
    required this.topicOfDay,
    required this.modalTitle,
    this.modalDescription,
    required this.entryTileImage,
    required this.botTable1,
    required this.botTable2,
    required this.botTable3,
    required this.vibeSection,
    required this.headingText,
    required this.backgroundColorHue,
    required this.characterLimit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'topicOfDay': topicOfDay,
      'modalTitle': modalTitle,
      'modalDescription': modalDescription,
      'entryTileImage': entryTileImage,
      'botTable1': botTable1.map((bot) => bot.toMap()).toList(),
      'botTable2': botTable2.map((bot) => bot.toMap()).toList(),
      'botTable3': botTable3.map((bot) => bot.toMap()).toList(),
      'vibeSection': vibeSection,
      'headingText': headingText,
      'backgroundColorHue': backgroundColorHue,
      'characterLimit': characterLimit,
    };
  }

  factory WorldConfig.fromMap(Map<String, dynamic> map) {
    return WorldConfig(
      id: map['id'] as String,
      displayName: map['displayName'] as String,
      topicOfDay: map['topicOfDay'] as String,
      modalTitle: map['modalTitle'] as String,
      modalDescription: map['modalDescription'] as String?,
      entryTileImage: map['entryTileImage'] as String,
      botTable1: (map['botTable1'] as List<dynamic>?)
          ?.map((botMap) => BotUser.fromMap(botMap as Map<String, dynamic>))
          .toList() ?? [],
      botTable2: (map['botTable2'] as List<dynamic>?)
          ?.map((botMap) => BotUser.fromMap(botMap as Map<String, dynamic>))
          .toList() ?? [],
      botTable3: (map['botTable3'] as List<dynamic>?)
          ?.map((botMap) => BotUser.fromMap(botMap as Map<String, dynamic>))
          .toList() ?? [],
      vibeSection: map['vibeSection'] as String,
      headingText: map['headingText'] as String,
      backgroundColorHue: map['backgroundColorHue'] as int,
      characterLimit: map['characterLimit'] as int? ?? 180, // Default to 180 if not specified
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorldConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WorldConfig(id: $id, displayName: $displayName)';
  }
}