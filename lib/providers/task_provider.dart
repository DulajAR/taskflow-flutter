import 'package:flutter/material.dart';

import '../database/task_repository.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<Task> _tasks = [];
  bool _isLoading = false;

  // Search and filter state
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _categoryFilter = 'All';
  String _priorityFilter = 'All';
  String _sortOption = 'Newest';

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get categoryFilter => _categoryFilter;
  String get priorityFilter => _priorityFilter;
  String get sortOption => _sortOption;

  int get totalTasks => _tasks.length;

  int get completedTasks => _tasks.where((task) => task.isCompleted).length;

  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;

  // Tasks after applying search, filters and sorting.
  List<Task> get filteredTasks {
    List<Task> result = List<Task>.from(_tasks);

    // Search by task title or description.
    final query = _searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query);
      }).toList();
    }

    // Status filter.
    if (_statusFilter == 'Pending') {
      result = result.where((task) => !task.isCompleted).toList();
    } else if (_statusFilter == 'Completed') {
      result = result.where((task) => task.isCompleted).toList();
    }

    // Category filter.
    if (_categoryFilter != 'All') {
      result = result
          .where((task) => task.category == _categoryFilter)
          .toList();
    }

    // Priority filter.
    if (_priorityFilter != 'All') {
      result = result
          .where((task) => task.priority == _priorityFilter)
          .toList();
    }

    // Sorting.
    switch (_sortOption) {
      case 'Oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;

      case 'Due Date':
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;

      case 'Alphabetical':
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;

      case 'Priority':
        const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};

        result.sort((a, b) {
          final aPriority = priorityOrder[a.priority] ?? 3;
          final bPriority = priorityOrder[b.priority] ?? 3;
          return aPriority.compareTo(bPriority);
        });
        break;

      case 'Newest':
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return result;
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setStatusFilter(String value) {
    _statusFilter = value;
    notifyListeners();
  }

  void setCategoryFilter(String value) {
    _categoryFilter = value;
    notifyListeners();
  }

  void setPriorityFilter(String value) {
    _priorityFilter = value;
    notifyListeners();
  }

  void setSortOption(String value) {
    _sortOption = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = 'All';
    _categoryFilter = 'All';
    _priorityFilter = 'All';
    _sortOption = 'Newest';
    notifyListeners();
  }

  bool get hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _statusFilter != 'All' ||
        _categoryFilter != 'All' ||
        _priorityFilter != 'All' ||
        _sortOption != 'Newest';
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _repository.getAllTasks();
      await _syncTaskReminders();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncTaskReminders() async {
    for (final task in _tasks) {
      final taskId = task.id;
      if (taskId == null) continue;

      await NotificationService.cancelTaskReminder(taskId);
      await NotificationService.scheduleTaskReminder(task);
    }
  }

  Future<void> addTask(Task task) async {
    await _repository.addTask(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    final taskId = task.id;

    if (taskId != null) {
      await NotificationService.cancelTaskReminder(taskId);
    }

    await _repository.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await NotificationService.cancelTaskReminder(id);
    await _repository.deleteTask(id);
    await loadTasks();
  }

  Future<void> refreshTasks() async {
    await loadTasks();
  }
}
