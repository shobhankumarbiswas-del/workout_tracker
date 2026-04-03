import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../models/workout_session.dart';
import 'dart:convert';

class DatabaseHelper {
  static const String _dbName = 'workout_tracker.db';
  static const int _dbVersion = 1;

  // Table names
  static const String exercisesTable = 'exercises';
  static const String routinesTable = 'routines';
  static const String workoutSessionsTable = 'workout_sessions';

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create exercises table
    await db.execute('''
      CREATE TABLE $exercisesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        muscleGroup TEXT NOT NULL,
        defaultDurationSeconds INTEGER NOT NULL,
        notes TEXT,
        sets INTEGER NOT NULL,
        repsRange TEXT NOT NULL
      )
    ''');

    // Create routines table (stores as JSON)
    await db.execute('''
      CREATE TABLE $routinesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dayExercisesJson TEXT NOT NULL,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create workout sessions table
    await db.execute('''
      CREATE TABLE $workoutSessionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routineId INTEGER NOT NULL,
        routineName TEXT NOT NULL,
        date TEXT NOT NULL,
        exercisesJson TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        totalDurationSeconds INTEGER NOT NULL,
        FOREIGN KEY(routineId) REFERENCES $routinesTable(id)
      )
    ''');

    // Insert default exercises
    await _insertDefaultExercises(db);

    // Insert default routine
    await _insertDefaultRoutine(db);
  }

  Future<void> _insertDefaultExercises(Database db) async {
    final defaultExercises = _getDefaultExercises();
    for (final exercise in defaultExercises) {
      await db.insert(exercisesTable, {
        'name': exercise.name,
        'muscleGroup': exercise.muscleGroup,
        'defaultDurationSeconds': exercise.defaultDurationSeconds,
        'notes': exercise.notes,
        'sets': exercise.sets,
        'repsRange': exercise.repsRange,
      });
    }
  }

  Future<void> _insertDefaultRoutine(Database db) async {
    final defaultRoutine = _getDefaultRoutine();
    final dayExercisesJson = _encodeDayExercises(defaultRoutine.dayExercises);

    await db.insert(routinesTable, {
      'name': defaultRoutine.name,
      'dayExercisesJson': dayExercisesJson,
    });
  }

  // Exercise CRUD
  Future<int> insertExercise(Exercise exercise) async {
    final db = await database;
    return await db.insert(exercisesTable, {
      'name': exercise.name,
      'muscleGroup': exercise.muscleGroup,
      'defaultDurationSeconds': exercise.defaultDurationSeconds,
      'notes': exercise.notes,
      'sets': exercise.sets,
      'repsRange': exercise.repsRange,
    });
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final maps = await db.query(exercisesTable);
    return List.generate(maps.length, (i) {
      return Exercise(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        muscleGroup: maps[i]['muscleGroup'] as String,
        defaultDurationSeconds: maps[i]['defaultDurationSeconds'] as int,
        notes: maps[i]['notes'] as String?,
        sets: maps[i]['sets'] as int,
        repsRange: maps[i]['repsRange'] as String,
      );
    });
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await database;
    return await db.update(
      exercisesTable,
      {
        'name': exercise.name,
        'muscleGroup': exercise.muscleGroup,
        'defaultDurationSeconds': exercise.defaultDurationSeconds,
        'notes': exercise.notes,
        'sets': exercise.sets,
        'repsRange': exercise.repsRange,
      },
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await database;
    return await db.delete(
      exercisesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Routine CRUD
  Future<int> insertRoutine(Routine routine) async {
    final db = await database;
    final dayExercisesJson = _encodeDayExercises(routine.dayExercises);
    return await db.insert(routinesTable, {
      'name': routine.name,
      'dayExercisesJson': dayExercisesJson,
    });
  }

  Future<List<Routine>> getAllRoutines() async {
    final db = await database;
    final maps = await db.query(routinesTable);
    return List.generate(maps.length, (i) {
      final dayExercises = _decodeDayExercises(maps[i]['dayExercisesJson'] as String);
      return Routine(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        dayExercises: dayExercises,
      );
    });
  }

  Future<int> updateRoutine(Routine routine) async {
    final db = await database;
    final dayExercisesJson = _encodeDayExercises(routine.dayExercises);
    return await db.update(
      routinesTable,
      {'name': routine.name, 'dayExercisesJson': dayExercisesJson},
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  Future<int> deleteRoutine(int id) async {
    final db = await database;
    return await db.delete(
      routinesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Workout Session CRUD
  Future<int> insertWorkoutSession(WorkoutSession session) async {
    final db = await database;
    final exercisesJson = jsonEncode(
      session.exercises.map((e) => e.toJson()).toList(),
    );
    return await db.insert(workoutSessionsTable, {
      'routineId': session.routineId,
      'routineName': session.routineName,
      'date': session.date.toIso8601String(),
      'exercisesJson': exercisesJson,
      'completed': session.completed ? 1 : 0,
      'totalDurationSeconds': session.totalDurationSeconds,
    });
  }

  Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    final db = await database;
    final maps = await db.query(workoutSessionsTable, orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      final exercisesJson = maps[i]['exercisesJson'] as String;
      final exercises = (jsonDecode(exercisesJson) as List)
          .map((e) => ExerciseLog.fromJson(e))
          .toList();
      return WorkoutSession(
        id: maps[i]['id'] as int,
        routineId: maps[i]['routineId'] as int,
        routineName: maps[i]['routineName'] as String,
        date: DateTime.parse(maps[i]['date'] as String),
        exercises: exercises,
        completed: (maps[i]['completed'] as int) == 1,
        totalDurationSeconds: maps[i]['totalDurationSeconds'] as int,
      );
    });
  }

  Future<int> updateWorkoutSession(WorkoutSession session) async {
    final db = await database;
    final exercisesJson = jsonEncode(
      session.exercises.map((e) => e.toJson()).toList(),
    );
    return await db.update(
      workoutSessionsTable,
      {
        'exercisesJson': exercisesJson,
        'completed': session.completed ? 1 : 0,
        'totalDurationSeconds': session.totalDurationSeconds,
      },
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  // Helper methods
  String _encodeDayExercises(Map<int, List<Exercise>> dayExercises) {
    final encoded = dayExercises.map((day, exercises) {
      return MapEntry(
        day.toString(),
        exercises.map((e) => e.toJson()).toList(),
      );
    });
    return jsonEncode(encoded);
  }

  Map<int, List<Exercise>> _decodeDayExercises(String json) {
    final decoded = jsonDecode(json) as Map;
    return decoded.map((day, exercises) {
      return MapEntry(
        int.parse(day),
        List<Exercise>.from(
          (exercises as List).map((e) => Exercise.fromJson(e)),
        ),
      );
    });
  }

  List<Exercise> _getDefaultExercises() {
    return [
      // Day 1 - PUSH
      Exercise(
        name: 'Floor Press',
        muscleGroup: 'Chest',
        defaultDurationSeconds: 120,
        sets: 4,
        repsRange: '10-12',
      ),
      Exercise(
        name: 'Shoulder Press',
        muscleGroup: 'Shoulders',
        defaultDurationSeconds: 120,
        sets: 4,
        repsRange: '8-12',
      ),
      Exercise(
        name: 'Lateral Raise',
        muscleGroup: 'Shoulders',
        defaultDurationSeconds: 90,
        sets: 3,
        repsRange: '12-15',
      ),
      Exercise(
        name: 'Chest Fly',
        muscleGroup: 'Chest',
        defaultDurationSeconds: 100,
        sets: 3,
        repsRange: '10-12',
      ),
      Exercise(
        name: 'Tricep Extension',
        muscleGroup: 'Triceps',
        defaultDurationSeconds: 90,
        sets: 3,
        repsRange: '10-12',
      ),
      // Day 2 - LOWER
      Exercise(
        name: 'Goblet Squat',
        muscleGroup: 'Quads',
        defaultDurationSeconds: 120,
        sets: 4,
        repsRange: '10-15',
      ),
      Exercise(
        name: 'RDL',
        muscleGroup: 'Hamstrings',
        defaultDurationSeconds: 120,
        sets: 4,
        repsRange: '10-12',
      ),
      Exercise(
        name: 'Lunges',
        muscleGroup: 'Quads',
        defaultDurationSeconds: 120,
        sets: 3,
        repsRange: '10',
      ),
      Exercise(
        name: 'Calf Raises',
        muscleGroup: 'Calves',
        defaultDurationSeconds: 150,
        sets: 4,
        repsRange: '20',
      ),
      Exercise(
        name: 'Wall Sit',
        muscleGroup: 'Quads',
        defaultDurationSeconds: 45,
        sets: 3,
        repsRange: '1',
      ),
      // Day 3 - PULL
      Exercise(
        name: '1-Arm Row',
        muscleGroup: 'Back',
        defaultDurationSeconds: 120,
        sets: 4,
        repsRange: '10-12',
      ),
      Exercise(
        name: 'Bent Row',
        muscleGroup: 'Back',
        defaultDurationSeconds: 100,
        sets: 3,
        repsRange: '10',
      ),
      Exercise(
        name: 'Bicep Curl',
        muscleGroup: 'Biceps',
        defaultDurationSeconds: 100,
        sets: 3,
        repsRange: '10-12',
      ),
      Exercise(
        name: 'Hammer Curl',
        muscleGroup: 'Biceps',
        defaultDurationSeconds: 100,
        sets: 3,
        repsRange: '10-12',
      ),
      Exercise(
        name: 'Rear Delt Raise',
        muscleGroup: 'Rear Delts',
        defaultDurationSeconds: 90,
        sets: 3,
        repsRange: '12-15',
      ),
      // Day 5 - FULL
      Exercise(
        name: 'Thrusters',
        muscleGroup: 'Full Body',
        defaultDurationSeconds: 120,
        sets: 4,
        repsRange: '10',
      ),
      Exercise(
        name: 'Renegade Row',
        muscleGroup: 'Full Body',
        defaultDurationSeconds: 120,
        sets: 3,
        repsRange: '10',
      ),
      Exercise(
        name: 'Squat to Press',
        muscleGroup: 'Full Body',
        defaultDurationSeconds: 120,
        sets: 3,
        repsRange: '12',
      ),
      Exercise(
        name: 'DB Swings',
        muscleGroup: 'Full Body',
        defaultDurationSeconds: 120,
        sets: 3,
        repsRange: '15',
      ),
      Exercise(
        name: 'Burpees',
        muscleGroup: 'Full Body',
        defaultDurationSeconds: 120,
        sets: 3,
        repsRange: '10-15',
      ),
      // Day 6 - CARDIO + ABS
      Exercise(
        name: 'Cardio',
        muscleGroup: 'Cardio',
        defaultDurationSeconds: 1500, // 25 min
        sets: 1,
        repsRange: '1',
      ),
      Exercise(
        name: 'Plank',
        muscleGroup: 'Abs',
        defaultDurationSeconds: 45,
        sets: 3,
        repsRange: '1',
      ),
      Exercise(
        name: 'Leg Raises',
        muscleGroup: 'Abs',
        defaultDurationSeconds: 90,
        sets: 3,
        repsRange: '15',
      ),
      Exercise(
        name: 'Russian Twists',
        muscleGroup: 'Abs',
        defaultDurationSeconds: 100,
        sets: 3,
        repsRange: '20',
      ),
    ];
  }

  Routine _getDefaultRoutine() {
    final exercises = _getDefaultExercises();
    return Routine(
      name: 'PUSH/PULL/LOWER/FULL/CARDIO',
      dayExercises: {
        1: exercises.where((e) => ['Chest', 'Shoulders', 'Triceps'].contains(e.muscleGroup)).toList(),
        2: exercises.where((e) => ['Quads', 'Hamstrings', 'Calves'].contains(e.muscleGroup)).toList(),
        3: exercises.where((e) => ['Back', 'Biceps', 'Rear Delts'].contains(e.muscleGroup)).toList(),
        4: [], // Rest day
        5: exercises.where((e) => e.muscleGroup == 'Full Body').toList(),
        6: exercises.where((e) => ['Cardio', 'Abs'].contains(e.muscleGroup)).toList(),
        7: [], // Rest day
      },
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

class ExerciseLog {
  final int exerciseId;
  final String exerciseName;
  final int setsCompleted;
  final String repsCompleted;
  final double? weight;
  final int durationSeconds;
  final DateTime completedAt;

  ExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.setsCompleted,
    required this.repsCompleted,
    this.weight,
    required this.durationSeconds,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'setsCompleted': setsCompleted,
    'repsCompleted': repsCompleted,
    'weight': weight,
    'durationSeconds': durationSeconds,
    'completedAt': completedAt.toIso8601String(),
  };

  factory ExerciseLog.fromJson(Map<String, dynamic> json) => ExerciseLog(
    exerciseId: json['exerciseId'],
    exerciseName: json['exerciseName'],
    setsCompleted: json['setsCompleted'],
    repsCompleted: json['repsCompleted'],
    weight: json['weight']?.toDouble(),
    durationSeconds: json['durationSeconds'],
    completedAt: DateTime.parse(json['completedAt']),
  );
}
