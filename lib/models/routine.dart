import 'exercise.dart';

class Routine {
  final int? id;
  final String name;
  final Map<int, List<Exercise>> dayExercises; // day (1-7) -> list of exercises

  Routine({
    this.id,
    required this.name,
    required this.dayExercises,
  });

  // Convert Routine to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dayExercises': dayExercises.map(
      (day, exercises) => MapEntry(
        day.toString(),
        exercises.map((e) => e.toJson()).toList(),
      ),
    ),
  };

  // Create Routine from JSON
  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
    id: json['id'],
    name: json['name'],
    dayExercises: (json['dayExercises'] as Map).map(
      (day, exercises) => MapEntry(
        int.parse(day),
        List<Exercise>.from(
          (exercises as List).map(
            (e) => Exercise.fromJson(e),
          ),
        ),
      ),
    ),
  );

  List<Exercise> getExercisesForDay(int day) {
    return dayExercises[day] ?? [];
  }

  Routine copyWith({
    int? id,
    String? name,
    Map<int, List<Exercise>>? dayExercises,
  }) =>
      Routine(
        id: id ?? this.id,
        name: name ?? this.name,
        dayExercises: dayExercises ?? this.dayExercises,
      );
}
