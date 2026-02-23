import 'package:flutter/material.dart';

void main() {
  runApp(const ToDoApp());
}

/// A StatelessWidget functioning as the root of the app.
/// StatelessWidget is used here because the overall theme and configuration do not change.
class ToDoApp extends StatelessWidget {
  // Utilizing the const constructor ensures the widget isn't rebuilt unnecessarily
  const ToDoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Optimized To-Do',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        // Enables Material 3 for modern look
        useMaterial3: true,
      ),
      home: const ToDoScreen(),
    );
  }
}

/// A simple data model.
class Task {
  final String id;
  final String title;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

/// StatefulWidget representing the main screen.
/// StatefulWidget is required because the list of tasks will change over time, requiring UI updates.
class ToDoScreen extends StatefulWidget {
  const ToDoScreen({Key? key}) : super(key: key);

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  // Application State
  final List<Task> _tasks = [];
  final TextEditingController _textController = TextEditingController();

  /// Efficient use of setState():
  /// This function explicitly mutates local state inside the setState callback.
  /// Flutter will mark this State object as "dirty" and schedule a build for this subtree.
  void _addTask(String title) {
    if (title.trim().isEmpty) return;

    setState(() {
      _tasks.add(Task(
        id: DateTime.now().toString(),
        title: title.trim(),
      ));
    });
    _textController.clear();
  }

  void _toggleTask(String id) {
    setState(() {
      final task = _tasks.firstWhere((t) => t.id == id);
      task.isCompleted = !task.isCompleted;
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold UI
    return Scaffold(
      appBar: AppBar(
        // 'const' prevents the AppBar and its contents from rebuilding needlessly during setState
        title: const Text('Tasks'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Input Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'New Task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _addTask,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _addTask(_textController.text),
                  // 'const' used here since the Icon is static
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          
          // List Section
          Expanded(
            // ListView.builder builds items instantly on demand as they scroll into view.
            // This represents a dramatic performance improvement over rendering all widgets at once.
            child: _tasks.isEmpty
                ? const Center(
                    child: Text('No tasks yet! Add one above.'),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      // Abstracting the Task item into a separate StatelessWidget.
                      // Keeps the tree modular and the build method highly maintainable.
                      return TaskTile(
                        task: task,
                        onToggle: () => _toggleTask(task.id),
                        onDelete: () => _deleteTask(task.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// StatelessWidget to render an individual task item.
/// Extracts UI logic to separate widgets, adhering to best practices for a clean structure.
class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  // Key provided for list re-ordering optimizations internally by the element tree.
  const TaskTile({
    Key? key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
