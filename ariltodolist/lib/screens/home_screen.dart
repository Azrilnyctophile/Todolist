import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';
import '../extensions/string_extension.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();
  List<Task> tasks = [];
  String selectedFilter = 'all';
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => isLoading = true);
    try {
      tasks = await api.getTasks();
    } catch (e) {
      tasks = [];
    }
    setState(() => isLoading = false);
  }

  double calculateProgress() {
    if (tasks.isEmpty) return 0;
    int completed = tasks.where((t) => t.isDone).length;
    return completed / tasks.length;
  }

  List<Task> getFilteredTasks() {
    if (selectedFilter == 'all') return tasks;
    return tasks.where((task) => task.priority == selectedFilter).toList();
  }

  List<Task> getDisplayedTasks() {
    final filtered = getFilteredTasks();
    if (searchQuery.isEmpty) return filtered;
    return filtered
        .where((task) => task.title.toLowerCase().contains(searchQuery))
        .toList();
  }

  Future<void> confirmDelete(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Tugas"),
        content: Text("Yakin ingin menghapus '${task.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal"),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            label: Text("Hapus"),
            icon: Icon(Icons.delete),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await api.deleteTask(task.id!);
      fetchTasks();
    }
  }

  Future<void> _logout() async {
    await api.logout();
    await api.removeToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = calculateProgress();
    final displayedTasks = getDisplayedTasks();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TODOLIST",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ),

              // BODY → pakai Expanded agar responsif
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius:
                        const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // Progress Bar
                      const FaIcon(FontAwesomeIcons.chartSimple,
                          color: Colors.purple, size: 28),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Progress: ${(progress * 100).toStringAsFixed(0)}%",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),

                      // Filter Priority
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: ['all', 'low', 'medium', 'high'].map((filter) {
                          return ChoiceChip(
                            label: Text(
                                filter == 'all' ? 'Semua' : filter.capitalize()),
                            selected: selectedFilter == filter,
                            onSelected: (_) =>
                                setState(() => selectedFilter = filter),
                            selectedColor: Colors.deepPurple,
                            labelStyle: TextStyle(
                              color: selectedFilter == filter
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),

                      // Search Field
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Cari tugas...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // ✅ LIST → Expandable, Scrollable
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : displayedTasks.isEmpty
                                ? const Center(child: Text("Tidak ada tugas"))
                                : ListView.builder(
                                    itemCount: displayedTasks.length,
                                    itemBuilder: (context, index) {
                                      final task = displayedTasks[index];
                                      return Card(
                                        elevation: 3,
                                        margin:
                                            const EdgeInsets.symmetric(vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: TaskCard(
                                          task: task,
                                          onToggleComplete: () async {
                                            await api.updateTask(Task(
                                              id: task.id,
                                              title: task.title,
                                              priority: task.priority,
                                              dueDate: task.dueDate,
                                              isDone: !task.isDone,
                                            ));
                                            fetchTasks();
                                          },
                                          onEdit: () async {
                                            await showTaskForm(context,
                                                task: task,
                                                onSave: (updatedTask) async {
                                              await api.updateTask(updatedTask);
                                              fetchTasks();
                                            });
                                          },
                                          onDelete: () => confirmDelete(task),
                                        ),
                                      );
                                    },
                                  ),
                      ),

                      const SizedBox(height: 8),

                      // ✅ FIXED BUTTON (tidak ikut scroll, selalu terlihat)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => showTaskForm(context,
                              onSave: (newTask) async {
                            await api.addTask(newTask);
                            fetchTasks();
                          }),
                          icon: const Icon(Icons.add),
                          label: const Text("Tambah Tugas"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
