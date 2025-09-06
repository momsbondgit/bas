import 'package:flutter/material.dart';
import '../../../services/analytics/returning_user_service.dart';

class ReturningUsersCounter extends StatefulWidget {
  const ReturningUsersCounter({super.key});

  @override
  State<ReturningUsersCounter> createState() => _ReturningUsersCounterState();
}

class _ReturningUsersCounterState extends State<ReturningUsersCounter> {
  final ReturningUserService _service = ReturningUserService();
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _service.getReturningUsersCountStream(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.repeat,
                size: 16,
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Returning',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}