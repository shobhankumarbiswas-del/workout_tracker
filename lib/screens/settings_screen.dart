import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';
import '../providers/exercise_provider.dart';
import '../models/routine.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _restDuration = 45;

  @override
  void initState() {
    super.initState();
    Provider.of<RoutineProvider>(context, listen: false).loadRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rest Duration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Rest Duration',
                      style: AppStyles.heading3,
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _restDuration.toDouble(),
                      min: 15,
                      max: 120,
                      divisions: 21,
                      label: '${_restDuration}s',
                      onChanged: (value) {
                        setState(() {
                          _restDuration = value.toInt();
                        });
                      },
                    ),
                    Text(
                      'Current: ${_restDuration}s',
                      style: AppStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Routine Selection
            Text(
              'Active Routine',
              style: AppStyles.heading2,
            ),
            const SizedBox(height: 12),
            Consumer<RoutineProvider>(
              builder: (context, routineProvider, _) {
                final routines = routineProvider.routines;
                final currentRoutine = routineProvider.currentRoutine;

                if (routines.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No routines available',
                        style: AppStyles.bodyMedium,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    ...routines.map((routine) {
                      final isSelected = routine.id == currentRoutine?.id;
                      return Card(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                        child: ListTile(
                          leading: Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                          title: Text(routine.name),
                          onTap: () {
                            routineProvider.setCurrentRoutine(routine);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${routine.name} selected'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            // Create New Routine
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Custom Routine'),
                onPressed: () {
                  _showCreateRoutineDialog();
                },
              ),
            ),
            const SizedBox(height: 24),
            // About
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: AppStyles.heading3,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Workout Tracker v1.0',
                      style: AppStyles.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your fitness journey with custom workouts, timers, and progress analytics.',
                      style: AppStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoutineDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Routine'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Routine Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final routine = Routine(
                name: nameController.text,
                dayExercises: <int, dynamic>{},
              );
              Provider.of<RoutineProvider>(context, listen: false)
                  .addRoutine(routine);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${nameController.text} created'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
