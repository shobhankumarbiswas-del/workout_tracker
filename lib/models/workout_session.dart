class ExerciseLog {
  final int exerciseId;
  final String exerciseName;
  final int setsCompleted;
  final String repsCompleted; // e.g., "12, 10, 8"
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

class WorkoutSession {
  final int? id;
  final int routineId;
  final String routineName;
  final DateTime date;
  final List<ExerciseLog> exercises;
  final bool completed;
  final int totalDurationSeconds;

  WorkoutSession({
    this.id,
    required this.routineId,
    required this.routineName,
    required this.date,
    required this.exercises,
    this.completed = false,
    required this.totalDurationSeconds,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'routineId': routineId,
    'routineName': routineName,
    'date': date.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'completed': completed,
    'totalDurationSeconds': totalDurationSeconds,
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    id: json['id'],
    routineId: json['routineId'],
    routineName: json['routineName'],
    date: DateTime.parse(json['date']),
    exercises: List<ExerciseLog>.from(
      (json['exercises'] as List).map((e) => ExerciseLog.fromJson(e)),
    ),
    completed: json['completed'],
    totalDurationSeconds: json['totalDurationSeconds'],
  );

  WorkoutSession copyWith({
    int? id,
    int? routineId,
    String? routineName,
    DateTime? date,
    List<ExerciseLog>? exercises,
    bool? completed,
    int? totalDurationSeconds,
  }) =>
      WorkoutSession(
        id: id ?? this.id,
        routineId: routineId ?? this.routineId,
        routineName: routineName ?? this.routineName,
        date: date ?? this.date,
        exercises: exercises ?? this.exercises,
        completed: completed ?? this.completed,
        totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      );
}
