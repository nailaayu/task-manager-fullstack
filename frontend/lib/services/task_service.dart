import '../models/task.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _apiService;

  TaskService(this._apiService);

  Future<List<Task>> getAllTasks() async {
    final response = await _apiService.get('/tasks');
    return _parseTaskList(response.data);
  }

  Future<Task> getTaskById(int id) async {
    final response = await _apiService.get('/tasks/$id');
    return Task.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<Task> createTask(Task task) async {
    final response = await _apiService.post('/tasks', data: task.toJson());
    return Task.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<Task> updateTask(int id, Task task) async {
    final response = await _apiService.put('/tasks/$id', data: task.toJson());
    return Task.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<Task> updateTaskStatus(int id, TaskStatus status) async {
    final response = await _apiService.patch('/tasks/$id/status?status=${status.apiValue}');
    return Task.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> deleteTask(int id) async {
    await _apiService.delete('/tasks/$id');
  }

  Future<List<Task>> searchTasks(String query) async {
    final response = await _apiService.get(
      '/tasks/search',
      queryParameters: {'query': query},
    );
    return _parseTaskList(response.data);
  }

  Future<List<Task>> filterByStatus(TaskStatus status) async {
    final response = await _apiService.get(
      '/tasks/filter/status',
      queryParameters: {'status': status.apiValue},
    );
    return _parseTaskList(response.data);
  }

  Future<List<Task>> filterByCategory(TaskCategory category) async {
    final response = await _apiService.get(
      '/tasks/filter/category',
      queryParameters: {'category': category.apiValue},
    );
    return _parseTaskList(response.data);
  }

  List<Task> _parseTaskList(dynamic data) {
    final list = data is List ? data : <dynamic>[];
    return list
        .map((json) => Task.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }
}
