import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:studentos/domain/models/task_model.dart';
import 'package:studentos/providers/task_provider.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskListProvider);
    
    // Filter tasks
    final pendingTasks = allTasks.where((t) => !t.isCompleted).toList();
    // Sort pending: Daily first, then by date
    pendingTasks.sort((a, b) {
      if (a.isDaily && !b.isDaily) return -1;
      if (!a.isDaily && b.isDaily) return 1;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    final completedTasks = allTasks.where((t) => t.isCompleted).toList();
    completedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "To-Do"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(pendingTasks, isPending: true),
          _buildTaskList(completedTasks, isPending: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        label: const Text("Add Task"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, {required bool isPending}) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPending ? Icons.check_circle_outline : Icons.task_alt, 
                 size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(isPending ? "All caught up!" : "No completed tasks yet.",
                 style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 10),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            ref.read(taskListProvider.notifier).delete(task);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task deleted')),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: Checkbox(
                value: task.isCompleted,
                shape: const CircleBorder(),
                onChanged: (val) {
                  ref.read(taskListProvider.notifier).toggleComplete(task);
                },
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description.isNotEmpty)
                    Text(task.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (task.isDaily)
                        _buildTag(context, "Daily Routine", Colors.purple),
                      if (task.isDaily) const SizedBox(width: 8),
                      if (task.category.isNotEmpty)
                        _buildTag(context, task.category, Colors.blue),
                      const Spacer(),
                      if (task.dueDate != null)
                        Text(
                          DateFormat('MMM d, h:mm a').format(task.dueDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddTaskSheet(),
    );
  }
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  const _AddTaskSheet();

  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  bool _isDaily = false;
  String _category = "Study";

  final List<String> _categories = ["Study", "Personal", "Project", "Exam", "Health"];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("New Task", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: "Description (Optional)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null && mounted) {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        setState(() {
                          _dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: "Due Date", border: OutlineInputBorder()),
                    child: Text(
                      _dueDate == null ? "Select Date" : DateFormat('MMM d, HH:mm').format(_dueDate!),
                      style: TextStyle(color: _dueDate == null ? Colors.grey : null),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text("Daily Routine"),
            subtitle: const Text("Resets automatically every day"),
            value: _isDaily,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _isDaily = val),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isEmpty) return;
              ref.read(taskListProvider.notifier).addTask(
                _titleController.text,
                _dueDate,
                _category,
                _isDaily,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text("Create Task"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}