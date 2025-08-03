import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/entities/task.dart';
import '../../../data/entities/task_category.dart';
import '../../../shared/enum/task_status.dart';
import '../../../shared/utils/date_input_formatter.dart';
import '../../../style/app_colors.dart';

class CreateTaskDialog extends StatefulWidget {
  final List<TaskCategory> categories;

  const CreateTaskDialog({required this.categories, super.key});

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categories = List<TaskCategory>.empty(growable: true);
  final _expiryDateTextController = TextEditingController();
  TaskStatus _selectedStatus = TaskStatus.todo;
  TaskCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _categories.addAll(widget.categories);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'New Task',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
      content: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey),
                  ),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? false) {
                    return "Title can't be blank";
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey),
                  ),
                ),
              ),
              DropdownMenu<TaskCategory?>(
                label: Text('Category'),
                expandedInsets: EdgeInsets.zero,
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownMenuEntries: _categories.map((category) {
                  return DropdownMenuEntry(
                    value: category,
                    label: category.name,
                  );
                }).toList(),
                onSelected: (category) {
                  _selectedCategory = category;
                },
              ),
              DropdownMenu<TaskStatus?>(
                label: Text('Status'),
                initialSelection: TaskStatus.todo,
                expandedInsets: EdgeInsets.zero,
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownMenuEntries: TaskStatus.values.map((value) {
                  return DropdownMenuEntry(value: value, label: value.label);
                }).toList(),
                onSelected: (value) {
                  _selectedStatus = value ?? TaskStatus.todo;
                },
              ),
              TextFormField(
                controller: _expiryDateTextController,
                inputFormatters: [DateInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hint: Text('yyyy/MM/dd'),
                  suffixIcon: GestureDetector(
                    onTap: _didTapPickDate,
                    child: Icon(Icons.calendar_month),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createTask() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final newTask = Task(
      id: 0,
      title: _titleController.text,
      description: _descriptionController.text,
      status: _selectedStatus.label,
      category: _selectedCategory,
      expiryDate: DateTime.tryParse(
        _expiryDateTextController.text.replaceAll('/', '-'),
      ),
    );

    Navigator.of(context).pop(newTask);
  }

  Future<void> _didTapPickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(3000),
    );

    if (selectedDate == null) return;

    final formatter = DateFormat('yyyy/MM/dd');
    _expiryDateTextController.text = formatter.format(selectedDate);
  }
}
