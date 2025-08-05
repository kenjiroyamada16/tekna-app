import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/supabase_service.dart';
import '../../../data/domain/app_exception.dart';
import '../../../data/entities/task.dart';
import '../../../data/entities/task_category.dart';
import '../../../shared/enum/task_status.dart';
import '../../../shared/utils/date_input_formatter.dart';
import '../../../style/app_colors.dart';

class CreateTaskDialog extends StatefulWidget {
  final List<TaskCategory> categories;
  final SupabaseServiceProtocol supabaseService;
  final void Function(String message, [Color? color])? showMessage;
  final void Function(List<TaskCategory> categoriesList)? onUpdateCategories;

  const CreateTaskDialog({
    required this.categories,
    required this.supabaseService,
    this.showMessage,
    this.onUpdateCategories,
    super.key,
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _categoryFocusNode = FocusNode();
  final _categories = List<TaskCategory>.empty(growable: true);
  final _expiryDateTextController = TextEditingController();
  TaskStatus _selectedStatus = TaskStatus.todo;
  TaskCategory? _selectedCategory;
  bool _isEditting = false;

  @override
  void initState() {
    super.initState();
    _categories.addAll(widget.categories);
    _categories.add(TaskCategory(id: -1, name: '+ Create category'));
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
                textInputAction: TextInputAction.done,
                focusNode: _selectedCategory?.id == -1 || _isEditting
                    ? _categoryFocusNode
                    : null,
                controller: _categoryController,
                expandedInsets: EdgeInsets.zero,
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                selectedTrailingIcon: _trailingIcon,
                trailingIcon: _trailingIcon,
                dropdownMenuEntries: _categories.map((category) {
                  return DropdownMenuEntry(
                    value: category,
                    label: category.name,
                    trailingIcon: Visibility(
                      visible: category.id != -1,
                      child: Row(
                        children: [
                          IconButton(
                            iconSize: 16,
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _selectedCategory = category;
                              _categoryController.text =
                                  _selectedCategory?.name ?? '';
                              _categoryFocusNode.requestFocus();
                              _isEditting = true;

                              setState(() {});
                            },
                          ),
                          IconButton(
                            onPressed: () => _deleteCategory(category.id),
                            iconSize: 16,
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onSelected: (category) {
                  _isEditting = false;

                  if (category?.id == -1) {
                    _categoryController.clear();
                    _categoryFocusNode.requestFocus();
                  }

                  _selectedCategory = TaskCategory(
                    id: category?.id ?? -1,
                    name: _categoryController.text,
                  );

                  setState(() {});
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

  Widget? get _trailingIcon {
    if (_isEditting) {
      return GestureDetector(
        onTap: _editCategory,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey,
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(Icons.edit, size: 20, color: AppColors.backgroundColor),
          ),
        ),
      );
    }

    if (_selectedCategory?.id != -1) return null;

    return GestureDetector(
      onTap: _createCategory,
      child: Icon(Icons.add_circle),
    );
  }

  Future<void> _createCategory() async {
    final newCategory = _categoryController.text;
    final categoriesNames = widget.categories.map(
      (category) => category.name.toLowerCase(),
    );

    if (newCategory.isEmpty) return;
    if (categoriesNames.contains(newCategory.toLowerCase())) return;

    try {
      final createdCategory = await widget.supabaseService.createCategory(
        newCategory,
      );

      if (createdCategory == null) {
        return widget.showMessage?.call(
          'Could not create the category',
          AppColors.errorColor,
        );
      }

      _categories.insert(_categories.length - 1, createdCategory);
      _selectedCategory = _categories.where((category) {
        return createdCategory.id == category.id;
      }).firstOrNull;
      _categoryFocusNode.unfocus();
      widget.onUpdateCategories?.call(_categories);

      setState(() {});
    } on AppException catch (e) {
      widget.showMessage?.call(e.userFriendlyMessage, AppColors.errorColor);
    }
  }

  void _createTask() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final newTask = Task(
      id: 0,
      title: _titleController.text,
      description: _descriptionController.text,
      status: _selectedStatus.label,
      category: _isEditting ? null : _selectedCategory,
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

  Future<void> _editCategory() async {
    final edittedCategoryId = _selectedCategory?.id;
    final newCategoryName = _categoryController.text;

    final categoriesNames = widget.categories.map(
      (category) => category.name.toLowerCase(),
    );

    if (edittedCategoryId == null) return;
    if (categoriesNames.contains(newCategoryName.toLowerCase())) return;

    try {
      final updatedCategory = await widget.supabaseService.editCategory(
        id: edittedCategoryId,
        newName: newCategoryName,
      );

      if (updatedCategory == null) {
        return widget.showMessage?.call(
          'Could not edit the category',
          AppColors.errorColor,
        );
      }

      final updatedIndex = _categories.indexOf(updatedCategory);
      _categories[updatedIndex] = updatedCategory;
      _selectedCategory = _categories.where((category) {
        return updatedCategory == category;
      }).firstOrNull;
      _categoryFocusNode.unfocus();
      widget.onUpdateCategories?.call(
        _categories.where((category) {
          return category.id >= 0;
        }).toList(),
      );
      _isEditting = false;

      setState(() {});
    } on AppException catch (e) {
      widget.showMessage?.call(e.userFriendlyMessage, AppColors.errorColor);
    }
  }

  Future<void> _deleteCategory(int categoryId) async {
    try {
      final deletedCategory = await widget.supabaseService.deleteCategory(
        id: categoryId,
      );

      if (deletedCategory == null) {
        return widget.showMessage?.call(
          'Could not edit the category',
          AppColors.errorColor,
        );
      }

      final hasRemovedCategory = _categories.remove(deletedCategory);

      if (!hasRemovedCategory) {
        return widget.showMessage?.call(
          'Could not delete the category',
          AppColors.errorColor,
        );
      }

      widget.onUpdateCategories?.call(
        _categories.where((category) {
          return category.id >= 0;
        }).toList(),
      );

      setState(() {});
    } on AppException catch (e) {
      widget.showMessage?.call(e.userFriendlyMessage, AppColors.errorColor);
    }
  }
}
