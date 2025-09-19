# Utils Directory - CLAUDE.md

This directory contains utility classes that provide common functionality and helper methods used throughout the BAS Rituals application.

## Files Overview

### `admin_navigation.dart`
**Purpose**: Centralized admin navigation utilities.

**Key Components**:

#### `AdminNavigation` Class
Static utility class for admin navigation flow:
- **`navigateToLogin()`**: Navigate to admin login screen
- **`navigateToDashboard()`**: Navigate to admin dashboard with replacement

**Navigation Pattern**:
- Uses MaterialPageRoute for navigation
- Dashboard navigation uses pushReplacement to prevent back navigation
- Simple, focused navigation utilities

### `accessibility_utils.dart`
**Purpose**: Comprehensive accessibility support for screen readers and assistive technologies.

**Key Features**:

#### Screen Reader Announcements
Text generation for dynamic content announcements:
- **`getTypingAnnouncementText()`**: User typing status
- **`getRotationAnnouncementText()`**: Queue rotation notifications
- **`getReactionAnnouncementText()`**: Reaction count updates with pluralization
- **`getMessageSubmittedAnnouncementText()`**: Message submission feedback
- **`getRemainingTimeAnnouncementText()`**: Time-based announcements (minutes/seconds)

#### Semantic Utilities
Widget wrapper and enhancement methods:
- **`wrapWithSemantics()`**: Comprehensive semantic wrapper with configurable properties
  - Supports label, hint, value, button, focusable properties
  - Handles tap callbacks and live regions
  - Can exclude semantics when needed
- **`createAnnouncementWidget()`**: Live region widgets for dynamic updates
- **`getReactionButtonLabel()`**: Context-aware button labeling (Add/Remove)
- **`getQueuePositionLabel()`**: Queue position descriptions

#### Screen Reader Integration
Direct screen reader communication:
- **`announceToScreenReader()`**: Immediate announcements using SemanticsService
- **`announceLiveRegionUpdate()`**: Live region updates for dynamic content

#### Motion Sensitivity
- **`getReducedMotionDuration()`**: Respects user motion preferences (90% duration reduction)

### `animation_utils.dart`
**Purpose**: Centralized animation creation and management utilities.

**Key Animation Factories**:

#### Typing Animation Support
- **`createBounceAnimation()`**: Staggered dot animations for typing indicators
  - Uses `RitualConfig.animationStaggerOffsets` for dot timing
  - Implements elastic curves for natural bounce effects
  - Calculates interval based on dot index and bounce duration

#### Standard Animations
- **`createShimmerAnimation()`**: Shimmer loading effects (-1.0 to 1.0 range)
- **`createSlideInAnimation()`**: Banner and notification slides
  - Default: slides from top (0.0, -1.0) to center
  - Uses easeOutBack curve for bounce effect
- **`createFadeAnimation()`**: General fade transitions
  - Configurable begin/end opacity values
  - Uses easeInOut curve for smooth transitions

#### Accessibility Integration
- **`shouldReduceMotion()`**: Checks MediaQuery for motion preferences
- **`getAnimationDuration()`**: Returns Duration.zero for reduced motion users

**Animation Configuration**:
All animations use constants from `RitualConfig`:
- Bounce duration: 600ms
- Shimmer duration: 2s
- Stagger offsets: 0ms, 100ms, 200ms for dot animations

## Key Patterns

### Static Utility Pattern
All utility classes use static methods for stateless operations:
```dart
AnimationUtils.createFadeAnimation(controller);
AccessibilityUtils.announceToScreenReader(context, message);
AdminNavigation.navigateToLogin(context);
```

### Accessibility-First Design
Comprehensive accessibility support throughout:
- Screen reader announcements for all dynamic content
- Semantic labeling for interactive elements
- Motion preference respect
- Live region updates for real-time changes
- Proper pluralization in announcements

### Configuration Integration
Animation utilities integrate with centralized configuration:
- Uses `RitualConfig` constants for consistent timing
- Supports runtime configuration changes
- Maintains consistent animation behavior across the app

## Development Guidelines

### Adding New Utilities
1. **Use static methods** for stateless operations
2. **Follow existing naming patterns** with descriptive method names
3. **Include context parameters** when UI-specific operations are needed
4. **Add comprehensive documentation** for public methods

### Accessibility Guidelines
1. **Always provide semantic labels** for interactive elements
2. **Use live regions** for dynamic content updates
3. **Respect user motion preferences** in all animations
4. **Test with screen readers** during development
5. **Handle pluralization** correctly in announcements

### Animation Best Practices
1. **Use configuration constants** rather than hardcoded values
2. **Provide motion-reduced alternatives** for all animations
3. **Follow Material Design** animation guidelines
4. **Test on different devices** for performance
5. **Use appropriate curves** for different animation types

### Admin Navigation Usage
1. **Use simple navigation patterns** for admin flows
2. **Use pushReplacement** for preventing back navigation
3. **Keep navigation logic centralized** in this utility

### Testing Considerations
- Utilities should be easily unit testable
- Mock external dependencies (navigation, screen readers)
- Test accessibility announcements with assistive technology
- Verify animation behavior with reduced motion settings
- Test pluralization in announcement texts