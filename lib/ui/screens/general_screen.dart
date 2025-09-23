import 'package:flutter/material.dart';
import 'dart:ui';
import 'game_experience_screen.dart';
import '../../services/auth/auth_service.dart';
import '../../services/core/world_service.dart';
import '../../services/data/local_storage_service.dart';
import '../../services/simulation/bot_assignment_service.dart';
import '../../services/admin/maintenance_service.dart';
import '../../config/world_config.dart';
import '../widgets/forms/world_access_modal.dart';
import '../widgets/forms/instagram_collection_modal.dart';
import '../widgets/forms/tribe_loading_modal.dart';

void main() => runApp(MaterialApp(home: GeneralScreen()));

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  final WorldService _worldService = WorldService();
  late List<WorldConfig> _availableWorlds;

  @override
  void initState() {
    super.initState();
    _availableWorlds = _worldService.getAllWorlds();
  }

  Future<void> _checkAuthAndNavigate(BuildContext context, WorldConfig world) async {

    final authService = AuthService();
    final localStorageService = LocalStorageService();
    final maintenanceService = MaintenanceService();

    // Store the selected world
    await localStorageService.setWorld(world.displayName);

    // Check if user is authenticated for this specific world
    final isLoggedInForWorld = await authService.isLoggedInForWorld(world.id);

    if (isLoggedInForWorld) {
      // This is a RETURNING user with existing account
      // Check if returning users are being blocked
      final maintenanceStatus = await maintenanceService.getMaintenanceStatus();
      final anonId = await authService.getOrCreateAnonId();

      if (maintenanceStatus.blockReturningUsers) {
        // Toggle ON: Returning users are completely blocked
        if (context.mounted) {
          _showInstagramCollectionModal(context);
        }
        return;
      } else {
        // Toggle OFF: Check if user has already visited today
        final hasVisitedToday = await authService.hasVisitedToday(anonId, world.id);

        if (hasVisitedToday) {
          // User already visited today, block them with Instagram modal
          if (context.mounted) {
            _showInstagramCollectionModal(context);
          }
          return;
        }
      }

      // Track world visit for returning users (only reaches here if allowed to enter)
      await authService.trackWorldVisit(anonId, world.id);

      // Show loading modal for returning users before navigating
      if (context.mounted) {
        _showTribeLoadingModal(context, world);
      }
    } else {
      // This is a NEW user without existing account
      // New users can always go through the signup process regardless of admin toggle
      // (The admin toggle only blocks existing users from re-entering)

      // User needs to create account for this world, show modal
      if (context.mounted) {
        _showWorldAccessModal(context, world);
      }
    }
  }


  bool _isModalOpen = false;
  bool _hasBeenRejectedForFullWorld = false;

  void _showWorldAccessModal(BuildContext context, WorldConfig world) {
    // Prevent multiple modals from opening
    if (_isModalOpen) {
      return;
    }

    // If user has already been rejected for full world, show Instagram modal
    if (_hasBeenRejectedForFullWorld) {
      _showInstagramCollectionModal(context);
      return;
    }

    _isModalOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WorldAccessModal(
        worldConfig: world,
        onSubmit: (accessCode, nickname, vibeAnswers) async {
          final authService = AuthService();

          // First validate the access code
          final correctCode = world.id == 'girl-meets-college' ? '789' : '456';
          if (accessCode != correctCode) {
            throw Exception('Invalid access code');
          }

          // Check bot availability BEFORE creating account
          final botAssignmentService = BotAssignmentService();
          final assignedBots = await botAssignmentService.assignBotsBasedOnVibeCheck(vibeAnswers);


          if (assignedBots.isEmpty) {
            // World is full - DON'T create account, show Instagram modal
            if (context.mounted) {
              _closeModal(context);
              _hasBeenRejectedForFullWorld = true;
              _showInstagramCollectionModal(context);
            }
            return false;
          }

          // Only create account if bots were successfully assigned
          final success = await authService.createAccountForWorld(accessCode, nickname, world.id);

          if (success && context.mounted) {
            _closeModal(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameExperienceScreen(
                  selectedFloor: 1,
                  worldConfig: null,
                ),
              ),
            );
          } else {
            // This shouldn't happen since we validated the code above
            throw Exception('Failed to create account');
          }
        },
        onCancel: () {
          _closeModal(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          _buildBackgroundCollages(context),
          _buildWorldTiles(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundCollages(BuildContext context) {
    return Stack(
      children: [
        // Girl Meets College background (centered)
        _buildFadeBackground(context, isLeft: true),
        // Guy Meets College background (right side) - COMMENTED OUT
        // _buildFadeBackground(context, isLeft: false),
      ],
    );
  }

  Widget _buildFadeBackground(BuildContext context, {required bool isLeft}) {
    final screenSize = MediaQuery.of(context).size;
    final groupWidth = 124.0;
    final groupHeight = 128.0;

    // Position: center the background since we only have Girl Meets College
    final leftOffset = (screenSize.width / 2) - (groupWidth / 2);

    return Positioned(
      left: leftOffset,
      top: (screenSize.height - groupHeight) / 2,
      child: SizedBox(
        width: groupWidth,
        height: groupHeight,
        child: Stack(
          children: [
            _buildBlurredCircle(
              left: 39, top: 39, width: 85, height: 80,
              color: isLeft
                  ? const Color(0xFFF9D6D3).withOpacity(0.83)
                  : const Color(0xFF6B73FF).withOpacity(0.4),
            ),
            _buildBlurredCircle(
              left: 25, top: 0, width: 76, height: 76,
              color: isLeft
                  ? const Color(0xFFFDBFC5).withOpacity(0.83)
                  : const Color(0xFF9B8CFF).withOpacity(0.4),
            ),
            _buildBlurredCircle(
              left: 0, top: 54, width: 77, height: 74,
              color: isLeft
                  ? const Color(0xFFFDC4A0).withOpacity(0.83)
                  : const Color(0xFF7C6BFF).withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredCircle({
    required double left,
    required double top,
    required double width,
    required double height,
    required Color color,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 32.5, sigmaY: 32.5),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildWorldTiles(BuildContext context) {
    final girlWorld = _availableWorlds.firstWhere((world) => world.id == 'girl-meets-college');
    // final guyWorld = _availableWorlds.firstWhere((world) => world.id == 'guy-meets-college');

    return Stack(
      children: [
        // Girl Meets College tile (centered)
        _buildWorldTile(
          context,
          world: girlWorld,
          isLeft: false, // Changed to false to center it
          stickerAsset: 'assets/sticker_image.png',
        ),
        // Guy Meets College tile (right) - COMMENTED OUT
        // _buildWorldTile(
        //   context,
        //   world: guyWorld,
        //   isLeft: false,
        //   stickerAsset: 'assets/Boy_sticker.png',
        // ),
        // Tap indicators - COMMENTED OUT
        // _buildTapIndicators(context),
      ],
    );
  }

  Widget _buildWorldTile(BuildContext context, {
    required WorldConfig world,
    required bool isLeft,
    required String stickerAsset,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final boxWidth = 122.0;
    final boxHeight = 126.0;
    
    // Position: left side, right side, or centered
    final leftOffset = isLeft
        ? (screenSize.width / 2 - 100) - (boxWidth / 2)  // Left position
        : (screenSize.width / 2) - (boxWidth / 2);        // Centered position
    
    return Stack(
      children: [
        // Box
        Positioned(
          left: leftOffset,
          top: (screenSize.height - boxHeight) / 2,
          child: GestureDetector(
            onTap: () => _checkAuthAndNavigate(context, world),
            child: Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFefd),
                border: Border.all(
                  color: const Color(0xFFEFEFEF),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.07),
                    offset: const Offset(4, 6),
                    blurRadius: 8.9,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Sticker image - centered on the box
        Positioned(
          left: leftOffset + (boxWidth / 2) - (stickerAsset.contains('Boy_sticker') ? 140.0 / 2 : 165.29 / 2),
          top: (screenSize.height / 2) - (126.0 / 2) + (boxHeight / 2) - (stickerAsset.contains('Boy_sticker') ? 96.0 / 2 : 113.53 / 2),
          child: GestureDetector(
            onTap: () => _checkAuthAndNavigate(context, world),
            child: Image.asset(
              stickerAsset,
              width: stickerAsset.contains('Boy_sticker') ? 140.0 : 165.29,
              height: stickerAsset.contains('Boy_sticker') ? 96.0 : 113.53,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // Title
        Positioned(
          left: leftOffset - (boxWidth / 2),
          right: screenSize.width - leftOffset - (boxWidth * 1.5),
          top: (screenSize.height / 2) + (boxHeight / 2) + 15,
          child: Center(
            child: Text(
              world.displayName,
              style: const TextStyle(
                fontFamily: 'SF Pro Rounded',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Color(0xFFB2B2B2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTapIndicators(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Only show tap indicator for Guy Meets College (right side)
        Positioned(
          left: (screenSize.width / 2 + 100) + 10,
          top: (screenSize.height / 2) - 200,
          child: Image.asset(
            'assets/tap.png',
            width: 98,
            height: 98,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  void _closeModal(BuildContext context) {
    Navigator.of(context).pop();
    _isModalOpen = false;
  }

  void _showInstagramCollectionModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InstagramCollectionModal(
        onInstagramSubmitted: () {
        },
      ),
    );
  }

  void _showTribeLoadingModal(BuildContext context, WorldConfig world) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => TribeLoadingModal(
        onComplete: () {
          // Close the loading modal
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
          // Navigate to the game experience screen
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameExperienceScreen(
                  selectedFloor: 1,
                  worldConfig: null,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}