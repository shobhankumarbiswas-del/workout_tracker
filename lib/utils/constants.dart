const Map<String, String> muscleGroupEmojis = {
  'Chest': '🦅',
  'Shoulders': '💪',
  'Triceps': '💪',
  'Quads': '🦵',
  'Hamstrings': '🦵',
  'Calves': '🦵',
  'Back': '🔙',
  'Biceps': '💪',
  'Rear Delts': '💪',
  'Full Body': '🔥',
  'Cardio': '🏃',
  'Abs': '🎯',
};

const Map<int, String> dayNames = {
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
  7: 'Sunday',
};

const Map<int, String> shortDayNames = {
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

List<String> getStreamStatistics(List<double> weights) {
  if (weights.isEmpty) return [];
  weights.sort();
  return [
    'Max: ${weights.last.toStringAsFixed(1)} kg',
    'Min: ${weights.first.toStringAsFixed(1)} kg',
    'Avg: ${(weights.reduce((a, b) => a + b) / weights.length).toStringAsFixed(1)} kg',
  ];
}

String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  if (minutes == 0) return '${remainingSeconds}s';
  if (remainingSeconds == 0) return '${minutes}m';
  return '${minutes}m ${remainingSeconds}s';
}

String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateToCheck = DateTime(date.year, date.month, date.day);

  if (dateToCheck == today) return 'Today';
  if (dateToCheck == yesterday) return 'Yesterday';

  return '${date.day}/${date.month}/${date.year}';
}
