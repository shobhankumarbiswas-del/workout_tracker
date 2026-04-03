import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/main_navigation.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WorkoutTrackerApp());
}

class WorkoutTrackerApp extends StatelessWidget {
  const WorkoutTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: MaterialApp(
        title: 'Workout Tracker',
        theme: AppTheme.lightTheme,
        home: const MainNavigation(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
