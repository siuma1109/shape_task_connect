import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/public_holiday_service.dart';
import '../../services/auth_service.dart';
import '../../services/locator.dart';
import '../../widgets/custom_calendar.dart';
import '../../widgets/task/task_list.dart';
import '../../models/task.dart';
import '../../repositories/task_repository.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final PublicHolidayService _holidayService = locator<PublicHolidayService>();
  final TaskRepository _taskRepository = locator<TaskRepository>();
  final AuthService _authService = locator<AuthService>();
  late final DateTime _firstAllowedDay;
  late final DateTime _lastAllowedDay;
  List<Task> _tasks = [];
  bool _isLoading = false;
  Map<DateTime, int> _taskCounts = {};

  Future<void> _loadTaskCounts() async {
    try {
      final currentUser = _authService.currentUserDetails;
      if (currentUser != null) {
        // Get first day of current month
        final firstVisibleDay =
            DateTime(_focusedDay.year, _focusedDay.month, 1);

        // Get last visible day (includes days from next month that are shown)
        final lastDayOfMonth =
            DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
        final lastWeekday = lastDayOfMonth.weekday;
        final daysToAdd = (7 - lastWeekday) % 7; // Days showing from next month
        final lastVisibleDay = lastDayOfMonth.add(Duration(days: daysToAdd));

        // Set time to include full days
        final startDate = firstVisibleDay;
        final endDate = DateTime(
          lastVisibleDay.year,
          lastVisibleDay.month,
          lastVisibleDay.day,
          23,
          59,
          59,
        );

        final counts = await _taskRepository.getTaskCountsByDateRange(
          currentUser.uid,
          Timestamp.fromDate(startDate),
          Timestamp.fromDate(endDate),
        );

        setState(() {
          _taskCounts = counts;
          print('taskCounts: $_taskCounts');
        });
      }
    } catch (e) {
      print('Error loading task counts: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _firstAllowedDay = DateTime(currentYear - 20, 1, 1);
    _lastAllowedDay = DateTime(currentYear + 20, 12, 31);
    _loadTaskCounts();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _authService.currentUserDetails;
      if (currentUser != null) {
        final startOfDay =
            DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
        final endOfDay = DateTime(
            _focusedDay.year, _focusedDay.month, _focusedDay.day, 23, 59, 59);
        final tasks = await _taskRepository.getTasksByUserAndDueDateRange(
            currentUser.uid,
            Timestamp.fromDate(startOfDay),
            Timestamp.fromDate(endOfDay));

        print('Values: $currentUser.uid $startOfDay $endOfDay');
        print('Tasks: ${tasks.length}');
        setState(() {
          _tasks = tasks;
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          CustomCalendar(
            firstDay: _firstAllowedDay,
            lastDay: _lastAllowedDay,
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            holidayService: _holidayService,
            taskCounts: _taskCounts,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadTaskCounts();
              _loadTasks();
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
              _loadTaskCounts();
              _loadTasks();
            },
          ),
          Expanded(
            child: TaskList(
              tasks: _tasks,
              isLoading: _isLoading,
              onRefresh: _handleRefresh,
            ),
          ),
        ],
      ),
    );
  }
}
