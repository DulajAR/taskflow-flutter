import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_dialog.dart';
import 'home_screen.dart' show taskFlowPrimary;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

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
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(animation);

    _controller.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

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

  Future<void> _deleteTask(Task task) async {
    if (task.id == null) return;

    final confirmed = await showDialog<bool>(
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

    if (confirmed != true || !mounted) return;

    await context.read<TaskProvider>().deleteTask(task.id!);

    if (!mounted) return;

    _showMessage('Task deleted successfully!');
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

  void _clearFilters(TaskProvider provider) {
    _searchController.clear();
    provider.clearFilters();
  }

  Color _priorityColor(String priority) {
    switch (priority) {
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
    final provider = context.watch<TaskProvider>();
    final scheme = Theme.of(context).colorScheme;

    final tasks = provider.filteredTasks;
    final total = provider.totalTasks;
    final completed = provider.tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organize your day',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Stay on top of everything that matters.',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Gradient overview
                          _TaskOverview(
                            total: total,
                            completed: completed,
                            pending: pending,
                          ),

                          const SizedBox(height: 20),

                          // Search
                          TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              provider.setSearchQuery(value);
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: 'Search your tasks...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search',
                                      onPressed: () {
                                        _searchController.clear();
                                        provider.setSearchQuery('');
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                              filled: true,
                              fillColor: scheme.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(17),
                                borderSide: BorderSide(
                                  color: scheme.outlineVariant,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(17),
                                borderSide: BorderSide(
                                  color: scheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Status filter chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final status in [
                                  'All',
                                  'Pending',
                                  'Completed',
                                ])
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(status),
                                      avatar: Icon(
                                        status == 'All'
                                            ? Icons.apps_rounded
                                            : status == 'Pending'
                                            ? Icons.schedule_rounded
                                            : Icons.task_alt_rounded,
                                        size: 17,
                                        color: provider.statusFilter == status
                                            ? taskFlowPrimary
                                            : scheme.onSurfaceVariant,
                                      ),
                                      selected: provider.statusFilter == status,
                                      selectedColor: taskFlowPrimary.withValues(
                                        alpha: 0.15,
                                      ),
                                      showCheckmark: false,
                                      onSelected: (_) {
                                        provider.setStatusFilter(status);
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Priority and category
                          Row(
                            children: [
                              Expanded(
                                child: _FilterDropdown(
                                  label: 'Priority',
                                  value: provider.priorityFilter,
                                  values: const [
                                    'All',
                                    'Low',
                                    'Medium',
                                    'High',
                                  ],
                                  onChanged: (value) {
                                    provider.setPriorityFilter(value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _FilterDropdown(
                                  label: 'Category',
                                  value: provider.categoryFilter,
                                  values: const [
                                    'All',
                                    'Study',
                                    'Work',
                                    'Personal',
                                    'Other',
                                  ],
                                  onChanged: (value) {
                                    provider.setCategoryFilter(value);
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Sort and clear
                          Row(
                            children: [
                              Expanded(
                                child: _FilterDropdown(
                                  label: 'Sort by',
                                  value: provider.sortOption,
                                  values: const [
                                    'Newest',
                                    'Oldest',
                                    'Due Date',
                                    'Alphabetical',
                                    'Priority',
                                  ],
                                  onChanged: (value) {
                                    provider.setSortOption(value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: provider.hasActiveFilters
                                    ? () => _clearFilters(provider)
                                    : null,
                                icon: const Icon(
                                  Icons.filter_alt_off_rounded,
                                  size: 18,
                                ),
                                label: const Text('Clear'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Text(
                                'Your Tasks',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const Spacer(),
                              Text(
                                '${tasks.length} of $total',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  if (provider.isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (tasks.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyTasks(
                        hasTasks: total > 0,
                        hasFilters: provider.hasActiveFilters,
                        onClear: () => _clearFilters(provider),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                      sliver: SliverList.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return _TaskCard(
                            key: ValueKey(task.id ?? task.createdAt),
                            task: task,
                            priorityColor: _priorityColor(task.priority),
                            onToggle: (value) => _toggleTask(task, value),
                            onEdit: () => _editTask(task),
                            onDelete: () => _deleteTask(task),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// GRADIENT TASK OVERVIEW
// =====================================================

class _TaskOverview extends StatelessWidget {
  final int total;
  final int completed;
  final int pending;

  const _TaskOverview({
    required this.total,
    required this.completed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _OverviewStat(
              label: 'Total',
              value: total,
              icon: Icons.list_alt_rounded,
            ),
          ),
          Container(width: 1, height: 45, color: Colors.white24),
          Expanded(
            child: _OverviewStat(
              label: 'Completed',
              value: completed,
              icon: Icons.task_alt_rounded,
            ),
          ),
          Container(width: 1, height: 45, color: Colors.white24),
          Expanded(
            child: _OverviewStat(
              label: 'Pending',
              value: pending,
              icon: Icons.schedule_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _OverviewStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 7),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value.toDouble()),
          duration: const Duration(milliseconds: 600),
          builder: (context, animatedValue, child) {
            return Text(
              '${animatedValue.round()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            );
          },
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

// =====================================================
// MODERN FILTER DROPDOWN
// =====================================================

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      items: values
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}

// =====================================================
// MODERN TASK CARD
// =====================================================

class _TaskCard extends StatelessWidget {
  final Task task;
  final Color priorityColor;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    super.key,
    required this.task,
    required this.priorityColor,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
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
            color: Colors.black.withValues(alpha: 0.035),
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
            const SizedBox(width: 3),
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
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: priorityColor,
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

// =====================================================
// EMPTY TASK STATE
// =====================================================

class _EmptyTasks extends StatelessWidget {
  final bool hasTasks;
  final bool hasFilters;
  final VoidCallback onClear;

  const _EmptyTasks({
    required this.hasTasks,
    required this.hasFilters,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: taskFlowPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 42,
                color: taskFlowPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasTasks ? 'No matching tasks' : 'Your list is empty',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              hasTasks
                  ? 'Try adjusting your search or filters.'
                  : 'Create a task to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
