import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Note extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) String title;
  @HiveField(2) List<NoteBlock> blocks;
  @HiveField(3) DateTime lastModified;
  @HiveField(4) bool isStarred; // NEW
  @HiveField(5) List<String> attachments; // NEW: File paths

  Note({
    required this.id,
    required this.title,
    required this.blocks,
    required this.lastModified,
    this.isStarred = false,
    this.attachments = const [],
  });
}

@HiveType(typeId: 2)
class NoteBlock {
  @HiveField(0) String id;
  @HiveField(1) String type;
  @HiveField(2) String content;
  @HiveField(3) bool isChecked;

  NoteBlock({required this.id, required this.type, required this.content, this.isChecked = false});
}

class NoteAdapter extends TypeAdapter<Note> {
   @override final int typeId = 1;
   @override Note read(BinaryReader reader) => Note(
     id: reader.read(), title: reader.read(), blocks: (reader.read() as List).cast<NoteBlock>(), lastModified: reader.read(),
     isStarred: reader.read(), attachments: (reader.read() as List).cast<String>()
   );
   @override void write(BinaryWriter writer, Note obj) { 
     writer.write(obj.id); writer.write(obj.title); writer.write(obj.blocks); writer.write(obj.lastModified);
     writer.write(obj.isStarred); writer.write(obj.attachments);
   }
}

class NoteBlockAdapter extends TypeAdapter<NoteBlock> {
   @override final int typeId = 2;
   @override NoteBlock read(BinaryReader reader) => NoteBlock(id: reader.read(), type: reader.read(), content: reader.read(), isChecked: reader.read());
   @override void write(BinaryWriter writer, NoteBlock obj) { writer.write(obj.id); writer.write(obj.type); writer.write(obj.content); writer.write(obj.isChecked); }
}