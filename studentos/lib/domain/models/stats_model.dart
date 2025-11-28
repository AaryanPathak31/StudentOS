import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class FocusSession extends HiveObject {
  @HiveField(0) final int minutes;
  @HiveField(1) final DateTime timestamp;
  @HiveField(2) final String type; // Focus, Break

  FocusSession({required this.minutes, required this.timestamp, required this.type});
}

class FocusSessionAdapter extends TypeAdapter<FocusSession> {
   @override final int typeId = 3;
   @override FocusSession read(BinaryReader reader) => FocusSession(minutes: reader.read(), timestamp: reader.read(), type: reader.read());
   @override void write(BinaryWriter writer, FocusSession obj) { writer.write(obj.minutes); writer.write(obj.timestamp); writer.write(obj.type); }
}