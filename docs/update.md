# Multi-World System Implementation

## Overview
Extend the existing **Girl Meets College** flow to support multiple worlds (e.g., *Girl Meets College*, *Guy Meets College*) while keeping all core logic unchanged. This creates a reusable, configurable system that can scale to any number of worlds.

## Core Requirements

### 1. Logic Preservation
- **Queue system**: Remains identical across all worlds
- **Posting flow**: Same submission and display logic
- **Reaction system**: Same local simulation and engagement
- **Turn management**: Same bot and user turn progression
- **Session end**: Same navigation to session end screen

### 2. Reusability & Configuration
- Single codebase supports multiple worlds through configuration
- No branching or world-specific logic in core flow
- World differences handled through configuration objects only

## Implementation Requirements

### World Configuration System
Create a centralized world configuration that defines:

```dart
class WorldConfig {
  final String id;                    // "girl-meets-college"
  final String displayName;          // "Girl Meets College"
  final String topicOfDay;          // "confess your college experiences"
  final String modalTitle;          // "join the world bestie ✨"
  final String modalDescription;    // world-specific copy
  final String entryTileImage;      // path to world image
  final List<BotUser> botPool;      // world-specific bots
}
```

### Database Schema Changes
Replace gender-based posts with world-based posts:

**Before:**
```dart
{
  'confession': 'text...',
  'floor': 2,
  'gender': 'girl',  // Remove this
  'timestamp': timestamp
}
```

**After:**
```dart
{
  'confession': 'text...',
  'floor': 2,
  'world': 'Girl Meets College',  // Add this
  'timestamp': timestamp
}
```

### Bot System Architecture
- **Single shared bot logic**: One `BotAssignmentService` and `QueueService`
- **World-specific bot pools**: Each world configuration contains its own bot list
- **Same assignment logic**: 6 bots per user, same persistence and reassignment rules
- **Same behavior**: Bot posting, timing, and queue participation identical across worlds

### UI Configuration Points

#### 1. General Screen Updates
- Dynamic world tiles based on available world configurations
- Each tile shows world-specific image and name
- Same tile layout and interaction pattern

#### 2. World Access Modal
- World-specific copywriting (title, description, button text)
- Same authentication flow and validation logic
- World context passed to subsequent screens

#### 3. Main Experience Screen
- World-specific topic display ("Today's topic: [world.topicOfDay]")
- Same queue UI, posting interface, and session flow
- World context maintains throughout session

## Files to Modify

### New Files to Create
- `lib/config/world_config.dart` - World configuration definitions
- `lib/config/worlds/girl_meets_college_world.dart` - Girl Meets College config
- `lib/config/worlds/guy_meets_college_world.dart` - Guy Meets College config
- `lib/services/world_service.dart` - World selection and management

### Existing Files to Update
- `lib/ui/screens/general_screen.dart` - Dynamic world tiles
- `lib/ui/widgets/world_access_modal.dart` - Accept world configuration
- `lib/ui/screens/girl_meets_college_screen.dart` - Make world-agnostic, rename to `world_experience_screen.dart`
- `lib/services/post_service.dart` - Replace gender field with world field
- `lib/services/auth_service.dart` - Store selected world in user account
- `lib/services/local_storage_service.dart` - Add world storage methods
- `lib/services/bot_assignment_service.dart` - Accept world-specific bot pool

## Implementation Phases

### Phase 1: Configuration Infrastructure
1. Create world configuration system
2. Define Girl Meets College world config (migrate existing copy/bots)
3. Create Guy Meets College world config
4. Build world service for configuration management

### Phase 2: Database Migration
1. Update post schema to use `world` field instead of `gender`
2. Migrate existing posts to use "Girl Meets College" world
3. Update all post creation and querying logic

### Phase 3: UI Generalization
1. Make general screen display dynamic world tiles
2. Update world access modal to accept world configuration
3. Generalize main experience screen to work with any world config
4. Update all world-specific copy to use configuration

### Phase 4: Bot System Updates
1. Move bot pools into world configurations
2. Update bot assignment service to use world-specific bot pools
3. Ensure bot behavior remains identical across worlds

## Success Criteria

### Functionality
- [ ] All existing Girl Meets College functionality works unchanged
- [ ] Guy Meets College world works with identical flow logic
- [ ] Bot assignment and behavior identical across worlds
- [ ] Session end and queue management works for all worlds
- [ ] Posts correctly tagged with world information

### Scalability
- [ ] Adding a third world requires only new configuration file
- [ ] No changes to core flow logic needed for new worlds
- [ ] Bot system scales automatically with new world bot pools
- [ ] UI adapts automatically to new world configurations

### Code Quality
- [ ] Single shared codebase with no world-specific branching
- [ ] Configuration-driven differences only
- [ ] Clean separation between world config and core logic
- [ ] Existing development principles maintained

## Technical Notes

### Development Principles Alignment
- **Bare minimum complexity**: Configuration over branching logic
- **MVVM pattern**: Same view models work with any world configuration
- **Simplicity**: Core flow unchanged, only data sources configured
- **No third-party dependencies**: Pure Flutter configuration system

### Migration Strategy
- Implement as additive changes to preserve existing functionality
- Use feature flags if needed during transition
- Maintain backward compatibility during rollout
- Test thoroughly with existing Girl Meets College users

This implementation creates a truly scalable multi-world system while preserving all existing functionality and following established development principles.