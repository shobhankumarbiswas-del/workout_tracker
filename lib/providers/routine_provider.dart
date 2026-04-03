import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/routine.dart';

class RoutineProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Routine> _routines = [];
  Routine? _currentRoutine;

  List<Routine> get routines => _routines;
  Routine? get currentRoutine => _currentRoutine;

  Future<void> loadRoutines() async {
    _routines = await _dbHelper.getAllRoutines();
    if (_currentRoutine == null && _routines.isNotEmpty) {
      _currentRoutine = _routines.first;
    }
    notifyListeners();
  }

  Future<void> addRoutine(Routine routine) async {
    await _dbHelper.insertRoutine(routine);
    await loadRoutines();
  }

  Future<void> updateRoutine(Routine routine) async {
    await _dbHelper.updateRoutine(routine);
    await loadRoutines();
  }

  Future<void> deleteRoutine(int id) async {
    await _dbHelper.deleteRoutine(id);
    if (_currentRoutine?.id == id) {
      _currentRoutine = null;
    }
    await loadRoutines();
  }

  void setCurrentRoutine(Routine routine) {
    _currentRoutine = routine;
    notifyListeners();
  }

  Routine? getRoutineById(int id) {
    try {
      return _routines.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}
