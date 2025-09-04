import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePresenceCounter extends StatefulWidget {
  const HomePresenceCounter({super.key});

  @override
  State<HomePresenceCounter> createState() => _HomePresenceCounterState();
}

class _HomePresenceCounterState extends State<HomePresenceCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentCount = 0;
  int _targetCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateCount(int newCount) {
    if (newCount != _targetCount) {
      setState(() {
        _currentCount = _targetCount;
        _targetCount = newCount;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('presence_home')
          .where('isHome', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Chip(
            label: Text('Users: -'),
            backgroundColor: Colors.grey,
          );
        }

        final now = DateTime.now();
        final activeUsers = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final lastSeen = (data['lastSeen'] as Timestamp?)?.toDate();
          if (lastSeen == null) return false;
          return now.difference(lastSeen).inSeconds <= 60;
        }).length;

        // Update count with animation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateCount(activeUsers);
        });

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final displayCount = (_currentCount + 
                (_targetCount - _currentCount) * _animation.value).round();
            
            return Chip(
              label: Text('Active Users: $displayCount'),
              backgroundColor: displayCount > 0 ? Colors.green : Colors.grey,
            );
          },
        );
      },
    );
  }
}