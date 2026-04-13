import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _todayTasks = [];
  List<Task> _allTasks   = [];
  bool       _loading    = false;
  bool       _loadingAll = false;
  String?    _error;

  List<Task> get todayTasks => _todayTasks;
  List<Task> get allTasks   => _allTasks;
  bool       get loading    => _loading;
  bool       get loadingAll => _loadingAll;
  String?    get error      => _error;

  // Tareas agrupadas por día (año-mes-día) para el calendario
  Map<String, List<Task>> get tasksByDate {
    final map = <String, List<Task>>{};
    for (final task in _allTasks) {
      try {
        final dt  = DateTime.parse(task.scheduledDate);
        final key = '${dt.year}-${dt.month}-${dt.day}';
        map.putIfAbsent(key, () => []).add(task);
      } catch (_) {}
    }
    return map;
  }

  // Días completados del mes (todos sus tareas están realizadas)
  Set<int> completedDaysInMonth(int year, int month) {
    final byDay = <int, List<Task>>{};
    for (final task in _allTasks) {
      try {
        final dt = DateTime.parse(task.scheduledDate);
        if (dt.year == year && dt.month == month) {
          byDay.putIfAbsent(dt.day, () => []).add(task);
        }
      } catch (_) {}
    }
    final result = <int>{};
    byDay.forEach((day, tasks) {
      final past = tasks.every((t) =>
          DateTime.parse(t.scheduledDate).isBefore(DateTime.now()));
      final allDone = tasks.every((t) => t.isDone);
      if (past && allDone) result.add(day);
    });
    return result;
  }

  // Días fallidos del mes (pasaron y al menos una tarea está vencida)
  Set<int> failedDaysInMonth(int year, int month) {
    final byDay = <int, List<Task>>{};
    for (final task in _allTasks) {
      try {
        final dt = DateTime.parse(task.scheduledDate);
        if (dt.year == year && dt.month == month) {
          byDay.putIfAbsent(dt.day, () => []).add(task);
        }
      } catch (_) {}
    }
    final result = <int>{};
    byDay.forEach((day, tasks) {
      final hasExpired = tasks.any((t) => t.isExpired);
      final notAllDone = !tasks.every((t) => t.isDone);
      if (hasExpired || notAllDone) {
        final allPast = tasks.every((t) =>
            DateTime.parse(t.scheduledDate).isBefore(DateTime.now()));
        if (allPast) result.add(day);
      }
    });
    // Quitar los que ya están en completados
    return result..removeAll(completedDaysInMonth(year, month));
  }

  // Días con tareas futuras programadas
  Set<int> scheduledDaysInMonth(int year, int month) {
    final now = DateTime.now();
    final result = <int>{};
    for (final task in _allTasks) {
      try {
        final dt = DateTime.parse(task.scheduledDate);
        if (dt.year == year && dt.month == month && dt.isAfter(now)) {
          result.add(dt.day);
        }
      } catch (_) {}
    }
    return result;
  }

  // Tareas de un día concreto como lista de Map para los tiles del calendario
  List<Map<String, dynamic>> tasksForDay(int year, int month, int day) {
    final key = '$year-$month-$day';
    final tasks = tasksByDate[key] ?? [];
    return tasks.map((t) {
      DateTime dt;
      try { dt = DateTime.parse(t.scheduledDate); } catch (_) { dt = DateTime.now(); }
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');

      // Color por estado
      int color;
      if (t.isDone)        color = 0xFF5A4EDB; // blueberry
      else if (t.isExpired) color = 0xFFCF6679; // error
      else                  color = 0xFFBCBBF2; // lightBlue

      return {
        'name':   t.name,
        'time':   '$h:$m',
        'done':   t.isDone,
        'foints': t.idTaskTemplate != null,
        'color':  color,
      };
    }).toList();
  }

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

  Future<void> loadAllTasks() async {
    _loadingAll = true;
    _error      = null;
    notifyListeners();
    try {
      _allTasks = await TaskService.getAllTasks();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _loadingAll = false;
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
      _allTasks.add(newTask);
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
      final todayIdx = _todayTasks.indexWhere((t) => t.idTask == taskId);
      if (todayIdx != -1) _todayTasks[todayIdx] = updated;
      final allIdx = _allTasks.indexWhere((t) => t.idTask == taskId);
      if (allIdx != -1) _allTasks[allIdx] = updated;
      notifyListeners();
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
      _allTasks.removeWhere((t) => t.idTask == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}