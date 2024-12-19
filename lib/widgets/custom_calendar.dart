import 'package:flutter/material.dart';
import 'package:shape_task_connect/services/public_holiday_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/public_holiday.dart';
import 'year_month_picker_dialog.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final PublicHolidayService holidayService;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Map<DateTime, int>? taskCounts;

  const CustomCalendar({
    super.key,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDay,
    required this.holidayService,
    required this.onDaySelected,
    required this.onPageChanged,
    this.taskCounts,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  final Map<int, List<PublicHoliday>> _holidayCache = {};
  int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadHolidaysForVisibleDates();
  }

  void _handleDateChange(DateTime focusedDay) {
    if (focusedDay.year != _currentYear) {
      setState(() {
        _currentYear = focusedDay.year;
      });
    }
    _loadHolidaysForVisibleDates();
    widget.onPageChanged(focusedDay);
  }

  Future<void> _loadHolidaysForVisibleDates() async {
    final DateTime firstDay =
        DateTime(widget.focusedDay.year, widget.focusedDay.month, 1);
    final DateTime lastDay =
        DateTime(widget.focusedDay.year, widget.focusedDay.month + 1, 0);

    final Set<int> yearsToFetch = {
      firstDay.year,
      DateTime(firstDay.year, firstDay.month - 1, 1).year,
      DateTime(lastDay.year, lastDay.month + 1, 1).year,
    };

    for (final year in yearsToFetch) {
      if (!_holidayCache.containsKey(year)) {
        try {
          final holidays = await widget.holidayService.getHolidays(year);
          setState(() {
            _holidayCache[year] = holidays;
          });
        } catch (e) {
          print('Error loading holidays for year $year: $e');
        }
      }
    }
  }

  Future<void> _showYearPicker(BuildContext context) async {
    final DateTime? selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) => YearMonthPickerDialog(
        initialDate: widget.focusedDay,
        firstAllowedDay: widget.firstDay,
        lastAllowedDay: widget.lastDay,
      ),
    );

    if (selectedDate != null) {
      widget.onPageChanged(selectedDate);
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    final allHolidays = _holidayCache.values.expand((list) => list).toList();
    return allHolidays
        .where((holiday) => isSameDay(holiday.date, day))
        .map((holiday) => Event(holiday.localName, holiday.name))
        .toList();
  }

  String getSelectedDayText(DateTime day) {
    final allHolidays = _holidayCache.values.expand((list) => list).toList();
    final dayHolidays =
        allHolidays.where((holiday) => isSameDay(holiday.date, day)).toList();
    if (dayHolidays.isEmpty) {
      return DateFormat('yyyy-MM-dd').format(day);
    }

    return dayHolidays
        .map((holiday) =>
            '${DateFormat('yyyy-MM-dd').format(day)} - ${holiday.localName} (${holiday.name})')
        .join('\n');
  }

  @override
  void didUpdateWidget(CustomCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay.year != widget.focusedDay.year ||
        oldWidget.focusedDay.month != widget.focusedDay.month) {
      _loadHolidaysForVisibleDates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: widget.firstDay,
          lastDay: widget.lastDay,
          focusedDay: widget.focusedDay,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) {
            return isSameDay(widget.selectedDay, day);
          },
          onDaySelected: widget.onDaySelected,
          onPageChanged: _handleDateChange,
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 0,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            headerPadding: EdgeInsets.symmetric(vertical: 4.0),
          ),
          calendarBuilders: CalendarBuilders(
            headerTitleBuilder: (context, day) {
              return InkWell(
                onTap: () => _showYearPicker(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(day),
                        style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 20.0,
                      ),
                    ],
                  ),
                ),
              );
            },
            defaultBuilder: (context, day, focusedDay) {
              final events = _getEventsForDay(day);
              final isToday = isSameDay(day, DateTime.now());
              final isSelected = isSameDay(day, widget.selectedDay);
              final isSunday = day.weekday == DateTime.sunday;

              if (!isSelected && !isToday && (events.isNotEmpty || isSunday)) {
                return Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                );
              }
              return null;
            },
            markerBuilder: (context, day, events) {
              final taskCount = widget.taskCounts?[DateTime(
                day.year,
                day.month,
                day.day,
              )];

              if (taskCount != null && taskCount > 0) {
                return Positioned(
                  bottom: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Text(
                      taskCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
          eventLoader: _getEventsForDay,
        ),
        const SizedBox(height: 20),
        if (widget.selectedDay != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              getSelectedDayText(widget.selectedDay!),
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }
}
