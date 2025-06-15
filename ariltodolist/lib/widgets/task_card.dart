import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/task.dart';
import '../extensions/string_extension.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              leading: IconButton(
                icon: FaIcon(
                  task.isDone
                      ? FontAwesomeIcons.solidCircleCheck
                      : FontAwesomeIcons.circle,
                  color: task.isDone ? Colors.green : Colors.grey,
                ),
                onPressed: onToggleComplete,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.penToSquare, color: Colors.amber),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.trash, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.calendarAlt, size: 14, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(task.dueDate,
                          style: const TextStyle(fontSize: 13, color: Colors.blue)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: task.priority == "low"
                        ? Colors.green[100]
                        : task.priority == "medium"
                            ? Colors.orange[100]
                            : Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(FontAwesomeIcons.flag,
                          size: 12,
                          color: task.priority == "low"
                              ? Colors.green
                              : task.priority == "medium"
                                  ? Colors.orange
                                  : Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        task.priority.capitalize(),
                        style: TextStyle(
                            fontSize: 13,
                            color: task.priority == "low"
                                ? Colors.green[800]
                                : task.priority == "medium"
                                    ? Colors.orange[800]
                                    : Colors.red[800]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
