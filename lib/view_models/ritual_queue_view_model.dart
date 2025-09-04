import 'package:flutter/material.dart';
import 'dart:async';
import '../models/ritual_queue_state.dart';
import '../services/ritual_queue_service.dart';
import '../services/local_storage_service.dart';

class RitualQueueViewModel extends ChangeNotifier {
  final RitualQueueService _ritualQueueService = RitualQueueService();
  final LocalStorageService _localStorage = LocalStorageService();
  
  // State
  RitualQueueState? _queueState;
  String? _currentUserId;
  String? _currentDisplayName;
  bool _isInitialized = false;
  String? _errorMessage;
  
  // Private
  StreamSubscription<RitualQueueState>? _queueSubscription;
  Timer? _typingTimer;
  
  // Getters
  RitualQueueState? get queueState => _queueState;
  String? get currentUserId => _currentUserId;
  String? get currentDisplayName => _currentDisplayName;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isActiveUser => _queueState?.activeUserId == _currentUserId;
  bool get canType => isActiveUser && _queueState?.phase != QueuePhase.submitted;
  bool get canSubmit => isActiveUser && _queueState?.phase == QueuePhase.typing;

  Future<void> initialize() async {
    try {
      _clearError();
      
      // Initialize services
      await _ritualQueueService.initialize();
      _currentUserId = _ritualQueueService.currentState?.activeUserId;
      _currentDisplayName = await _localStorage.getRitualDisplayName();
      
      // Listen to queue state changes
      _listenToQueueState();
      
      _isInitialized = true;
      notifyListeners();
      
    } catch (e) {
      _setError('Failed to initialize ritual queue: $e');
    }
  }

  void _listenToQueueState() {
    _queueSubscription = _ritualQueueService.queueStateStream.listen(
      (state) {
        _queueState = state;
        _updateCurrentUserInfo();
        notifyListeners();
      },
      onError: (error) {
        _setError('Queue state error: $error');
      },
    );
  }

  void _updateCurrentUserInfo() {
    if (_queueState != null) {
      // Update current user ID if we don't have it
      _currentUserId ??= _queueState!.activeUserId;
      
      // Update display name from queue state if needed
      if (_queueState!.activeUserId == _currentUserId) {
        _currentDisplayName = _queueState!.activeDisplayName;
      }
    }
  }

  Future<void> joinQueue(String displayName) async {
    try {
      _clearError();
      
      if (displayName.trim().isEmpty) {
        _setError('Display name cannot be empty');
        return;
      }
      
      // Store display name locally
      await _localStorage.setRitualDisplayName(displayName);
      _currentDisplayName = displayName;
      
      // Get or create user ID
      if (_currentUserId == null) {
        await _ritualQueueService.initialize();
        _currentUserId = await _localStorage.getRitualUserId();
      }
      
      // Join the queue
      await _ritualQueueService.addUserToQueue(_currentUserId!, displayName);
      
      notifyListeners();
      
    } catch (e) {
      _setError('Failed to join queue: $e');
    }
  }

  Future<void> leaveQueue() async {
    try {
      _clearError();
      
      if (_currentUserId == null) return;
      
      await _ritualQueueService.removeUserFromQueue(_currentUserId!);
      
      // Clear local data
      await _localStorage.setRitualDisplayName('');
      _currentDisplayName = null;
      
      notifyListeners();
      
    } catch (e) {
      _setError('Failed to leave queue: $e');
    }
  }

  void startTyping() {
    if (!canType) return;
    
    try {
      _clearError();
      
      _ritualQueueService.startTyping(_currentUserId!);
      // Typing indicator removed
      
      // Reset typing timer
      _resetTypingTimer();
      
    } catch (e) {
      _setError('Failed to start typing: $e');
    }
  }

  void stopTyping() {
    if (_currentUserId == null) return;
    
    try {
      _clearError();
      
      _ritualQueueService.stopTyping(_currentUserId!);
      // Typing indicator removed
      
      _cancelTypingTimer();
      
    } catch (e) {
      _setError('Failed to stop typing: $e');
    }
  }

  void onTextChanged(String text) {
    if (!canType) return;
    
    if (text.trim().isNotEmpty) {
      startTyping();
    } else {
      stopTyping();
    }
  }

  Future<void> submitMessage(String content) async {
    if (!canSubmit || _currentUserId == null) {
      _setError('Cannot submit message at this time');
      return;
    }
    
    try {
      _clearError();
      
      if (content.trim().isEmpty) {
        _setError('Message cannot be empty');
        return;
      }
      
      // Stop typing indicator first
      // Typing indicator removed
      _cancelTypingTimer();
      
      // Submit the message
      await _ritualQueueService.submitMessage(_currentUserId!, content);
      
      notifyListeners();
      
    } catch (e) {
      _setError('Failed to submit message: $e');
    }
  }

  // Reaction methods removed - reactions are now local-only

  void dismissRotationBanner() {
    if (_queueState?.showRotationBanner == true) {
      // The banner will auto-dismiss, but we can manually dismiss it
      // This could trigger a state update in the service if needed
      notifyListeners();
    }
  }

  void _resetTypingTimer() {
    _cancelTypingTimer();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      if (_currentUserId != null) {
        stopTyping();
      }
    });
  }

  void _cancelTypingTimer() {
    _typingTimer?.cancel();
    _typingTimer = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
    
    // Auto-clear error after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (_errorMessage == message) {
        _clearError();
      }
    });
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearError() => _clearError();

  // Helper methods for UI
  String getRemainingTimeText() {
    if (_queueState?.remainingTime == null) return '';
    
    final duration = _queueState!.remainingTime;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  int getQueuePosition() {
    if (_queueState?.userQueue == null || _currentUserId == null) return -1;
    
    final userIndex = _queueState!.userQueue.indexWhere((user) => user.id == _currentUserId);
    return userIndex >= 0 ? userIndex + 1 : -1;
  }

  int getTotalQueueSize() {
    return _queueState?.userQueue.length ?? 0;
  }

  @override
  void dispose() {
    _cancelTypingTimer();
    _queueSubscription?.cancel();
    
    _ritualQueueService.dispose();
    
    super.dispose();
  }
}