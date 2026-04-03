import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/exercise.dart';

class ExerciseProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Exercise> _exercises = [];

  List<Exercise> get exercises => _exercises;

  Future<void> loadExercises() async {
    _exercises = await _dbHelper.getAllExercises();
    notifyListeners();
  }

  Future<void> addExercise(Exercise exercise) async {
    await _dbHelper.insertExercise(exercise);
    await loadExercises();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _dbHelper.updateExercise(exercise);
    await loadExercises();
  }

  Future<void> deleteExercise(int id) async {
    await _dbHelper.deleteExercise(id);
    await loadExercises();
  }

  Exercise? getExerciseById(int id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
