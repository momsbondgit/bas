import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class PhoneNumbersCounter extends StatefulWidget {
  const PhoneNumbersCounter({super.key});

  @override
  State<PhoneNumbersCounter> createState() => _PhoneNumbersCounterState();
}

class _PhoneNumbersCounterState extends State<PhoneNumbersCounter> {
  StreamSubscription<QuerySnapshot>? _subscription;
  int _phoneCount = 0;

  @override
  void initState() {
    super.initState();
    _setupPhoneCountStream();
  }

  void _setupPhoneCountStream() {
    _subscription = FirebaseFirestore.instance
        .collection('endings')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        final countWithPhone = snapshot.docs
            .where((doc) {
              final data = doc.data();
              return data.containsKey('phone') && 
                     data['phone'] != null && 
                     data['phone'].toString().trim().isNotEmpty;
            })
            .length;
            
        setState(() {
          _phoneCount = countWithPhone;
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
    const color = Color(0xFF059669); // Green color for phone numbers

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
          const Icon(Icons.phone, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            _phoneCount.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Phone',
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