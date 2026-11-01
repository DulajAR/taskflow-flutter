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

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Toggle task completion
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

  // Edit task
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

  // Delete task
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await context.read<TaskProvider>().deleteTask(task.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Task deleted')));
  }

  // Clear search and filters
  void _clearFilters(TaskProvider provider) {
    _searchController.clear();
    provider.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.filteredTasks;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearchQuery('');
                      },
                      icon: const Icon(Icons.clear),
                    ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Status filters
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['All', 'Pending', 'Completed'].map((status) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(status),
                  selected: provider.statusFilter == status,
                  selectedColor: taskFlowPrimary.withValues(alpha: 0.15),
                  onSelected: (_) {
                    provider.setStatusFilter(status);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Category and priority filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: provider.priorityFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: ['All', 'Low', 'Medium', 'High']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setPriorityFilter(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: provider.categoryFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: ['All', 'Study', 'Work', 'Personal', 'Other']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setCategoryFilter(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Sorting and clear filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: provider.sortOption,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Sort by',
                    prefixIcon: Icon(Icons.sort),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items:
                      [
                        'Newest',
                        'Oldest',
                        'Due Date',
                        'Alphabetical',
                        'Priority',
                      ].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSortOption(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: provider.hasActiveFilters
                    ? () => _clearFilters(provider)
                    : null,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),

        // Result count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${tasks.length} of ${provider.totalTasks} '
                  'task${provider.totalTasks == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (provider.hasActiveFilters)
                Text(
                  'Filters active',
                  style: const TextStyle(
                    color: taskFlowPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),

        // Task list
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No matching tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          provider.totalTasks == 0
                              ? 'You have not added any tasks yet.'
                              : 'Try changing your search or filters.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        if (provider.hasActiveFilters) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _clearFilters(provider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Clear filters'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: task.isCompleted,
                              activeColor: taskFlowPrimary,
                              onChanged: (value) {
                                _toggleTask(task, value);
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: task.isCompleted
                                          ? Colors.grey
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                    ),
                                  ),
                                  if (task.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      task.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 5),
                                  Text(
                                    '${task.category} • ${task.priority}'
                                    '${task.dueDate == null ? '' : ' • ${DateFormat('MMM d, h:mm a').format(task.dueDate!)}'}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Edit button
                            IconButton(
                              tooltip: 'Edit task',
                              onPressed: () => _editTask(task),
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: taskFlowPrimary,
                              ),
                            ),

                            // Delete button
                            IconButton(
                              tooltip: 'Delete task',
                              onPressed: () => _deleteTask(task),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
