# Utils Directory - CLAUDE.md

This directory contains utility classes that provide common functionality and helper methods used throughout the BAS Rituals application.

## Files Overview

### `admin_navigation.dart`
**Purpose**: Centralized admin navigation and authentication utilities.

**Key Components**:

#### `AdminNavigation` Class
Static utility class for admin navigation flow:
- **`navigateToLogin()`**: Smart navigation that checks existing authentication
- **`navigateToDashboard()`**: Direct navigation to admin dashboard
- **`canAccessAdmin()`**: Permission checking utility
- **`logoutAndNavigateToLogin()`**: Secure logout with navigation

**Navigation Logic**:
- Automatically redirects authenticated users to dashboard
- Handles authentication state checking before navigation
- Provides context-aware navigation with proper error handling

#### `AdminAccessMixin`
Mixin that adds admin functionality to any screen:
- **`checkAdminAuth()`**: Authentication status checking
- **`showAdminAccessDialog()`**: User instruction dialog
- **`navigateToAdmin()`**: Error-safe admin navigation

**Usage Pattern**:
```dart
class MyScreen extends StatefulWidget {}
class _MyScreenState extends State<MyScreen> with AdminAccessMixin {
  // Now has access to admin navigation methods
}
```

### `accessibility_utils.dart`
**Purpose**: Comprehensive accessibility support for screen readers and assistive technologies.

**Key Features**:

#### Screen Reader Announcements
Text generation for dynamic content announcements:
- **`getTypingAnnouncementText()`**: User typing status
- **`getRotationAnnouncementText()`**: Queue rotation notifications
- **`getReactionAnnouncementText()`**: Reaction count updates
- **`getMessageSubmittedAnnouncementText()`**: Message submission feedback
- **`getRemainingTimeAnnouncementText()`**: Time-based announcements

#### Semantic Utilities
Widget wrapper and enhancement methods:
- **`wrapWithSemantics()`**: Comprehensive semantic wrapper with configurable properties
- **`createAnnouncementWidget()`**: Live region widgets for dynamic updates
- **`getReactionButtonLabel()`**: Context-aware button labeling
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

#### Standard Animations
- **`createShimmerAnimation()`**: Shimmer loading effects
- **`createSlideInAnimation()`**: Banner and notification slides
- **`createFadeAnimation()`**: General fade transitions

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

### Mixin Pattern
`AdminAccessMixin` provides reusable functionality across multiple screens:
- Reduces code duplication
- Provides consistent admin access patterns
- Includes error handling and user feedback

### Accessibility-First Design
Comprehensive accessibility support throughout:
- Screen reader announcements for all dynamic content
- Semantic labeling for interactive elements
- Motion preference respect
- Live region updates for real-time changes

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

### Animation Best Practices
1. **Use configuration constants** rather than hardcoded values
2. **Provide motion-reduced alternatives** for all animations
3. **Follow Material Design** animation guidelines
4. **Test on different devices** for performance

### Admin Utilities Usage
1. **Use mixins** for screens that need admin access
2. **Check authentication status** before sensitive operations
3. **Handle navigation errors** gracefully with user feedback
4. **Provide clear user instructions** for admin access

### Error Handling Pattern
All utility methods that can fail should:
- Include try-catch blocks where appropriate
- Provide meaningful error messages
- Handle context-dependent operations safely (check `mounted` state)
- Offer graceful degradation when possible

### Testing Considerations
- Utilities should be easily unit testable
- Mock external dependencies (navigation, screen readers)
- Test accessibility announcements with assistive technology
- Verify animation behavior with reduced motion settings