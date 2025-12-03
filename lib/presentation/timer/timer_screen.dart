import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studentos/providers/timer_provider.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Timer')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Session Type Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChip(context, notifier, timerState, SessionType.focus, "Focus 25"),
                const SizedBox(width: 8),
                _buildChip(context, notifier, timerState, SessionType.shortBreak, "Short 5"),
                const SizedBox(width: 8),
                _buildChip(context, notifier, timerState, SessionType.longBreak, "Long 15"),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text("Custom"),
                  backgroundColor: timerState.sessionType == SessionType.custom 
                      ? theme.colorScheme.primary 
                      : null,
                  labelStyle: TextStyle(
                      color: timerState.sessionType == SessionType.custom 
                      ? theme.colorScheme.onPrimary 
                      : null
                  ),
                  onPressed: () => _showCustomTimeDialog(context, notifier),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          
          // The Clock
          Text(
            _formatTime(timerState.remainingSeconds),
            style: const TextStyle(
              fontSize: 90, 
              fontWeight: FontWeight.w300, 
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          
          const SizedBox(height: 20),
          Text(
            timerState.state == TimerState.running ? "STAY FOCUSED" : "READY TO START?", 
            style: TextStyle(
              letterSpacing: 4, 
              color: theme.colorScheme.primary, 
              fontWeight: FontWeight.bold
            )
          ),
          
          const SizedBox(height: 60),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.large(
                heroTag: 'play',
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                onPressed: timerState.state == TimerState.running 
                  ? notifier.pause 
                  : notifier.start,
                child: Icon(timerState.state == TimerState.running ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: 30),
              FloatingActionButton(
                heroTag: 'reset',
                onPressed: notifier.reset,
                backgroundColor: theme.cardColor,
                foregroundColor: theme.iconTheme.color,
                child: const Icon(Icons.refresh),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, TimerNotifier notifier, TimerStateModel state, SessionType type, String label) {
    final isSelected = state.sessionType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (v) {
        if(v) notifier.setSessionType(type);
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(color: isSelected ? Theme.of(context).colorScheme.onPrimary : null),
    );
  }

  void _showCustomTimeDialog(BuildContext context, TimerNotifier notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Custom Duration"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Minutes",
            hintText: "e.g. 45",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(controller.text);
              if (minutes != null && minutes > 0) {
                notifier.setCustomTime(minutes);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Set Timer"),
          ),
        ],
      ),
    );
  }
}