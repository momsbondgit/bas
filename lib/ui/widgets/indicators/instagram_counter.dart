import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class InstagramCounter extends StatefulWidget {
  const InstagramCounter({super.key});

  @override
  State<InstagramCounter> createState() => _InstagramCounterState();
}

class _InstagramCounterState extends State<InstagramCounter> {
  StreamSubscription<QuerySnapshot>? _subscription;
  int _instagramCount = 0;

  @override
  void initState() {
    super.initState();
    _setupInstagramCountStream();
  }

  void _setupInstagramCountStream() {
    _subscription = FirebaseFirestore.instance
        .collection('endings')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        final countWithInstagram = snapshot.docs
            .where((doc) {
              final data = doc.data();
              return data.containsKey('instagram') && 
                     data['instagram'] != null && 
                     data['instagram'].toString().trim().isNotEmpty;
            })
            .length;
            
        setState(() {
          _instagramCount = countWithInstagram;
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
    const color = Color(0xFFE4405F); // Instagram brand color

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
          const Icon(Icons.camera_alt, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            _instagramCount.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Instagram',
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