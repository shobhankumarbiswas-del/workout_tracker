import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/exercise_card.dart';
import '../widgets/timer_widget.dart';
import '../models/workout_session.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({Key? key}) : super(key: key);

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int _currentExerciseIndex = 0;
  bool _showTimer = false;
  int _restDuration = 45;
  final Map<int, int?> _weights = {};
  final Map<int, String> _reps = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Workout'),
        centerTitle: true,
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, _) {
          final session = workoutProvider.currentSession;

          if (session == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active workout',
                    style: AppStyles.heading2,
                  ),
                  const SizedBox(height: 8),
                  const Text('Start a workout from the dashboard'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: const Text('Go to Dashboard'),
                  ),
                ],
              ),
            );
          }

          final exercises = session.exercises;
          
          // This is a workaround - in a real app, you'd use the data from the routine
          // For now, we'll display a simple list

          return _showTimer
              ? _buildTimerView(session)
              : _buildExerciseListView(session);
        },
      ),
    );
  }

  Widget _buildTimerView(WorkoutSession session) {
    final currentExercise = session.exercises.isNotEmpty
        ? session.exercises[_currentExerciseIndex]
        : null;

    if (currentExercise == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
            Text(
              'Workout Complete!',
              style: AppStyles.heading2,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Finish'),
                  onPressed: () async {
                    await Provider.of<WorkoutProvider>(context, listen: false)
                        .completeSession();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    }
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  onPressed: () {
                    setState(() {
                      _showTimer = false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Exercise ${_currentExerciseIndex + 1} of ${session.exercises.length}',
            style: AppStyles.bodySmall,
          ),
          const SizedBox(height: 12),
          Text(
            currentExercise.exerciseName,
            style: AppStyles.heading2,
          ),
          const SizedBox(height: 24),
          TimerWidget(
            durationSeconds: currentExercise.durationSeconds,
            onComplete: () {
              _showRestTimer();
            },
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Log Reps', style: AppStyles.heading3),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter reps completed (e.g., 12, 10, 8)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _reps[_currentExerciseIndex] = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Weight (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _weights[_currentExerciseIndex] = int.tryParse(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                onPressed: () {
                  setState(() {
                    _showTimer = false;
                  });
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
                onPressed: () {
                  if (_currentExerciseIndex < session.exercises.length - 1) {
                    setState(() {
                      _currentExerciseIndex++;
                    });
                  } else {
                    setState(() {
                      _showTimer = false;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseListView(WorkoutSession session) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Exercises',
            style: AppStyles.heading2,
          ),
          const SizedBox(height: 16),
          ...session.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;

            return ExerciseCard(
              exercise: exercise as dynamic,
              onTap: () {
                setState(() {
                  _currentExerciseIndex = index;
                  _showTimer = true;
                });
              },
            );
          }).toList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Finish Workout'),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text('Finish this workout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Finish'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await Provider.of<WorkoutProvider>(context, listen: false)
                      .completeSession();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRestTimer() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TimerWidget(
            durationSeconds: _restDuration,
            isRestTimer: true,
            onComplete: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
