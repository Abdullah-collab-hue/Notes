import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../DBHelper/db_helper.dart';
import '../Notes_Model/notes.dart';
import 'open_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final DBHelper dbHelper = DBHelper();
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final data = await dbHelper.getNotes();
    setState(() {
      notes = data.map((e) => Note.fromMap(e)).toList();
    });
  }
  final List<Color> noteColors = [
    Colors.amber.shade200,
    Colors.green.shade200,
    Colors.blue.shade200,
    Colors.orange.shade200,
    Colors.pink.shade200,
    Colors.purple.shade200,
  ];

  // void _showNoteDialog({Note? note}) {
  //   final titleController = TextEditingController(text: note?.title ?? "");
  //   final contentController = TextEditingController(text: note?.content ?? "");
  //
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: Text(note == null ? "Add Note" : "Edit Note"),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(controller: titleController, decoration: const InputDecoration(hintText: "Title")),
  //           TextField(controller: contentController, decoration: const InputDecoration(hintText: "Content")),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Cancel"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             if (note == null) {
  //               await dbHelper.insertNote({
  //                 'title': titleController.text,
  //                 'content': contentController.text,
  //               });
  //             } else {
  //               await dbHelper.updateNote({
  //                 'id': note.id,
  //                 'title': titleController.text,
  //                 'content': contentController.text,
  //               });
  //             }
  //             Navigator.pop(context);
  //             _loadNotes();
  //           },
  //           child: const Text("Save"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _deleteNote(int? id) async {
    if (id == null) return; // guard for null ids
    await dbHelper.deleteNote(id); // DB call requires non-null int
    setState(() {
      notes.removeWhere((n) => n.id == id); // update UI
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white38,
      appBar: AppBar(
          title: const Text("Notes",
            style:TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w600,
            ) ,),
        backgroundColor: Colors.black45,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MasonryGridView.count(
          crossAxisCount: 2, // two cards per row
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            final color = noteColors[index % noteColors.length];

            return GestureDetector(
              onTap: () {
                // Navigate to ShowContent page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowContent(note: note),
                  ),
                ).then((_) {
                  _loadNotes(); // refresh when coming back
                });
              },
              onLongPress: () {
                // Show confirmation dialog before deleting
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Note"),
                    content: const Text("Are you sure you want to delete this note?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text(
                            "Cancel",
                             style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _deleteNote(note.id); // call your delete function
                          Navigator.of(ctx).pop();
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note.content,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 6, // optional, prevents overflow
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> ShowContent() )
          ).then((_) {
            _loadNotes(); // refresh when coming back
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
