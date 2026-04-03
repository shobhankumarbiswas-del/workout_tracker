import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;
  final VoidCallback onTap;
  final int? weight;

  const ExerciseCard({
    required this.exercise,
    this.isCompleted = false,
    required this.onTap,
    this.weight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emoji = muscleGroupEmojis[exercise.muscleGroup] ?? '💪';

    return Card(
      elevation: isCompleted ? 2 : 4,
      color: isCompleted ? AppColors.background : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: AppStyles.heading3.copyWith(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.sets}×${exercise.repsRange} • ${formatDuration(exercise.defaultDurationSeconds)}',
                      style: AppStyles.bodySmall,
                    ),
                    if (weight != null && weight! > 0)
                      Text(
                        'Weight: ${weight}kg',
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
