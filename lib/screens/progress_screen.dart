import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        centerTitle: true,
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, _) {
          final sessions = workoutProvider.workoutSessions;
          final streak = workoutProvider.getWorkoutStreak();

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No workout history',
                    style: AppStyles.heading2,
                  ),
                  const SizedBox(height: 8),
                  const Text('Complete your first workout to see stats!'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                size: 32,
                                color: AppColors.danger,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$streak',
                                style: AppStyles.heading1,
                              ),
                              const SizedBox(height: 4),
                              const Text('Day Streak'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.fitness_center,
                                size: 32,
                                color: AppColors.success,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${sessions.length}',
                                style: AppStyles.heading1,
                              ),
                              const SizedBox(height: 4),
                              const Text('Total Workouts'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // History
                Text(
                  'Workout History',
                  style: AppStyles.heading2,
                ),
                const SizedBox(height: 12),
                ...sessions.take(10).map((session) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: AppColors.success),
                      title: Text(session.routineName),
                      subtitle: Text(formatDate(session.date)),
                      trailing: Text(
                        '${session.exercises.length} exercises',
                        style: AppStyles.bodySmall,
                      ),
                      onTap: () {
                        _showSessionDetails(context, session);
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSessionDetails(BuildContext context, dynamic session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.routineName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${formatDate(session.date)}',
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Exercises: ',
                style: AppStyles.heading3,
              ),
              ...session.exercises.map<Widget>((exercise) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '• ${exercise.exerciseName}: ${exercise.setsCompleted} sets',
                    style: AppStyles.bodySmall,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
