import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/theme.dart';
import '../utils/constants.dart';

class TimerWidget extends StatefulWidget {
  final int durationSeconds;
  final bool isRestTimer;
  final VoidCallback onComplete;
  final int ? restDuration;

  const TimerWidget({
    required this.durationSeconds,
    this.isRestTimer = false,
    required this.onComplete,
    this.restDuration,
    Key? key,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _remainingSeconds;
  late Timer _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
  }

  void _startTimer() {
    if (_isRunning) return;
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _stopTimer();
        widget.onComplete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isRestTimer ? 'Rest time complete!' : 'Exercise complete!'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _pauseTimer() {
    _timer.cancel();
    _isRunning = false;
  }

  void _resetTimer() {
    _timer.cancel();
    _isRunning = false;
    setState(() {
      _remainingSeconds = widget.durationSeconds;
    });
  }

  @override
  void dispose() {
    if (_isRunning) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final displayText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isRestTimer ? 'Rest Time' : 'Work Time',
              style: AppStyles.heading3,
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isRestTimer ? AppColors.primary : AppColors.secondary,
              ),
              child: Center(
                child: Text(
                  displayText,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pause' : 'Start'),
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                ),
                FloatingActionButton.extended(
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                  onPressed: _resetTimer,
                  backgroundColor: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
