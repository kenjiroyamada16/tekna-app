import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import '../../core/blocs/home_bloc.dart';
import '../../data/entities/task.dart';
import '../../shared/enum/task_status.dart';
import '../../shared/utils/date_input_formatter.dart';
import '../../style/app_colors.dart';
import '../widgets/home/task_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>();
    _homeBloc.add(HomeLoadTasks());
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _homeBloc.add(HomeLoadTasks()),
          ),
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        bloc: _homeBloc,
        listener: (_, state) {
          if (state is HomeCreateTaskDialog) {
            _showCreateTaskDialog(state.categories);
          }

          if (state is HomeError) {
            _showErrorMessage(state.message);
          }
        },
        builder: (_, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _homeBloc.add(HomeLoadTasks()),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          if (state is HomeSuccess) {
            if (state.tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No task found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start creating a new task!',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tasks.length,
              itemBuilder: (_, index) {
                final task = state.tasks[index];

                return TaskCard(task: task);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: SpeedDial(
        elevation: 1,
        icon: Icons.add,
        backgroundColor: AppColors.primaryColor,
        animatedIconTheme: IconThemeData(color: AppColors.white),
        children: [
          SpeedDialChild(
            onTap: () => _homeBloc.add(HomeShowCreateTaskDialog()),
            labelWidget: _getFabItem(
              label: 'Create task',
              leadingIcon: Icon(Icons.event),
            ),
          ),
          SpeedDialChild(
            labelWidget: _getFabItem(
              label: 'Create category',
              leadingIcon: Icon(Icons.category),
            ),
            onTap: () {
              // TODO: Create new category
            },
          ),
        ],
      ),
    );
  }

  Widget _getFabItem({required String label, required Widget leadingIcon}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(spacing: 8, children: [leadingIcon, Text(label)]),
      ),
    );
  }

  Future<void> _showCreateTaskDialog(List<String> categories) async {
    final result = await showDialog(
      context: context,
      builder: (_) {
        return CreateTaskDialog(categories: categories);
      },
    );

    if (result is Task) _homeBloc.add(HomeCreateTask(newTask: result));
  }

  void _showErrorMessage(String errorMessage) {
    final snackBar = SnackBar(
      backgroundColor: AppColors.secondaryColor,
      content: Text(
        errorMessage,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class CreateTaskDialog extends StatefulWidget {
  final List<String> categories;

  const CreateTaskDialog({required this.categories, super.key});

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categories = List<String>.empty(growable: true);
  final _expiryDateTextController = TextEditingController();
  String _selectedStatus = TaskStatus.todo.name;
  String? _selectedCategory;

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
              DropdownMenu<String?>(
                label: Text('Category'),
                expandedInsets: EdgeInsets.zero,
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownMenuEntries: _categories.map((value) {
                  return DropdownMenuEntry(value: value, label: value);
                }).toList(),
                onSelected: (value) {
                  _selectedCategory = value;
                },
              ),
              DropdownMenu<String?>(
                label: Text('Status'),
                initialSelection: TaskStatus.todo.name,
                expandedInsets: EdgeInsets.zero,
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownMenuEntries: TaskStatus.values.map((value) {
                  return DropdownMenuEntry(
                    value: value.name,
                    label: value.label,
                  );
                }).toList(),
                onSelected: (value) {
                  _selectedStatus = value ?? TaskStatus.todo.name;
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
      status: _selectedStatus,
      categoryName: _selectedCategory,
      expiryDate: DateTime.tryParse(_expiryDateTextController.text),
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
