# Config Directory - CLAUDE.md

This directory contains configuration files that define the core settings and world definitions for the BAS Rituals application.

## Files Overview

### `ritual_config.dart`
Static configuration constants for the ritual queue system:
- **Timing Settings**: Turn duration (60s), banner display (4s), typing debounce (500ms)
- **Animation Settings**: FPS (60), dot bounce (600ms), shimmer (2s)
- **UI Constants**: Dot size/spacing, banner height, reaction button sizes
- **Text Constants**: Typing indicator text, banner messages

### `world_config.dart`
Base model class defining the structure for different "worlds":
- **Core Properties**: ID, display name, topic of day, modal title/description
- **Bot Configuration**: Two bot tables (chaotic/edgy vs goofy/soft personalities)
- **UI Theming**: Background color hue, character limits, heading text
- **Serialization**: `toMap()` and `fromMap()` for Firebase storage

### `worlds/` Directory
Contains specific world implementations:

#### `girl_meets_college_world.dart`
- **Theme**: Pink/rose hue (340°), "tea topic of the day"
- **Character Limit**: 180 characters
- **Bot Personalities**: Female-oriented nicknames and responses
- **Topic Focus**: Hookup moments and college experiences

#### `guy_meets_college_world.dart`
- **Theme**: Blue hue, male-oriented language
- **Bot Personalities**: Male-oriented nicknames and responses
- **Similar Structure**: Follows same WorldConfig pattern

## Key Patterns

### World Configuration Pattern
Each world file exports a static `WorldConfig` instance with:
1. Unique ID and display name
2. Two bot tables with distinct personality types
3. World-specific UI theming
4. Character limits and topic definitions

### Bot Table Structure
- **Table 1**: Chaotic/Edgy personalities with provocative responses
- **Table 2**: Goofy/Soft personalities with supportive responses
- **Table 3**: Balanced/Mixed personalities with nuanced responses
- Each bot has: `botId`, `nickname`, `quineResponse`

### Configuration Constants
All timing, animation, and UI constants are centralized in `RitualConfig` to ensure consistency across the application.

## Development Guidelines

### Adding New Worlds
1. Create new file in `worlds/` directory
2. Follow existing naming pattern: `{name}_world.dart`
3. Implement static `WorldConfig` instance
4. Ensure unique bot IDs across both tables
5. Add to `WorldService._availableWorlds` list

### Modifying Timing/Animation
- Update constants in `ritual_config.dart`
- Consider impact on user experience
- Test across different devices/screen sizes

### Bot Configuration
- Maintain balance between chaotic and soft personalities
- Ensure responses fit character limits
- Keep nicknames appropriate and distinct