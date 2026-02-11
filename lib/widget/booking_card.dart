import 'package:flutter/material.dart';
import 'app_text.dart';

class BookingCard extends StatelessWidget {
  final int index;
  final String name;
  final String treatment;
  final String date;
  final String therapist;

  const BookingCard({
    super.key,
    required this.index,
    required this.name,
    required this.treatment,
    required this.date,
    required this.therapist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Top Row → Index + Name
          Row(
            children: [
              AppText(
                "$index.",
                weight: FontWeight.w600,
              ),
              const SizedBox(width: 8),
              AppText(
                name,
                size: 16,
                weight: FontWeight.w600,
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// Treatment
          AppText(
            treatment,
            color: Colors.green,
            weight: FontWeight.w500,
          ),

          const SizedBox(height: 10),

          /// Date & Therapist
          Row(
            children: [

              Icon(Icons.calendar_today,
                  size: 16, color: Colors.orange),
              const SizedBox(width: 6),
              AppText(date),

              const SizedBox(width: 16),

              Icon(Icons.people,
                  size: 16, color: Colors.orange),
              const SizedBox(width: 6),
              AppText(therapist),
            ],
          ),

          const SizedBox(height: 10),

          Divider(color: Colors.grey[400]),

          /// Bottom Row
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: const [
              AppText(
                "View Booking details",
                weight: FontWeight.w500,
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }
}
