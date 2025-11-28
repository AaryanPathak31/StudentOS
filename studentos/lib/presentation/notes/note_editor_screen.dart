import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studentos/domain/models/note_model.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart'; // IMPORT THIS
import 'dart:io';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late Note _note;
  late TextEditingController _titleController;
  
  @override
  void initState() {
    super.initState();
    final box = Hive.box<Note>('notes');
    if (widget.noteId != null && box.containsKey(widget.noteId)) {
      _note = box.get(widget.noteId)!;
    } else {
      _note = Note(
        id: const Uuid().v4(),
        title: "",
        blocks: [NoteBlock(id: const Uuid().v4(), type: 'text', content: '')],
        lastModified: DateTime.now(),
        isStarred: false,
        attachments: [],
      );
    }
    _titleController = TextEditingController(text: _note.title);
  }

  void _save() {
    _note.title = _titleController.text;
    _note.lastModified = DateTime.now();
    Hive.box<Note>('notes').put(_note.id, _note);
  }

  // LOGIC FOR FILE PICKER
  Future<void> _attachFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          _note.attachments.add(result.files.single.path!);
        });
        _save();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not pick file")));
    }
  }

  void _addBlock(String type) {
    setState(() {
      _note.blocks.add(NoteBlock(id: const Uuid().v4(), type: type, content: ''));
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Star Toggle
          IconButton(
            icon: Icon(_note.isStarred ? Icons.star : Icons.star_border, color: Colors.orange),
            onPressed: () {
              setState(() => _note.isStarred = !_note.isStarred);
              _save();
            },
          ),
          // Attachment Button
          IconButton(icon: const Icon(Icons.attach_file), onPressed: _attachFile),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Page Title", border: InputBorder.none),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              onChanged: (_) => _save(),
            ),
          ),
          // Attachments Horizontal List
          if (_note.attachments.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _note.attachments.length,
                itemBuilder: (context, index) {
                  final path = _note.attachments[index];
                  final fileName = path.split('/').last; // Get filename from path
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InputChip(
                      label: Text(fileName, style: const TextStyle(fontSize: 10)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        setState(() => _note.attachments.removeAt(index));
                        _save();
                      },
                    ),
                  );
                },
              ),
            ),
          const Divider(),
          // Blocks List
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = _note.blocks.removeAt(oldIndex);
                  _note.blocks.insert(newIndex, item);
                });
                _save();
              },
              children: [
                for (int i = 0; i < _note.blocks.length; i++)
                  _buildBlockWidget(i, _note.blocks[i])
              ],
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildBlockWidget(int index, NoteBlock block) {
    final key = ValueKey(block.id);
    if (block.type == 'checkbox') {
      return CheckboxListTile(
        key: key,
        value: block.isChecked,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: (v) { setState(() => block.isChecked = v!); _save(); },
        title: TextFormField(
          initialValue: block.content, 
          onChanged: (v) => block.content = v, 
          decoration: const InputDecoration(border: InputBorder.none)
        ),
      );
    } 
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        initialValue: block.content,
        maxLines: null,
        style: block.type == 'h1' ? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold) : const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: block.type == 'h1' ? 'Heading' : 'Type here...',
          prefixIcon: const Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
        ),
        onChanged: (v) { block.content = v; _save(); },
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.text_fields), onPressed: () => _addBlock('text')),
          IconButton(icon: const Icon(Icons.check_box_outlined), onPressed: () => _addBlock('checkbox')),
          IconButton(icon: const Icon(Icons.title), onPressed: () => _addBlock('h1')),
        ],
      ),
    );
  }
}