import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../constants/app_colors.dart';

class SessionCard extends StatelessWidget {
  final Session session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, yyyy').format(session.scheduledAt);
    final time = DateFormat('h:mm a').format(session.scheduledAt);
    final createdOn = DateFormat('MMM d, yyyy • h:mm a').format(session.timeScheduled);

    IconData icon;
    Color color;

    switch (session.status.toLowerCase()) {
      case 'confirmed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'pending':
        icon = Icons.hourglass_bottom;
        color = Colors.orange;
        break;
      case 'cancelled':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        color = AppColors.tealShade300;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.teal),
                const SizedBox(width: 8),
                Text(
                  'Session #${session.count}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTeal,
                  ),
                ),
                const Spacer(),
                Icon(icon, color: color),
                const SizedBox(width: 4),
                Text(
                  session.status,
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule, color: AppColors.teal, size: 20),
                const SizedBox(width: 6),
                Text("$date at $time",
                    style: const TextStyle(color: AppColors.tealShade300)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.edit_calendar, color: AppColors.teal, size: 20),
                const SizedBox(width: 6),
                Text("Scheduled on: $createdOn",
                    style: const TextStyle(color: AppColors.tealShade300)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
