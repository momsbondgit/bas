import 'package:flutter/material.dart';
import '../../../services/analytics/returning_user_service.dart';
import 'dart:async';

class ReturningUsersCounter extends StatefulWidget {
  const ReturningUsersCounter({super.key});

  @override
  State<ReturningUsersCounter> createState() => _ReturningUsersCounterState();
}

class _ReturningUsersCounterState extends State<ReturningUsersCounter> {
  final ReturningUserService _returningUserService = ReturningUserService();
  StreamSubscription<int>? _subscription;
  int _returningUsersCount = 0;

  @override
  void initState() {
    super.initState();
    _setupReturningUsersStream();
  }

  void _setupReturningUsersStream() {
    _subscription = _returningUserService
        .getReturningUsersCountStream()
        .listen((count) {
      if (mounted) {
        setState(() {
          _returningUsersCount = count;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFEF4444); // Red color for returning users

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.repeat, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            _returningUsersCount.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Returning',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}