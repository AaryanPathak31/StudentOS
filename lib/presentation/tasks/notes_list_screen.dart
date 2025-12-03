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
      appBar: AppBar(
        title: const Text('My Notes'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/note_editor'),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Note>('notes').listenable(),
        builder: (context, Box<Note> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined, size: 64, color: Theme.of(context).disabledColor),
                  const SizedBox(height: 16),
                  const Text("No notes created yet."),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push('/note_editor'),
                    child: const Text("Create your first page"),
                  )
                ],
              ),
            );
          }

          // Convert Hive map to list and sort by lastModified (descending)
          final notes = box.values.toList();
          notes.sort((a, b) => b.lastModified.compareTo(a.lastModified));

          return ListView.builder(
            itemCount: notes.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push('/note_editor', extra: note.id),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description_outlined, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                note.title.isEmpty ? "Untitled Page" : note.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Preview content (first text block)
                        Text(
                          _getPreviewText(note),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Edited ${DateFormat.MMMd().format(note.lastModified)}",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            InkWell(
                              onTap: () => _confirmDelete(context, note),
                              child: Icon(Icons.delete_outline, 
                                size: 18, 
                                color: Theme.of(context).colorScheme.error
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getPreviewText(Note note) {
    if (note.blocks.isEmpty) return "No content";
    // Find the first text block that isn't empty
    for (var block in note.blocks) {
      if (block.content.isNotEmpty) {
        return block.content;
      }
    }
    return "Empty note";
  }

  void _confirmDelete(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Note?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              note.delete(); // Hive delete
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}