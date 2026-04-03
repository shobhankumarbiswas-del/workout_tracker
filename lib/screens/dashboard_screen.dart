import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/exercise_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/stats_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Provider.of<ExerciseProvider>(context, listen: false).loadExercises();
    await Provider.of<RoutineProvider>(context, listen: false).loadRoutines();
    await Provider.of<WorkoutProvider>(context, listen: false).loadWorkoutSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Grid
            Consumer<WorkoutProvider>(
              builder: (context, workoutProvider, _) {
                final streak = workoutProvider.getWorkoutStreak();
                final thisWeek = workoutProvider.getSessionsForWeek(
                  DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
                ).length;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Workout Streak',
                            value: '$streak',
                            subtitle: 'consecutive days',
                            icon: Icons.local_fire_department,
                            color: AppColors.danger,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'This Week',
                            value: '$thisWeek',
                            subtitle: 'workouts completed',
                            icon: Icons.calendar_today,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            // Today's Workout
            Text(
              'Today\'s Workout',
              style: AppStyles.heading2,
            ),
            const SizedBox(height: 12),
            Consumer2<RoutineProvider, WorkoutProvider>(
              builder: (context, routineProvider, workoutProvider, _) {
                final today = DateTime.now();
                final dayOfWeek = today.weekday;
                final routine = routineProvider.currentRoutine;

                if (routine == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.warning,
                            size: 48,
                            color: AppColors.warning,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No routine selected',
                            style: AppStyles.heading3,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please select a routine from the settings screen',
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final todaysExercises = routine.getExercisesForDay(dayOfWeek);

                if (todaysExercises.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.today,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Rest Day',
                            style: AppStyles.heading3,
                          ),
                          const SizedBox(height: 8),
                          const Text('Take a break and recover!'),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    ...todaysExercises.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          child: ListTile(
                            leading: Text(
                              muscleGroupEmojis[entry.value.muscleGroup] ?? '💪',
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(entry.value.name),
                            subtitle: Text(
                              '${entry.value.sets}×${entry.value.repsRange}',
                            ),
                            trailing: const Icon(Icons.check_circle_outline),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await workoutProvider.createNewSession(
                            routine.id!,
                            routine.name,
                            todaysExercises,
                          );
                          Navigator.pushNamed(context, '/workout');
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Workout'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
