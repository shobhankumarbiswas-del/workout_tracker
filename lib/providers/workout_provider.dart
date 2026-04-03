import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/workout_session.dart';
import '../models/exercise.dart';

class WorkoutProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<WorkoutSession> _workoutSessions = [];
  WorkoutSession? _currentSession;

  List<WorkoutSession> get workoutSessions => _workoutSessions;
  WorkoutSession? get currentSession => _currentSession;

  Future<void> loadWorkoutSessions() async {
    _workoutSessions = await _dbHelper.getAllWorkoutSessions();
    notifyListeners();
  }

  Future<void> createNewSession(
    int routineId,
    String routineName,
    List<Exercise> exercises,
  ) async {
    _currentSession = WorkoutSession(
      routineId: routineId,
      routineName: routineName,
      date: DateTime.now(),
      exercises: [],
      completed: false,
      totalDurationSeconds: 0,
    );
    notifyListeners();
  }

  Future<void> addExerciseLog(ExerciseLog log) async {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        exercises: [..._currentSession!.exercises, log],
        totalDurationSeconds: _currentSession!.totalDurationSeconds + log.durationSeconds,
      );
      notifyListeners();
    }
  }

  Future<void> updateExerciseLog(int index, ExerciseLog log) async {
    if (_currentSession != null && index < _currentSession!.exercises.length) {
      final exercises = [..._currentSession!.exercises];
      exercises[index] = log;
      _currentSession = _currentSession!.copyWith(exercises: exercises);
      notifyListeners();
    }
  }

  Future<void> completeSession() async {
    if (_currentSession != null) {
      final completed = _currentSession!.copyWith(completed: true);
      await _dbHelper.insertWorkoutSession(completed);
      await loadWorkoutSessions();
      _currentSession = null;
      notifyListeners();
    }
  }

  Future<void> saveCurrentSession() async {
    if (_currentSession != null) {
      await _dbHelper.insertWorkoutSession(_currentSession!);
      await loadWorkoutSessions();
      notifyListeners();
    }
  }

  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }

  List<WorkoutSession> getSessionsForMonth(int year, int month) {
    return _workoutSessions.where((session) {
      return session.date.year == year && session.date.month == month;
    }).toList();
  }

  List<WorkoutSession> getSessionsForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _workoutSessions.where((session) {
      return session.date.isAfter(weekStart) && session.date.isBefore(weekEnd);
    }).toList();
  }

  int getWorkoutStreak() {
    if (_workoutSessions.isEmpty) return 0;
    
    _workoutSessions.sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime? lastWorkoutDate;
    
    for (final session in _workoutSessions) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      
      if (lastWorkoutDate == null) {
        lastWorkoutDate = sessionDate;
        streak = 1;
      } else {
        final daysDiff = lastWorkoutDate.difference(sessionDate).inDays;
        if (daysDiff == 1) {
          streak++;
          lastWorkoutDate = sessionDate;
        } else {
          break;
        }
      }
    }
    
    return streak;
  }

  WorkoutSession? getTodaysSession() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    try {
      return _workoutSessions.firstWhere((session) {
        final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
        return sessionDate == todayDate;
      });
    } catch (e) {
      return null;
    }
  }
}
