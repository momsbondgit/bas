import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstagramCounter extends StatelessWidget {
  const InstagramCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('endings')
          .snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        
        if (snapshot.hasData) {
          // Count documents that have Instagram field
          count = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data.containsKey('instagram') && 
                   data['instagram'] != null && 
                   data['instagram'].toString().trim().isNotEmpty;
          }).length;
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE4405F).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE4405F).withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_alt,
                size: 16,
                color: const Color(0xFFE4405F),
              ),
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE4405F),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Instagram',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE4405F),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}