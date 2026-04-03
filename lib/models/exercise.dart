class Exercise {
  final int? id;
  final String name;
  final String muscleGroup;
  final int defaultDurationSeconds;
  final String? notes;
  final int sets;
  final String repsRange; // e.g., "10-12"

  Exercise({
    this.id,
    required this.name,
    required this.muscleGroup,
    required this.defaultDurationSeconds,
    this.notes,
    required this.sets,
    required this.repsRange,
  });

  // Convert Exercise to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'muscleGroup': muscleGroup,
    'defaultDurationSeconds': defaultDurationSeconds,
    'notes': notes,
    'sets': sets,
    'repsRange': repsRange,
  };

  // Create Exercise from JSON
  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'],
    name: json['name'],
    muscleGroup: json['muscleGroup'],
    defaultDurationSeconds: json['defaultDurationSeconds'],
    notes: json['notes'],
    sets: json['sets'],
    repsRange: json['repsRange'],
  );

  // Copy with modifications
  Exercise copyWith({
    int? id,
    String? name,
    String? muscleGroup,
    int? defaultDurationSeconds,
    String? notes,
    int? sets,
    String? repsRange,
  }) =>
      Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
        muscleGroup: muscleGroup ?? this.muscleGroup,
        defaultDurationSeconds: defaultDurationSeconds ?? this.defaultDurationSeconds,
        notes: notes ?? this.notes,
        sets: sets ?? this.sets,
        repsRange: repsRange ?? this.repsRange,
      );
}
