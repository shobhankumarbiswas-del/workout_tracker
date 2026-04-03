import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? color;

  const StatsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [cardColor.withOpacity(0.7), cardColor.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: cardColor),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppStyles.heading2.copyWith(color: cardColor),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
