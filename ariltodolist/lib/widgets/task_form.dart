import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/task.dart';

Future<void> showTaskForm(BuildContext context,
    {Task? task, required Function(Task) onSave}) async {
  final titleController = TextEditingController(text: task?.title ?? "");
  final dueDateController = TextEditingController(text: task?.dueDate ?? "");
  String priority = task?.priority ?? 'low';

  DateTime? selectedDate =
      task != null ? DateTime.tryParse(task.dueDate) : null;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(task == null ? "Tambah Tugas" : "Edit Tugas"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Judul"),
            ),
            SizedBox(height: 8),
            TextField(
              controller: dueDateController,
              readOnly: true,
              decoration: InputDecoration(labelText: "Tanggal"),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  dueDateController.text =
                      picked.toIso8601String().substring(0, 10);
                }
              },
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: priority,
              decoration: InputDecoration(
                labelText: "Prioritas",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: SizedBox.shrink(),
              items: ["low", "medium", "high"].map((e) {
                Color color = (e == "low")
                    ? Colors.green
                    : (e == "medium")
                        ? Colors.orange
                        : Colors.red;
                return DropdownMenuItem<String>(
                  value: e,
                  child: Row(
                    children: [
                      FaIcon(FontAwesomeIcons.flag, size: 14, color: color),
                      SizedBox(width: 8),
                      Text(e),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) priority = value;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Batal")),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.trim().isEmpty ||
                dueDateController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Judul & tanggal wajib diisi")));
              return;
            }
            final newTask = Task(
              id: task?.id,
              title: titleController.text,
              priority: priority,
              dueDate: dueDateController.text,
              isDone: task?.isDone ?? false,
            );
            onSave(newTask);
            Navigator.pop(context);
          },
          child: Text(task == null ? "Tambah" : "Simpan"),
        ),
      ],
    ),
  );
}
