import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;

  List<Task> _tasks = <Task>[];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  TaskStatus? _selectedStatus;
  TaskCategory? _selectedCategory;

  TaskProvider(this._taskService);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  TaskStatus? get selectedStatus => _selectedStatus;
  TaskCategory? get selectedCategory => _selectedCategory;

  Future<void> loadTasks() async {
    await _runRequest(() async {
      _tasks = await _taskService.getAllTasks();
      _clearFiltersOnly();
    });
  }

  Future<void> searchTasks(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      await loadTasks();
      return;
    }

    await _runRequest(() async {
      _searchQuery = trimmed;
      _selectedStatus = null;
      _selectedCategory = null;
      _tasks = await _taskService.searchTasks(trimmed);
    });
  }

  Future<void> filterByStatus(TaskStatus? status) async {
    if (status == null) {
      await loadTasks();
      return;
    }

    await _runRequest(() async {
      _searchQuery = '';
      _selectedStatus = status;
      _selectedCategory = null;
      _tasks = await _taskService.filterByStatus(status);
    });
  }

  Future<void> filterByCategory(TaskCategory? category) async {
    if (category == null) {
      await loadTasks();
      return;
    }

    await _runRequest(() async {
      _searchQuery = '';
      _selectedStatus = null;
      _selectedCategory = category;
      _tasks = await _taskService.filterByCategory(category);
    });
  }

  Future<void> addTask(Task task) async {
    await _runMutation(() async {
      final newTask = await _taskService.createTask(task);
      _tasks.insert(0, newTask);
    });
  }

  Future<void> updateTask(int id, Task task) async {
    await _runMutation(() async {
      final updatedTask = await _taskService.updateTask(id, task);
      _replaceTask(updatedTask);
    });
  }

  Future<void> updateTaskStatus(int id, TaskStatus status) async {
    await _runMutation(() async {
      final updatedTask = await _taskService.updateTaskStatus(id, status);
      _replaceTask(updatedTask);
    });
  }

  Future<void> deleteTask(int id) async {
    await _runMutation(() async {
      await _taskService.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
    });
  }

  Future<void> clearFilters() async {
    await loadTasks();
  }

  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _runRequest(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await action();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _runMutation(Future<void> Function() action) async {
    _error = null;
    notifyListeners();

    try {
      await action();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _replaceTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) {
      _tasks.insert(0, updatedTask);
    } else {
      _tasks[index] = updatedTask;
    }
  }

  void _clearFiltersOnly() {
    _searchQuery = '';
    _selectedStatus = null;
    _selectedCategory = null;
  }
}
