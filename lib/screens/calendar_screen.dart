import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

const Color _calendarPrimary = Color(0xFF6855E8);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<Task> _tasksForDay(List<Task> tasks, DateTime day) {
    return tasks.where((task) {
      final dueDate = task.dueDate;
      return dueDate != null && _isSameDate(dueDate, day);
    }).toList()..sort((a, b) {
      return a.dueDate!.compareTo(b.dueDate!);
    });
  }

  Future<void> _toggleTask(Task task, bool? value) async {
    if (task.id == null) return;

    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      category: task.category,
      priority: task.priority,
      dueDate: task.dueDate,
      isCompleted: value ?? false,
      createdAt: task.createdAt,
    );

    await context.read<TaskProvider>().updateTask(updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;
    final selectedTasks = _tasksForDay(tasks, _selectedDay);

    final overdueCount = tasks.where((task) {
      return !task.isCompleted &&
          task.dueDate != null &&
          task.dueDate!.isBefore(DateTime.now());
    }).length;

    return SafeArea(
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // Monthly calendar
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TableCalendar<Task>(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2100),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    availableGestures: AvailableGestures.horizontalSwipe,
                    eventLoader: (day) => _tasksForDay(tasks, day),
                    selectedDayPredicate: (day) =>
                        _isSameDate(day, _selectedDay),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: _calendarPrimary,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: _calendarPrimary,
                      ),
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      markersMaxCount: 3,
                      markerDecoration: const BoxDecoration(
                        color: _calendarPrimary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: _calendarPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(
                        color: _calendarPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: _calendarPrimary,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      weekendTextStyle: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Task summary
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Scheduled',
                        value: tasks
                            .where((task) => task.dueDate != null)
                            .length
                            .toString(),
                        icon: Icons.event_note,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Overdue',
                        value: overdueCount.toString(),
                        icon: Icons.schedule,
                        alert: overdueCount > 0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Selected date and its tasks
                Text(
                  DateFormat('EEEE, MMMM d').format(_selectedDay),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedTasks.length} '
                  '${selectedTasks.length == 1 ? 'task' : 'tasks'} scheduled',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),

                if (selectedTasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 46,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Nothing scheduled',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tasks with a due date on this day '
                          'will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  ...selectedTasks.map(
                    (task) => _CalendarTaskTile(
                      task: task,
                      onToggle: (value) => _toggleTask(task, value),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool alert;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    this.alert = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = alert ? Colors.redAccent : _calendarPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onToggle;

  const _CalendarTaskTile({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final dueDate = task.dueDate!;
    final isCompleted = task.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            activeColor: _calendarPrimary,
            onChanged: onToggle,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${DateFormat('h:mm a').format(dueDate)}'
                  ' • ${task.category}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Text(
                  '${task.priority} priority',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _calendarPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
