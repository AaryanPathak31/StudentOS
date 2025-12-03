import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studentos/domain/models/stats_model.dart';

enum TimerState { idle, running, paused }
enum SessionType { focus, shortBreak, longBreak, custom } // Added custom

class TimerStateModel {
  final int remainingSeconds;
  final int initialDuration;
  final TimerState state;
  final SessionType sessionType;

  TimerStateModel({required this.remainingSeconds, required this.initialDuration, required this.state, required this.sessionType});

  TimerStateModel copyWith({int? remainingSeconds, int? initialDuration, TimerState? state, SessionType? sessionType}) {
    return TimerStateModel(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      initialDuration: initialDuration ?? this.initialDuration,
      state: state ?? this.state,
      sessionType: sessionType ?? this.sessionType,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerStateModel> {
  Timer? _timer;
  
  TimerNotifier() : super(TimerStateModel(
    remainingSeconds: 25 * 60, 
    initialDuration: 25 * 60, 
    state: TimerState.idle, 
    sessionType: SessionType.focus
  ));

  void setSessionType(SessionType type) {
    int minutes = switch (type) {
      SessionType.focus => 25,
      SessionType.shortBreak => 5,
      SessionType.longBreak => 15,
      SessionType.custom => 25, // Default for custom until set
    };
    state = TimerStateModel(
      remainingSeconds: minutes * 60,
      initialDuration: minutes * 60,
      state: TimerState.idle,
      sessionType: type,
    );
  }

  // New method for custom time
  void setCustomTime(int minutes) {
    state = TimerStateModel(
      remainingSeconds: minutes * 60,
      initialDuration: minutes * 60,
      state: TimerState.idle,
      sessionType: SessionType.custom,
    );
  }

  void start() {
    if (state.state == TimerState.running) return;
    state = state.copyWith(state: TimerState.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _completeSession();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(state: TimerState.paused);
  }

  void reset() {
    _timer?.cancel();
    // Reset to the initial duration of the CURRENT session type
    state = TimerStateModel(
      remainingSeconds: state.initialDuration,
      initialDuration: state.initialDuration,
      state: TimerState.idle,
      sessionType: state.sessionType,
    );
  }

  void _completeSession() {
    _timer?.cancel();
    state = state.copyWith(state: TimerState.idle);
    
    final box = Hive.box<FocusSession>('sessions');
    box.add(FocusSession(
      minutes: state.initialDuration ~/ 60,
      timestamp: DateTime.now(),
      type: state.sessionType.toString(),
    ));
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerStateModel>((ref) => TimerNotifier());