import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/utils/token_storage.dart';
import '../models/task.dart';

class TaskService {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<List<Task>> getTodayTasks() async {
    final response = await http.get(
      Uri.parse(ApiConstants.tasksToday),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener las tareas del dia');
    }
  }

  static Future<List<Task>> getAllTasks() async {
    final response = await http.get(
      Uri.parse(ApiConstants.tasks),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener las tareas');
    }
  }

  static Future<Task> createTask({
    required String name,
    String? description,
    required bool isUrgent,
    required String scheduledDate,
    required String notificationType,
    bool isRecurrent = false,
    String recurrenceType = 'ninguna',
    String? recurrenceDays,
    String? recurrenceEndDate,
    int? idTaskTemplate,
  }) async {
    final body = {
      'name':                name,
      'description':         description,
      'is_urgent':           isUrgent,
      'scheduled_date':      scheduledDate,
      'notification_type':   notificationType,
      'status':              'pendiente',
      'is_recurrent':        isRecurrent,
      'recurrence_type':     recurrenceType,
      'recurrence_days':     recurrenceDays,
      'recurrence_end_date': recurrenceEndDate,
      'id_task_template':    idTaskTemplate,
    };

    final response = await http.post(
      Uri.parse(ApiConstants.tasks),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Error al crear la tarea');
    }
  }

  static Future<Task> updateTaskStatus(int taskId, String newStatus) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.tasks}/$taskId'),
      headers: await _headers(),
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Error al actualizar la tarea');
    }
  }

  static Future<void> deleteTask(int taskId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.tasks}/$taskId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Error al eliminar la tarea');
    }
  }
}