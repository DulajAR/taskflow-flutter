import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_dialog.dart';
import '../widgets/taskflow_hero_banner.dart';
import '../services/notification_service.dart';

import 'tasks_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

// ======================================================
// TASKFLOW BRAND COLORS
// ======================================================

const Color taskFlowPrimary = Color(0xFF6855E8);
const Color taskFlowSecondary = Color(0xFF9B8CFF);
const Color taskFlowBackground = Color(0xFFF7F8FC);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  // ======================================================
  // ADD TASK
  // ======================================================

  Future<void> _addTask() async {
    final task = await showDialog<Task>(
      context: context,
      builder: (_) => const TaskDialog(),
    );

    if (task == null || !mounted) return;

    await context.read<TaskProvider>().addTask(task);

    if (!mounted) return;

    _showMessage('Task created successfully!');
  }

  // ======================================================
  // EDIT TASK
  // ======================================================

  Future<void> _editTask(Task task) async {
    final updatedTask = await showDialog<Task>(
      context: context,
      builder: (_) => TaskDialog(task: task),
    );

    if (updatedTask == null || !mounted) return;

    await context.read<TaskProvider>().updateTask(updatedTask);

    if (!mounted) return;

    _showMessage('Task updated successfully!');
  }

  // ======================================================
  // COMPLETE / UNCOMPLETE TASK
  // ======================================================

  Future<void> _toggleTask(Task task, bool? checked) async {
    if (task.id == null) return;

    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      category: task.category,
      priority: task.priority,
      dueDate: task.dueDate,
      isCompleted: checked ?? false,
      createdAt: task.createdAt,
      reminderMinutes: task.reminderMinutes,
    );

    await context.read<TaskProvider>().updateTask(updatedTask);
  }

  // ======================================================
  // DELETE TASK
  // ======================================================

  Future<void> _deleteTask(Task task) async {
    if (task.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<TaskProvider>().deleteTask(task.id!);

    if (!mounted) return;

    _showMessage('Task deleted successfully!');
  }

  // ======================================================
  // TEST NOTIFICATION
  // ======================================================

  Future<void> _testNotification() async {
    await NotificationService.showTestNotification();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ======================================================
  // MAIN SCREEN
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final pages = [
      _HomeDashboard(
        onEdit: _editTask,
        onDelete: _deleteTask,
        onToggle: _toggleTask,
        onViewAll: () {
          setState(() {
            selectedIndex = 1;
          });
        },
      ),
      const TasksScreen(),
      const CalendarScreen(),
      const SettingsScreen(),
    ];

    final titles = ['TaskFlow', 'My Tasks', 'Calendar', 'Settings'];

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.scaffoldBackgroundColor
          : taskFlowBackground,

      // ==================================================
      // APP BAR
      // ==================================================
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 18,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [taskFlowPrimary, taskFlowSecondary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            Text(
              titles[selectedIndex],
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 21,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Test notification',
            onPressed: _testNotification,
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ==================================================
      // PAGES
      // ==================================================
      body: IndexedStack(index: selectedIndex, children: pages),

      // ==================================================
      // ADD TASK BUTTON
      // ==================================================
      floatingActionButton: selectedIndex == 0 || selectedIndex == 1
          ? FloatingActionButton.extended(
              heroTag: 'taskflow_add_task',
              onPressed: _addTask,
              backgroundColor: taskFlowPrimary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'New Task',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,

      // ==================================================
      // BOTTOM NAVIGATION
      // ==================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: scheme.surface,
        indicatorColor: taskFlowPrimary.withValues(alpha: 0.14),
        animationDuration: const Duration(milliseconds: 350),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: taskFlowPrimary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist_rounded, color: taskFlowPrimary),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(
              Icons.calendar_month_rounded,
              color: taskFlowPrimary,
            ),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: taskFlowPrimary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ======================================================
// HOME DASHBOARD
// ======================================================

class _HomeDashboard extends StatefulWidget {
  final Future<void> Function(Task) onEdit;
  final Future<void> Function(Task) onDelete;
  final Future<void> Function(Task, bool?) onToggle;
  final VoidCallback onViewAll;

  const _HomeDashboard({
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    required this.onViewAll,
  });

  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fade = animation;

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(animation);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final scheme = Theme.of(context).colorScheme;

    final tasks = provider.tasks;

    final total = tasks.length;

    final completed = tasks.where((task) => task.isCompleted).length;

    final pending = total - completed;

    final progress = total == 0 ? 0.0 : completed / total;

    final recentTasks = List<Task>.from(tasks)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final visibleTasks = recentTasks.take(5).toList();

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: taskFlowPrimary,
                onRefresh: () async {
                  // Provider updates automatically refresh
                  // the dashboard through ChangeNotifier.
                  await Future<void>.delayed(const Duration(milliseconds: 350));
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                  children: [
                    // ==================================
                    // WELCOME HEADING
                    // ==================================

                    Text(
                      'Make today count ✨',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'A little progress every day adds up.',
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                    // ==================================
                    // DULTRIX HERO IMAGE
                    // ==================================
                    const SizedBox(height: 20),

                    const TaskFlowHeroBanner(),

                    const SizedBox(height: 25),

                    // ==================================
                    // PROGRESS SECTION
                    // ==================================
                    _ProgressCard(
                      total: total,
                      completed: completed,
                      progress: progress,
                    ),

                    const SizedBox(height: 20),

                    // ==================================
                    // SUMMARY CARDS
                    // ==================================
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Completed',
                            value: completed,
                            icon: Icons.task_alt_rounded,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Pending',
                            value: pending,
                            icon: Icons.schedule_rounded,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ==================================
                    // RECENT TASKS HEADING
                    // ==================================
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Recent Tasks',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onViewAll,
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: taskFlowPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ==================================
                    // RECENT TASKS LIST
                    // ==================================
                    if (visibleTasks.isEmpty)
                      const _EmptyTaskCard()
                    else
                      ...visibleTasks.map(
                        (task) => _AnimatedTaskCard(
                          key: ValueKey(task.id ?? task.createdAt),
                          task: task,
                          onToggle: (value) => widget.onToggle(task, value),
                          onEdit: () => widget.onEdit(task),
                          onDelete: () => widget.onDelete(task),
                        ),
                      ),

                    if (total > 5) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: widget.onViewAll,
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                          label: Text('View all $total tasks'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

// ======================================================
// PROGRESS CARD
// ======================================================

class _ProgressCard extends StatelessWidget {
  final int total;
  final int completed;
  final double progress;

  const _ProgressCard({
    required this.total,
    required this.completed,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6855E8), Color(0xFF806DF5), Color(0xFF9B8CFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: taskFlowPrimary.withValues(alpha: 0.2),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Today's Progress",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  '$completed of $total tasks completed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  total == 0
                      ? 'Start by creating your first task.'
                      : progress == 1
                      ? 'Excellent! All tasks completed.'
                      : 'Keep going. You are making progress!',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, child) {
              return SizedBox(
                width: 86,
                height: 86,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: animatedProgress,
                        strokeWidth: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '${(animatedProgress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ======================================================
// SUMMARY CARD
// ======================================================

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 23),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: value.toDouble()),
                  duration: const Duration(milliseconds: 650),
                  builder: (context, animatedValue, child) {
                    return Text(
                      '${animatedValue.round()}',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    );
                  },
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// RECENT TASK CARD
// ======================================================

class _AnimatedTaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnimatedTaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final priorityColor = _getPriorityColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: task.isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.35)
              : scheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              activeColor: taskFlowPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: onToggle,
            ),

            const SizedBox(width: 4),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: task.isCompleted
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const SizedBox(height: 7),

                  Text(
                    '${task.category}'
                    '${task.dueDate == null ? '' : ' • ${DateFormat('MMM d, h:mm a').format(task.dueDate!)}'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${task.priority} Priority',
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              tooltip: 'Edit task',
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_outlined,
                color: taskFlowPrimary,
                size: 20,
              ),
            ),

            IconButton(
              tooltip: 'Delete task',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// EMPTY TASK STATE
// ======================================================

class _EmptyTaskCard extends StatelessWidget {
  const _EmptyTaskCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: taskFlowPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: taskFlowPrimary,
              size: 39,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Ready to get productive?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 8),

          Text(
            'Your tasks will appear here.\n'
            'Tap New Task to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
