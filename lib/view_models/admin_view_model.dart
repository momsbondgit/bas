import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../services/admin/admin_service.dart';
import '../services/admin/maintenance_service.dart';
import '../services/data/post_service.dart';
import '../ui/screens/admin_screen.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  final MaintenanceService _maintenanceService = MaintenanceService();
  final PostService _postService = PostService();
  
  // State
  AdminSection _currentSection = AdminSection.postsManagement;
  List<QueryDocumentSnapshot> _posts = [];
  List<QueryDocumentSnapshot> _endings = [];
  MaintenanceStatus? _maintenanceStatus;
  int _remainingSessionMinutes = 0;
  bool _isLoading = true;
  
  // Private
  StreamSubscription<QuerySnapshot>? _postsSubscription;
  StreamSubscription<QuerySnapshot>? _endingsSubscription;
  StreamSubscription<MaintenanceStatus>? _maintenanceSubscription;
  Timer? _sessionTimer;
  
  // Getters
  AdminSection get currentSection => _currentSection;
  List<QueryDocumentSnapshot> get posts => _posts;
  List<QueryDocumentSnapshot> get endings => _endings;
  MaintenanceStatus? get maintenanceStatus => _maintenanceStatus;
  int get remainingSessionMinutes => _remainingSessionMinutes;
  bool get isLoading => _isLoading;

  void initialize() {
    _checkAuthentication();
    _setupDataStreams();
    _startSessionTimer();
  }

  void _checkAuthentication() async {
    final isLoggedIn = await _adminService.isLoggedIn();
    if (!isLoggedIn) {
      // Notify listeners that authentication failed
      notifyListeners();
      return;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void _setupDataStreams() {
    _postsSubscription = _postService.getPostsStream().listen((snapshot) {
      _posts = snapshot.docs;
      notifyListeners();
    });

    _endingsSubscription = FirebaseFirestore.instance
        .collection('endings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _endings = snapshot.docs;
      notifyListeners();
    });

    _maintenanceSubscription = _maintenanceService
        .getMaintenanceStatusStream()
        .listen((status) {
      _maintenanceStatus = status;
      notifyListeners();
    });
  }

  void _startSessionTimer() {
    _updateRemainingTime();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() async {
    final minutes = await _adminService.getRemainingSessionMinutes();
    _remainingSessionMinutes = minutes;
    notifyListeners();
    
    if (minutes <= 0) {
      await logout();
    }
  }

  Future<void> logout() async {
    await _adminService.logout();
    notifyListeners();
  }

  Future<void> extendSession() async {
    await _adminService.extendSession();
    _updateRemainingTime();
    notifyListeners();
  }

  void onSectionChanged(AdminSection section) {
    _currentSection = section;
    notifyListeners();
  }

  String getSectionTitle() {
    switch (_currentSection) {
      case AdminSection.postsManagement:
        return 'Posts Management';
      case AdminSection.addPost:
        return 'Add Post';
      case AdminSection.systemControls:
        return 'System Controls';
    }
  }

  String getSectionSubtitle() {
    switch (_currentSection) {
      case AdminSection.postsManagement:
        return 'View and manage all posts';
      case AdminSection.addPost:
        return 'Create new posts as admin';
      case AdminSection.systemControls:
        return 'Maintenance and system settings';
    }
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    _endingsSubscription?.cancel();
    _maintenanceSubscription?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }
}