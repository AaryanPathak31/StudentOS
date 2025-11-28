import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) String title;
  @HiveField(2) String description;
  @HiveField(3) DateTime? dueDate;
  @HiveField(4) bool isCompleted;
  @HiveField(5) String category;
  @HiveField(6) bool isDaily;
  @HiveField(7) DateTime createdAt;
  @HiveField(8) bool isStarred; // NEW

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
    this.category = 'General',
    this.isDaily = false,
    required this.createdAt,
    this.isStarred = false,
  });
}

class TaskAdapter extends TypeAdapter<Task> {
  @override final int typeId = 0;
  @override
  Task read(BinaryReader reader) {
    return Task(
      id: reader.read(),
      title: reader.read(),
      description: reader.read(),
      dueDate: reader.read(),
      isCompleted: reader.read(),
      category: reader.read(),
      isDaily: reader.read(),
      createdAt: reader.read(),
      isStarred: reader.read(), // Read new field
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.description);
    writer.write(obj.dueDate);
    writer.write(obj.isCompleted);
    writer.write(obj.category);
    writer.write(obj.isDaily);
    writer.write(obj.createdAt);
    writer.write(obj.isStarred); // Write new field
  }
}