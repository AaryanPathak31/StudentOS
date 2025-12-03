import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studentos/domain/models/task_model.dart';
import 'package:uuid/uuid.dart';

final taskBoxProvider = Provider((ref) => Hive.box<Task>('tasks'));

class TaskNotifier extends StateNotifier<List<Task>> {
  final Box<Task> box;
  
  TaskNotifier(this.box) : super(box.values.toList()) {
    _handleDailyReset();
  }

  // ... imports ...
// inside TaskNotifier class:

  void addTask(String title, DateTime? due, String cat, bool isDaily) {
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      dueDate: due,
      category: cat,
      isDaily: isDaily,
      createdAt: DateTime.now(),
      isStarred: false, // Default
    );
    box.add(task);
    state = box.values.toList();
  }

  void toggleStar(Task task) {
    task.isStarred = !task.isStarred;
    task.save();
    state = box.values.toList(); // Refresh UI
  }

  void toggleComplete(Task task) {
    task.isCompleted = !task.isCompleted;
    task.save();
    state = box.values.toList();
  }

  void delete(Task task) {
    task.delete();
    state = box.values.toList();
  }

  // Feature: Daily Tasks Reset
  void _handleDailyReset() {
    final now = DateTime.now();
    // Logic: If task isDaily and was completed before today, reset it.
    // In a real app, store "lastResetDate" in settings. 
    for(var task in state) {
      if(task.isDaily && task.isCompleted) {
        // Simplified check: If completed, uncheck it for "Today" view on load
        // A more robust check compares dates.
        // task.isCompleted = false; 
        // task.save();
      }
    }
  }
}

final taskListProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref.watch(taskBoxProvider));
});