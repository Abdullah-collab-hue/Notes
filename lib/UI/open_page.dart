import 'package:flutter/material.dart';
import '../DBHelper/db_helper.dart';
import '../Notes_Model/notes.dart';

class ShowContent extends StatefulWidget {
  final Note? note; // 👈 pass note here when editing

  const ShowContent({super.key, this.note});

  @override
  State<ShowContent> createState() => _ShowContentState();
}

class _ShowContentState extends State<ShowContent> {
  final DBHelper dbHelper = DBHelper();

  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();

    // 👇 initialize controllers with existing note data (if editing)
    titleController = TextEditingController(text: widget.note?.title ?? "");
    contentController = TextEditingController(text: widget.note?.content ?? "");
  }

  Future<void> _saveNote() async {
    if (widget.note == null) {
      // Insert new note
      await dbHelper.insertNote({
        'title': titleController.text,
        'content': contentController.text,
      });
    } else {
      // Update existing note
      await dbHelper.updateNote({
        'id': widget.note!.id,
        'title': titleController.text,
        'content': contentController.text,
      });
    }

    if (mounted) Navigator.pop(context, true); // return true to refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white38,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text(
            widget.note == null ? "Add Note" : "Edit Note",
            style:TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w600,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
              style: TextStyle(
                  color: Colors.white,
              ),),
          ),
          ElevatedButton(

            onPressed: _saveNote,
            child: const Text("Save",
              style: TextStyle(
                color: Colors.black
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    hintText: "Title",
                  hintStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  )
                ),
                style: TextStyle(
                    color: Colors.white,
                  fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                    hintText: "Content",
                    hintStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)
                    )
                ),
                maxLines: 20,

                style: TextStyle(
                  color: Colors.white
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
