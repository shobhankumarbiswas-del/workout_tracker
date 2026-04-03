# Workout Tracker - Flutter App

A Flutter application for tracking your workout routines with customizable exercises, timers, and progress analytics.

This is a vibe coded app
## Features

✨ **Core Features:**
- 🏋️ **Pre-loaded 5-day workout split** (Push/Pull/Lower/Full/Cardio)
- ⏱️ **Configurable timers** for exercises and rest periods with audio alerts
- 📊 **Exercise tracking** with sets, reps, and weight logging
- 🎯 **Daily workout dashboard** with quick workout start
- 💪 **Progress analytics** with streak tracking and workout history

🔧 **Customization:**
- ✏️ Add, edit, and delete custom exercises
- 🔄 Create and manage multiple workout routines
- ⏱️ Set default durations for exercises
- 💾 Full routine customization with save/load

📈 **Analytics:**
- 📅 Workout calendar view
- 🔥 Streak tracking (consecutive workout days)
- 📊 Weekly statistics
- 📝 Complete workout history

## Getting Started

### Prerequisites

- Flutter SDK (2.19.0 or higher)
- Dart SDK
- Android Studio, Xcode, or VS Code with Flutter extensions

### Installation

1. **Clone or download the project**
   ```bash
   cd workout_tracker
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Project Structure

```
workout_tracker/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── models/
│   │   ├── exercise.dart              # Exercise data model
│   │   ├── routine.dart               # Routine data model
│   │   └── workout_session.dart       # Workout session data model
│   ├── database/
│   │   └── db_helper.dart             # SQLite database operations
│   ├── providers/
│   │   ├── exercise_provider.dart     # Exercise state management
│   │   ├── routine_provider.dart      # Routine state management
│   │   └── workout_provider.dart      # Workout session state management
│   ├── screens/
│   │   ├── main_navigation.dart       # Navigation hub
│   │   ├── dashboard_screen.dart      # Home dashboard
│   │   ├── active_workout_screen.dart # Active workout tracker
│   │   ├── exercise_manager_screen.dart # Exercise management
│   │   ├── progress_screen.dart       # Progress & analytics
│   │   └── settings_screen.dart       # App settings & routine selection
│   ├── widgets/
│   │   ├── timer_widget.dart          # Countdown timer component
│   │   ├── exercise_card.dart         # Exercise display card
│   │   └── stats_card.dart            # Statistics display card
│   └── utils/
│       ├── theme.dart                 # App colors & themes
│       └── constants.dart             # App constants & utilities
├── pubspec.yaml                       # Dependencies
├── analysis_options.yaml              # Lint rules
└── README.md                          # This file
```

## Dependencies

- **provider** (^6.0.0) - State management
- **sqflite** (^2.3.0) - SQLite database
- **fl_chart** (^0.64.0) - Charts & graphs
- **just_audio** (^0.9.32) - Audio playback for timers
- **flutter_local_notifications** (^14.1.0) - Local notifications

## Usage

### Start a Workout
1. Go to the **Dashboard** tab
2. View today's scheduled exercises
3. Tap "Start Workout" to begin

### Use the Timer
1. Select an exercise from the list
2. Use the timer for work and rest periods
3. Log your weight/reps after completing the exercise
4. Move to the next exercise

### Manage Exercises
1. Go to the **Exercises** tab
2. Add new exercises, edit existing ones, or delete unused ones
3. Set muscle group, duration, sets, and rep ranges

### Track Progress
1. Go to the **Progress** tab
2. View your workout streak and total workouts
3. Review workout history and details

### Customize Settings
1. Go to the **Settings** tab
2. Adjust default rest duration
3. Select active routine or create custom ones

## Database Schema

### Exercises Table
- `id` (INTEGER PRIMARY KEY)
- `name` (TEXT)
- `muscleGroup` (TEXT)
- `defaultDurationSeconds` (INTEGER)
- `notes` (TEXT)
- `sets` (INTEGER)
- `repsRange` (TEXT)

### Routines Table
- `id` (INTEGER PRIMARY KEY)
- `name` (TEXT)
- `dayExercisesJson` (TEXT - JSON encoded)
- `createdAt` (TIMESTAMP)

### Workout Sessions Table
- `id` (INTEGER PRIMARY KEY)
- `routineId` (INTEGER FOREIGN KEY)
- `routineName` (TEXT)
- `date` (TEXT)
- `exercisesJson` (TEXT - JSON encoded)
- `completed` (INTEGER)
- `totalDurationSeconds` (INTEGER)

## Default Workout Split

### Day 1 - PUSH 🔥
- Floor Press 4×10-12
- Shoulder Press 4×8-12
- Lateral Raise 3×12-15
- Chest Fly 3×10-12
- Tricep Extension 3×10-12

### Day 2 - LOWER 🦵
- Goblet Squat 4×10-15
- RDL 4×10-12
- Lunges 3×10/leg
- Calf Raises 4×20
- Wall Sit 3×30-60s

### Day 3 - PULL 💪
- 1-Arm Row 4×10-12
- Bent Row 3×10
- Bicep Curl 3×10-12
- Hammer Curl 3×10-12
- Rear Delt Raise 3×12-15

### Day 4 - REST ☀️

### Day 5 - FULL 🔥
- Thrusters 4×10
- Renegade Row 3×10
- Squat to Press 3×12
- DB Swings 3×15
- Burpees 3×10-15

### Day 6 - CARDIO + ABS 🧠
- Cardio 25-30 min
- Plank 3×45s
- Leg Raises 3×15
- Russian Twists 3×20

### Day 7 - REST ☀️

## Key Features Explained

### Timer Widget
- Dual-mode timer: Work time & Rest time
- Start/Pause/Reset controls
- Audio notification on completion
- Visual countdown display

### Exercise Management
- Add custom exercises with muscle groups
- Edit exercise parameters anytime
- Delete unused exercises
- Pre-loaded default exercises

### State Management
- Provider pattern for clean architecture
- Separate providers for exercises, routines, and workouts
- Reactive UI updates on data changes

### Database
- Local SQLite storage (no internet required)
- JSON encoding for complex data (day-to-exercises mapping)
- Auto-initialization with default data
- CRUD operations for all models

## Building for Release

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

**Error: "No active workout"**
- Make sure you've selected/created a routine in Settings
- Tap "Start Workout" from the Dashboard

**Timer not working**
- Check sound permissions in app settings
- Make sure device isn't in silent mode

**Data not persisting**
- Clear app cache: Go to Settings > Apps > Workout Tracker > Storage > Clear Cache
- Reinstall the app

## Future Enhancements

- 📱 Cloud sync across devices
- 👥 Share routines with friends
- 📊 Advanced analytics with charts
- 🔔 Workout reminders & notifications
- 🌙 Dark mode support
- 📧 Export workout data as PDF
- 🎥 Exercise video tutorials

## Contributing

Feel free to fork, modify, and improve this project!

## License

This project is open source and available under the MIT License.

## Support

For issues, questions, or suggestions, please create an issue in the repository.

---

**Happy Training! 💪**
