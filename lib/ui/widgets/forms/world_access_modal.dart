import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../config/world_config.dart';
import '../../../services/auth/auth_service.dart';

class WorldAccessModal extends StatefulWidget {
  final WorldConfig? worldConfig;
  final Function(String nickname, List<String> lobbyUserIds, Map<String, String> lobbyUserNicknames) onStart;
  final VoidCallback? onCancel;

  const WorldAccessModal({
    super.key,
    this.worldConfig,
    required this.onStart,
    this.onCancel,
  });

  @override
  State<WorldAccessModal> createState() => _WorldAccessModalState();
}

class _WorldAccessModalState extends State<WorldAccessModal> {
  final TextEditingController _nicknameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;
  bool _hasJoinedLobby = false;
  String? _currentUserId;
  Map<String, String> _lobbyUsers = {};
  StreamSubscription<bool>? _lobbyStartedSubscription;




  @override
  void initState() {
    super.initState();
    _initializeLobby();
  }

  Future<void> _initializeLobby() async {
    _currentUserId = await _authService.getOrCreateAnonId();
    print('[LOBBY DEBUG] Initialized lobby for user: $_currentUserId, world: ${widget.worldConfig?.id}');
    _setupLobbyStartedListener();
  }

  void _setupLobbyStartedListener() {
    if (widget.worldConfig == null) return;

    print('[LOBBY DEBUG] Setting up lobby started listener for world: ${widget.worldConfig!.id}');
    _lobbyStartedSubscription = _authService.getLobbyStartedStream(widget.worldConfig!.id).listen((isStarted) {
      print('[LOBBY DEBUG] Lobby started status changed: $isStarted for user: $_currentUserId');
      if (isStarted && mounted && _lobbyUsers.length >= 2) {
        print('[LOBBY DEBUG] Another user started the lobby with ${_lobbyUsers.length} users, handling auto-navigation for user: $_currentUserId');
        _handleLobbyStartedByOther();
      } else if (isStarted && _lobbyUsers.length < 2) {
        print('[LOBBY DEBUG] Lobby started but only ${_lobbyUsers.length} users - ignoring auto-start');
      }
    });
  }

  Future<void> _handleLobbyStartedByOther() async {
    if (widget.worldConfig == null) return;

    print('[LOBBY DEBUG] Handling lobby started by other user for: $_currentUserId');
    try {
      // Get the active user IDs that were in the lobby when it was started
      final activeUserIds = await _authService.getActiveLobbyUsers(widget.worldConfig!.id);
      print('[LOBBY DEBUG] Retrieved active lobby users: $activeUserIds');

      // Check if current user was in the lobby when it was started
      if (activeUserIds.contains(_currentUserId)) {
        print('[LOBBY DEBUG] Current user $_currentUserId is in active users list, navigating to game...');
        // Navigate this user to the game
        await widget.onStart(
          _nicknameController.text.trim(),
          activeUserIds,
          _lobbyUsers,
        );
        print('[LOBBY DEBUG] Navigation completed for user: $_currentUserId');
      } else {
        print('[LOBBY DEBUG] Current user $_currentUserId NOT in active users list, not navigating');
      }
    } catch (e) {
      print('[LOBBY DEBUG] Error handling lobby started by other: $e');
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _lobbyStartedSubscription?.cancel();
    if (_hasJoinedLobby && widget.worldConfig != null) {
      _authService.leaveLobby(widget.worldConfig!.id);
    }
    super.dispose();
  }

  void _handleJoinLobby() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.worldConfig == null) return;

    print('[LOBBY DEBUG] User $_currentUserId attempting to join lobby with nickname: ${_nicknameController.text.trim()}');

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authService.joinLobby(
        widget.worldConfig!.id,
        _nicknameController.text.trim(),
      );

      print('[LOBBY DEBUG] User $_currentUserId successfully joined lobby');
      setState(() {
        _hasJoinedLobby = true;
      });
    } catch (e) {
      print('[LOBBY DEBUG] Error joining lobby for user $_currentUserId: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleStart() async {
    if (widget.worldConfig == null || _lobbyUsers.isEmpty) return;

    final lobbyUserIds = _lobbyUsers.keys.toList();
    print('[LOBBY DEBUG] User $_currentUserId clicked START button. Lobby users: $lobbyUserIds');

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Start the game for all users in the lobby
      print('[LOBBY DEBUG] Calling widget.onStart for user $_currentUserId with lobby users: $lobbyUserIds');
      await widget.onStart(
        _nicknameController.text.trim(),
        lobbyUserIds,
        _lobbyUsers,
      );
      print('[LOBBY DEBUG] widget.onStart completed for user $_currentUserId');

      // Mark lobby as started
      print('[LOBBY DEBUG] Marking lobby as started in Firebase for users: $lobbyUserIds');
      await _authService.startLobby(widget.worldConfig!.id, lobbyUserIds);
      print('[LOBBY DEBUG] Lobby marked as started successfully');
    } catch (e) {
      print('[LOBBY DEBUG] Error in _handleStart for user $_currentUserId: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }



  String? _validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'we gotta call u something!';
    }
    if (value.trim().length > 20) {
      return 'keep it under 20 chars bestie';
    }
    return null;
  }


  Widget _buildMainContent() {
    if (!_hasJoinedLobby) {
      // Show username input
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Waiting for your friends to join...',
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Nickname Field
          const Text(
            'what should we call u?',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nicknameController,
            maxLength: 20,
            validator: _validateNickname,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: 'ur nickname here...',
              hintStyle: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFB2B2B2),
                letterSpacing: 0.4,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFB2B2B2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFB2B2B2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 24),

          // Join button
          GestureDetector(
            onTap: _isSubmitting ? null : _handleJoinLobby,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: _isSubmitting ? Colors.grey : Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Join Lobby',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Show lobby with users list
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Waiting for your friends to join...',
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Users in lobby
          const Text(
            'Friends in lobby:',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),

          // Stream of lobby users
          if (widget.worldConfig != null)
            StreamBuilder<Map<String, String>>(
              stream: _authService.getLobbyUsersStream(widget.worldConfig!.id),
              builder: (context, snapshot) {
                print('[LOBBY DEBUG] StreamBuilder received data: ${snapshot.hasData}, data: ${snapshot.data}');
                if (snapshot.hasData) {
                  final newUsers = snapshot.data ?? {};
                  if (newUsers.toString() != _lobbyUsers.toString()) {
                    _lobbyUsers = newUsers;
                    print('[LOBBY DEBUG] Updated _lobbyUsers: $_lobbyUsers');

                    // Only trigger rebuild if users actually changed
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() {});
                    });
                  }

                  return Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: _lobbyUsers.length,
                      itemBuilder: (context, index) {
                        final userId = _lobbyUsers.keys.elementAt(index);
                        final username = _lobbyUsers[userId]!;
                        final isCurrentUser = userId == _currentUserId;

                        // Simple display logic: username + (you) for current user
                        final displayName = isCurrentUser ? '$username (you)' : username;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 14,
                                  fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.w400,
                                  color: Colors.black,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),

          const SizedBox(height: 24),

          // Start button
          GestureDetector(
            onTap: () {
              print('[LOBBY DEBUG] Start button tapped. isSubmitting: $_isSubmitting, lobbyUsers.isEmpty: ${_lobbyUsers.isEmpty}, lobbyUsers: $_lobbyUsers');
              if (_isSubmitting || _lobbyUsers.isEmpty) {
                print('[LOBBY DEBUG] Start button disabled - cannot proceed');
                return;
              }
              _handleStart();
            },
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: (_isSubmitting || _lobbyUsers.isEmpty) ? Colors.grey : Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Start',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
              ),
            ),
          ),
        ],
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false, // Prevent closing
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
        width: screenWidth > 400 ? 350 : screenWidth * 0.85,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EDEA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFB2B2B2),
            width: 1,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content
                _buildMainContent(),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}