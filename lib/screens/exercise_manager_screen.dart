import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../models/exercise.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class ExerciseManagerScreen extends StatefulWidget {
  const ExerciseManagerScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseManagerScreen> createState() => _ExerciseManagerScreenState();
}

class _ExerciseManagerScreenState extends State<ExerciseManagerScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ExerciseProvider>(context, listen: false).loadExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Manager'),
        centerTitle: true,
      ),
      body: Consumer<ExerciseProvider>(
        builder: (context, exerciseProvider, _) {
          final exercises = exerciseProvider.exercises;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length + 1,
            itemBuilder: (context, index) {
              if (index == exercises.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Exercise'),
                      onPressed: () {
                        _showExerciseDialog(context);
                      },
                    ),
                  ),
                );
              }

              final exercise = exercises[index];
              return Card(
                child: ListTile(
                  leading: Text(
                    muscleGroupEmojis[exercise.muscleGroup] ?? '💪',
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(exercise.name),
                  subtitle: Text(
                    '${exercise.sets}×${exercise.repsRange} • ${formatDuration(exercise.defaultDurationSeconds)}',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () {
                          Future.delayed(Duration.zero, () {
                            _showExerciseDialog(context, exercise);
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () {
                          _showDeleteDialog(context, exercise);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showExerciseDialog(BuildContext context, [Exercise? exercise]) {
    final nameController = TextEditingController(text: exercise?.name ?? '');
    final durationController = TextEditingController(
      text: (exercise?.defaultDurationSeconds ?? 0).toString(),
    );
    final setsController = TextEditingController(
      text: (exercise?.sets ?? 3).toString(),
    );
    final repsController = TextEditingController(text: exercise?.repsRange ?? '10-12');
    String selectedMuscleGroup = exercise?.muscleGroup ?? 'Chest';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise == null ? 'Add Exercise' : 'Edit Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Exercise Name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedMuscleGroup,
                decoration: const InputDecoration(labelText: 'Muscle Group'),
                items: muscleGroupEmojis.keys.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedMuscleGroup = value ?? selectedMuscleGroup;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration (seconds)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: setsController,
                decoration: const InputDecoration(labelText: 'Sets'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repsController,
                decoration: const InputDecoration(labelText: 'Reps Range (e.g., 10-12)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newExercise = Exercise(
                id: exercise?.id,
                name: nameController.text,
                muscleGroup: selectedMuscleGroup,
                defaultDurationSeconds: int.parse(durationController.text),
                sets: int.parse(setsController.text),
                repsRange: repsController.text,
              );

              if (exercise == null) {
                Provider.of<ExerciseProvider>(context, listen: false)
                    .addExercise(newExercise);
              } else {
                Provider.of<ExerciseProvider>(context, listen: false)
                    .updateExercise(newExercise);
              }

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Delete ${exercise.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ExerciseProvider>(context, listen: false)
                  .deleteExercise(exercise.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
