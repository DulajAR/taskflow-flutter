import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';
import '../widgets/task_dialog.dart';
import 'tasks_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

const Color taskFlowPrimary = Color(0xFF6855E8);
const Color taskFlowBackground = Color(0xFFF7F8FC);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  // CREATE TASK
  Future<void> _addTask() async {
    final task = await showDialog<Task>(
      context: context,
      builder: (_) => const TaskDialog(),
    );

    if (task == null || !mounted) return;

    await context.read<TaskProvider>().addTask(task);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task added successfully!')));
  }

  // EDIT TASK
  Future<void> _editTask(Task task) async {
    final updatedTask = await showDialog<Task>(
      context: context,
      builder: (_) => TaskDialog(task: task),
    );

    if (updatedTask == null || !mounted) return;

    await context.read<TaskProvider>().updateTask(updatedTask);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task updated successfully!')));
  }

  // COMPLETE / UNCOMPLETE TASK
  Future<void> _toggleTask(Task task, bool? value) async {
    if (task.id == null) return;

    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      category: task.category,
      priority: task.priority,
      dueDate: task.dueDate,
      isCompleted: value ?? false,
      createdAt: task.createdAt,
      reminderMinutes: task.reminderMinutes,
    );

    await context.read<TaskProvider>().updateTask(updatedTask);
  }

  // DELETE TASK
  Future<void> _deleteTask(Task task) async {
    if (task.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Delete "${task.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await context.read<TaskProvider>().deleteTask(task.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task deleted successfully!')));
  }

  // TEST NOTIFICATION
  Future<void> _testNotification() async {
    try {
      await NotificationService.showTestNotification();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Test notification sent!')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Notification error: $error')));
    }
  }

  String get _pageTitle {
    switch (selectedIndex) {
      case 1:
        return 'My Tasks';
      case 2:
        return 'Calendar';
      case 3:
        return 'Settings';
      default:
        return 'TaskFlow';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeDashboard(
        onAddTask: _addTask,
        onEditTask: _editTask,
        onToggleTask: _toggleTask,
        onDeleteTask: _deleteTask,
        onViewAllTasks: () {
          setState(() => selectedIndex = 1);
        },
      ),
      const TasksScreen(),
      const CalendarScreen(),
      const SettingsScreen(),
    ];

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          _pageTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (selectedIndex == 0)
            IconButton(
              tooltip: 'Test notifications',
              onPressed: _testNotification,
              icon: const Icon(Icons.notifications_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: selectedIndex, children: pages),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: taskFlowPrimary,
              foregroundColor: Colors.white,
              onPressed: _addTask,
              tooltip: 'Add task',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// HOME DASHBOARD
// =====================================================

class _HomeDashboard extends StatelessWidget {
  final Future<void> Function() onAddTask;
  final Future<void> Function(Task task) onEditTask;
  final Future<void> Function(Task task, bool? value) onToggleTask;
  final Future<void> Function(Task task) onDeleteTask;
  final VoidCallback onViewAllTasks;

  const _HomeDashboard({
    required this.onAddTask,
    required this.onEditTask,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onViewAllTasks,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tasks = provider.tasks;
    final completed = tasks.where((task) => task.isCompleted).length;
    final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;
    final pending = tasks.length - completed;

    return SafeArea(
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Hello, Welcome Back!',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Here is your productivity overview.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 25),

                // PROGRESS CARD
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: taskFlowPrimary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today's Progress",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$completed of ${tasks.length} tasks completed',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$pending tasks remaining',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 65,
                        height: 65,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                              strokeWidth: 7,
                            ),
                            Center(
                              child: Text(
                                '${(progress * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // TASK HEADING
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: onViewAllTasks,
                      child: const Text('View all'),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // EMPTY STATE
                if (tasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 55,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No tasks yet!',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create your first task to get started.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: onAddTask,
                          icon: const Icon(Icons.add),
                          label: const Text('Create a task'),
                        ),
                      ],
                    ),
                  )
                else
                  ...tasks.take(5).map((task) {
                    final isCompleted = task.isCompleted;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isCompleted,
                            activeColor: taskFlowPrimary,
                            onChanged: (value) {
                              onToggleTask(task, value);
                            },
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isCompleted
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  task.dueDate == null
                                      ? task.category
                                      : '${task.category} • '
                                            '${DateFormat('MMM d, h:mm a').format(task.dueDate!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            task.priority,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: taskFlowPrimary,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit task',
                            onPressed: () => onEditTask(task),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: taskFlowPrimary,
                              size: 20,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete task',
                            onPressed: () => onDeleteTask(task),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                if (tasks.length > 5)
                  TextButton(
                    onPressed: onViewAllTasks,
                    child: Text('View all ${tasks.length} tasks'),
                  ),
              ],
            ),
    );
  }
}
