import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../screens/home_screen.dart' show taskFlowPrimary;

class TaskDialog extends StatefulWidget {
  final Task? task;

  const TaskDialog({super.key, this.task});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late String category;
  late String priority;
  late int reminderMinutes;
  DateTime? dueDate;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    category = task?.category ?? 'Personal';
    priority = task?.priority ?? 'Medium';
    dueDate = task?.dueDate;
    reminderMinutes = task?.reminderMinutes ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: dueDate != null
          ? TimeOfDay.fromDateTime(dueDate!)
          : TimeOfDay.now(),
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      dueDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final existingTask = widget.task;

    final task = Task(
      id: existingTask?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: category,
      priority: priority,
      dueDate: dueDate,
      isCompleted: existingTask?.isCompleted ?? false,
      createdAt: existingTask?.createdAt ?? DateTime.now(),
      reminderMinutes: reminderMinutes,
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Task' : 'Create New Task',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  hintText: 'Enter task name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.task_alt),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task details (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const ['Study', 'Work', 'Personal', 'Other']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => category = value);
                  }
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const ['Low', 'Medium', 'High']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => priority = value);
                  }
                },
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  dueDate == null
                      ? 'Select due date and time'
                      : DateFormat('MMM d, yyyy - h:mm a').format(dueDate!),
                ),
              ),
              if (dueDate != null)
                TextButton.icon(
                  onPressed: () => setState(() => dueDate = null),
                  icon: const Icon(Icons.clear),
                  label: const Text('Remove due date'),
                ),
              const SizedBox(height: 15),
              DropdownButtonFormField<int>(
                initialValue: reminderMinutes,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Reminder',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('At due time')),
                  DropdownMenuItem(value: 10, child: Text('10 minutes before')),
                  DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                  DropdownMenuItem(value: -1, child: Text('No reminder')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => reminderMinutes = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveTask,
          style: FilledButton.styleFrom(
            backgroundColor: taskFlowPrimary,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Save Changes' : 'Save Task'),
        ),
      ],
    );
  }
}
