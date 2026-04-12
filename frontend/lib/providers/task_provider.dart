import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _todayTasks = [];
  bool       _loading    = false;
  String?    _error;

  List<Task> get todayTasks => _todayTasks;
  bool       get loading    => _loading;
  String?    get error      => _error;

  Future<void> loadTodayTasks() async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      _todayTasks = await TaskService.getTodayTasks();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> createTask({
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
    _error = null;
    try {
      final newTask = await TaskService.createTask(
        name:              name,
        description:       description,
        isUrgent:          isUrgent,
        scheduledDate:     scheduledDate,
        notificationType:  notificationType,
        isRecurrent:       isRecurrent,
        recurrenceType:    recurrenceType,
        recurrenceDays:    recurrenceDays,
        recurrenceEndDate: recurrenceEndDate,
        idTaskTemplate:    idTaskTemplate,
      );
      _todayTasks.add(newTask);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsDone(int taskId) async {
    _error = null;
    try {
      final updated = await TaskService.updateTaskStatus(taskId, 'realizada');
      final index = _todayTasks.indexWhere((t) => t.idTask == taskId);
      if (index != -1) {
        _todayTasks[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    _error = null;
    try {
      await TaskService.deleteTask(taskId);
      _todayTasks.removeWhere((t) => t.idTask == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}