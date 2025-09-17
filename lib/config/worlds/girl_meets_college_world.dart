import '../world_config.dart';

class GirlMeetsCollegeWorld {
  static const WorldConfig config = WorldConfig(
    id: 'girl-meets-college',
    displayName: 'Girl Meets College',
    topicOfDay: "ok… what's the weirdest or most annoying thing u seen in Lions Gate so far 👀💀",
    modalTitle: 'No code, no access. Only members can invite.',
    modalDescription: null,
    entryTileImage: 'assets/images/girl_meets_college.png', // TODO: Add actual asset path
    vibeSection: '',
    headingText: 'tea topic of the day',
    backgroundColorHue: 340, // Pink/rose hue for girl energy
    characterLimit: 180, // Reduced limit
    // Bot data now loaded from Firebase only - no fallback
    // Admins must configure bots in Firebase via Admin Dashboard
    botTable1: [],
    botTable2: [],
  );
}

