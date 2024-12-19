import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/task_item.dart';
import '../../repositories/task_repository.dart';

class EditTaskWidget extends StatefulWidget {
  final int taskId;
  final Future<void> Function()? onRefresh;

  const EditTaskWidget({
    super.key,
    required this.taskId,
    required this.onRefresh,
  });

  @override
  State<EditTaskWidget> createState() => _EditTaskWidgetState();
}

class _EditTaskWidgetState extends State<EditTaskWidget> {
  final _taskRepository = GetIt.instance<TaskRepository>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = true;
  TaskItem? _task;
  late DateTime _selectedDueDate;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _selectedDueDate = DateTime.now().add(const Duration(days: 1));
    _isCompleted = false;
    _loadTask();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    try {
      final task = await _taskRepository.getTask(widget.taskId);
      if (task != null) {
        setState(() {
          _task = task;
          _titleController.text = task.title;
          _descriptionController.text = task.description;
          _selectedDueDate = task.dueDate;
          _isCompleted = task.completed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _updateTask() async {
    if (_task == null) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final updatedTask = TaskItem(
        id: _task!.id,
        title: title,
        description: description,
        createdBy: _task!.createdBy,
        createdAt: _task!.createdAt,
        dueDate: _selectedDueDate,
        completed: _isCompleted,
      );

      await _taskRepository.updateTask(updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onRefresh?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateTask,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    minLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(
                      '${_selectedDueDate.year}-${_selectedDueDate.month}-${_selectedDueDate.day}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDueDate,
                    tileColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Mark as Completed'),
                    value: _isCompleted,
                    onChanged: (bool value) {
                      setState(() {
                        _isCompleted = value;
                      });
                    },
                    tileColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
