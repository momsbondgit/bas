import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceService {
  static const String _collectionName = 'system';
  static const String _documentId = 'maintenance';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Get maintenance status from Firestore
  Future<MaintenanceStatus> getMaintenanceStatus() async {
    final doc = await _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .get();

    if (!doc.exists) {
      await _initializeMaintenanceDocument();
      return MaintenanceStatus(
        isEnabled: false,
        message: 'We\'re currently performing some maintenance. Please check back soon!',
        lastUpdated: DateTime.now(),
        sessionEndTime: DateTime.now().add(const Duration(minutes: 1)),
        defaultSessionMinutes: 1,
      );
    }

    final data = doc.data() as Map<String, dynamic>;
    return MaintenanceStatus.fromMap(data);
  }

  /// Get maintenance status stream for real-time updates
  Stream<MaintenanceStatus> getMaintenanceStatusStream() {
    return _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return MaintenanceStatus(
          isEnabled: false,
          message: 'We\'re currently performing some maintenance. Please check back soon!',
          lastUpdated: DateTime.now(),
        );
      }
      
      final data = doc.data() as Map<String, dynamic>;
      return MaintenanceStatus.fromMap(data);
    });
  }

  /// Set maintenance mode status (Admin only)
  Future<void> setMaintenanceMode({
    required bool enabled,
    String? customMessage,
  }) async {
    // Get current status to preserve existing timer data
    final currentStatus = await getMaintenanceStatus();
    
    final message = customMessage ?? 
        (enabled 
            ? 'We\'re currently performing some maintenance. Please check back soon!'
            : '');
    
    final maintenanceStatus = MaintenanceStatus(
      isEnabled: enabled,
      message: message,
      lastUpdated: DateTime.now(),
      sessionEndTime: currentStatus.sessionEndTime,
      defaultSessionMinutes: currentStatus.defaultSessionMinutes,
    );

    await _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .set(maintenanceStatus.toMap(), SetOptions(merge: true));
  }

  /// Initialize maintenance document if it doesn't exist
  Future<void> _initializeMaintenanceDocument() async {
    final initialStatus = MaintenanceStatus(
      isEnabled: false,
      message: 'We\'re currently performing some maintenance. Please check back soon!',
      lastUpdated: DateTime.now(),
      sessionEndTime: DateTime.now().add(const Duration(minutes: 1)),
      defaultSessionMinutes: 1,
    );

    await _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .set(initialStatus.toMap());
  }


  /// Extend current session timer (Admin only)
  Future<void> extendSessionTimer({required int additionalMinutes}) async {
    final status = await getMaintenanceStatus();
    final currentEndTime = status.sessionEndTime ?? DateTime.now();
    final newEndTime = currentEndTime.add(Duration(minutes: additionalMinutes));
    
    final updatedStatus = MaintenanceStatus(
      isEnabled: status.isEnabled,
      message: status.message,
      lastUpdated: DateTime.now(),
      sessionEndTime: newEndTime,
      defaultSessionMinutes: status.defaultSessionMinutes,
    );

    await _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .set(updatedStatus.toMap(), SetOptions(merge: true));
  }

  /// Start a fresh session timer (used on app initialization)
  Future<void> startFreshSession({int minutes = 1}) async {
    final status = await getMaintenanceStatus();
    final newEndTime = DateTime.now().add(Duration(minutes: minutes));
    
    final updatedStatus = MaintenanceStatus(
      isEnabled: status.isEnabled,
      message: status.message,
      lastUpdated: DateTime.now(),
      sessionEndTime: newEndTime,
      defaultSessionMinutes: minutes,
    );

    await _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .set(updatedStatus.toMap(), SetOptions(merge: true));
  }

  /// Clear expired session timer
  Future<void> clearExpiredTimer() async {
    final status = await getMaintenanceStatus();
    final updatedStatus = MaintenanceStatus(
      isEnabled: status.isEnabled,
      message: status.message,
      lastUpdated: DateTime.now(),
      sessionEndTime: null,
      defaultSessionMinutes: status.defaultSessionMinutes,
    );

    await _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .set(updatedStatus.toMap(), SetOptions(merge: true));
  }
}

/// Data class for maintenance status
class MaintenanceStatus {
  final bool isEnabled;
  final String message;
  final DateTime lastUpdated;
  final DateTime? sessionEndTime;
  final int defaultSessionMinutes;

  const MaintenanceStatus({
    required this.isEnabled,
    required this.message,
    required this.lastUpdated,
    this.sessionEndTime,
    this.defaultSessionMinutes = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'message': message,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'sessionEndTime': sessionEndTime != null ? Timestamp.fromDate(sessionEndTime!) : null,
      'defaultSessionMinutes': defaultSessionMinutes,
    };
  }

  factory MaintenanceStatus.fromMap(Map<String, dynamic> map) {
    return MaintenanceStatus(
      isEnabled: map['isEnabled'] ?? false,
      message: map['message'] ?? 'We\'re currently performing some maintenance. Please check back soon!',
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sessionEndTime: (map['sessionEndTime'] as Timestamp?)?.toDate(),
      defaultSessionMinutes: map['defaultSessionMinutes'] ?? 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MaintenanceStatus &&
        other.isEnabled == isEnabled &&
        other.message == message &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => isEnabled.hashCode ^ message.hashCode ^ lastUpdated.hashCode;

  /// Get remaining seconds until session ends
  int get remainingSeconds {
    if (sessionEndTime == null) return 0;
    final remaining = sessionEndTime!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Get remaining time as minutes and seconds
  Map<String, int> get remainingTime {
    final remaining = remainingSeconds;
    return {
      'minutes': remaining ~/ 60,
      'seconds': remaining % 60,
    };
  }

  @override
  String toString() => 'MaintenanceStatus(isEnabled: $isEnabled, message: $message, lastUpdated: $lastUpdated, sessionEndTime: $sessionEndTime)';
}

