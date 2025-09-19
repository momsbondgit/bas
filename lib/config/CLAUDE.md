# Config Directory - CLAUDE.md

This directory contains configuration files that define the core settings and world definitions for the BAS Rituals application.

## Files Overview

### `ritual_config.dart`
Static configuration constants for the ritual queue system:

**Timing Settings**:
- `defaultTurnDuration`: 60 seconds per turn
- `bannerDisplayDuration`: 4 seconds for banner display
- `typingDebounceDelay`: 500ms debounce for typing indicator

**Animation Settings**:
- `targetFPS`: 60 FPS target
- `dotBounceDuration`: 600ms for dot bounce animation
- `shimmerDuration`: 2 seconds for shimmer effects
- `bannerAnimationDuration`: 300ms for banner transitions
- `messageCardAnimationDuration`: 200ms for card animations

**UI Constants**:
- `dotSize`: 4.0 pixels for typing dots
- `dotSpacing`: 8.0 pixels between dots
- `numberOfDots`: 3 dots for typing indicator
- `bannerHeight`: 60.0 pixels height
- `bannerBorderRadius`: 12.0 pixels border radius

**Reaction System**:
- `reactionButtonSize`: 32.0 pixels for reaction buttons
- `reactionEmojiSize`: 18.0 pixels for emoji display

**Text Constants**:
- `typingIndicatorText`: "is typing…"
- `newTurnBannerPrefix`: "New turn: "
- `yourTurnBannerText`: "It's your turn"

**Animation Offsets**:
- Stagger offsets for typing dots (0ms, 100ms, 200ms)

### `world_config.dart`
Base model class defining the structure for different "worlds":

**Core Properties**:
- `id`: Unique world identifier
- `displayName`: User-facing world name
- `topicOfDay`: Daily discussion topic
- `modalTitle`: Access modal title
- `modalDescription`: Access modal description
- `entryTileImage`: World selection image path

**Bot Configuration**:
- `botTable1`: Chaotic/edgy personality bots
- `botTable2`: Goofy/soft personality bots
- `botTable3`: Balanced/mixed personality bots (dynamically created from table 1 & 2)

**UI Theming**:
- `backgroundColorHue`: HSL color hue value
- `characterLimit`: Maximum confession character count
- `headingText`: World-specific heading
- `vibeSection`: Vibe check configuration

**Methods**:
- `toMap()`: Serializes world config to Firebase-compatible map
- `fromMap()`: Deserializes from Firebase data

### `worlds/` Directory
Contains specific world implementations:

#### `girl_meets_college_world.dart`
**Theme Configuration**:
- Pink/rose color theme (hue: 340°)
- Character limit: 180 characters
- Topic focus: "tea topic of the day"
- Target audience: Female college students

**Bot Tables**:
- Table 1: Chaotic personalities (Haylee, Hanna, Fiona, etc.)
- Table 2: Soft personalities (Emma, Kali, Grace, etc.)
- Each bot includes:
  - `botId`: Unique identifier
  - `nickname`: Display name
  - `quineResponse`: Bot's confession response
  - `goodbyeMessage`: Session end message

#### `guy_meets_college_world.dart`
**Theme Configuration**:
- Blue color theme
- Character limit: 180 characters
- Topic focus: Male-oriented college experiences
- Target audience: Male college students

**Bot Tables**:
- Table 1: Edgy/provocative male personalities
- Table 2: Supportive/friendly male personalities
- Similar structure to girl world with male-oriented names

## Key Patterns

### World Configuration Pattern
Each world file exports a static `WorldConfig` instance with:
1. Unique ID and display name
2. Three bot tables with distinct personality types
3. World-specific UI theming
4. Character limits and topic definitions
5. Vibe check configuration

### Bot Table Structure
- **Table 1**: Chaotic/Edgy personalities with provocative responses
- **Table 2**: Goofy/Soft personalities with supportive responses
- **Table 3**: Balanced/Mixed personalities (created dynamically from mixing table 1 and 2)
- Each bot has unique ID, nickname, confession response, and goodbye message

### Configuration Constants
All timing, animation, and UI constants are centralized in `RitualConfig` to ensure consistency across the application.

## Development Guidelines

### Adding New Worlds
1. Create new file in `worlds/` directory
2. Follow naming pattern: `{name}_world.dart`
3. Implement static `WorldConfig` instance
4. Ensure unique bot IDs across all tables
5. Add to `WorldService._availableWorlds` list
6. Test bot assignment with all vibe check combinations

### Modifying Timing/Animation
- Update constants in `ritual_config.dart`
- Consider impact on user experience
- Test across different devices/screen sizes
- Ensure animations remain smooth at target FPS

### Bot Configuration Best Practices
- Maintain personality consistency within each table
- Ensure responses fit within character limits
- Keep nicknames appropriate and distinct
- Balance provocative and supportive content
- Test goodbye messages for emotional impact

### World Theming
- Use HSL hue values for consistent color theming
- Keep character limits reasonable (150-200 chars)
- Ensure modal copy is clear and engaging
- Test entry images for proper display