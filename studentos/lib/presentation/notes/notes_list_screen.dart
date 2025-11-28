import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:studentos/domain/models/note_model.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/note_editor'),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Note>('notes').listenable(),
        builder: (context, Box<Note> box, _) {
          if (box.isEmpty) return const Center(child: Text("No notes yet"));

          final notes = box.values.toList();
          // Sort: Starred first, then date
          notes.sort((a, b) {
            if (a.isStarred && !b.isStarred) return -1;
            if (!a.isStarred && b.isStarred) return 1;
            return b.lastModified.compareTo(a.lastModified);
          });

          return ListView.builder(
            itemCount: notes.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                color: Theme.of(context).cardColor,
                child: ListTile(
                  onTap: () => context.push('/note_editor', extra: note.id),
                  title: Text(
                    note.title.isEmpty ? "Untitled" : note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Edited ${DateFormat.MMMd().format(note.lastModified)}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(note.isStarred ? Icons.star : Icons.star_border, color: Colors.orange),
                        onPressed: () {
                          note.isStarred = !note.isStarred;
                          note.save();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => note.delete(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}