import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/home_bloc.dart';
import '../../core/di/injector.dart';
import '../../core/services/supabase_service.dart';
import '../../data/entities/task.dart';
import '../../data/entities/task_category.dart';
import '../../style/app_colors.dart';
import '../widgets/bottom_sheet/confirm_delete_task_bottom_sheet.dart';
import '../widgets/dialogs/create_task_dialog.dart';
import '../widgets/dialogs/edit_task_dialog.dart';
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
          if (state is HomeSuccess && state.message != null) {
            _showMessage(state.message ?? '', AppColors.secondaryColor);
          }

          if (state is HomeCreateTaskDialog) {
            _showCreateTaskDialog(state.categories);
          }

          if (state is HomeError) {
            _showMessage(state.message, AppColors.errorColor);
          }

          if (state is HomeDeleteTaskBottomSheet) {
            _showDeleteTaskBottomSheet(state.taskId);
          }

          if (state is HomeEditTaskDialog) {
            _showEditTaskDialog(state.task, state.categories);
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
              itemCount: state.tasks.length,
              itemBuilder: (_, index) {
                final task = state.tasks[index];

                return TaskCard(
                  task: task,
                  onTapEditTask: (oldTask) {
                    _homeBloc.add(HomeShowEditTaskDialog(task));
                  },
                  onTapDeleteTask: (taskId) {
                    _homeBloc.add(HomeShowDeleteTaskBottomSheet(taskId));
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _homeBloc.add(HomeShowCreateTaskDialog()),
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
        ),
        child: Icon(Icons.add, color: AppColors.backgroundColor),
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

  Future<void> _showCreateTaskDialog(List<TaskCategory> categories) async {
    final result = await showDialog(
      context: context,
      builder: (_) {
        return CreateTaskDialog(
          categories: categories,
          showMessage: _showMessage,
          supabaseService: ServiceLocator.get<SupabaseServiceProtocol>(),
          onUpdateCategories: (updatedCategories) {
            _homeBloc.add(HomeUpdateCategories(updatedCategories));
          },
        );
      },
    );

    if (result is Task) _homeBloc.add(HomeCreateTask(newTask: result));
  }

  Future<void> _showDeleteTaskBottomSheet(int taskId) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return ConfirmDeleteTaskBottomSheet(
          onTapConfirmDelete: () {
            _homeBloc.add(HomeConfirmDeleteTask(taskId));
          },
        );
      },
    );
  }

  void _showMessage(String message, [Color? color]) {
    final snackBar = SnackBar(
      backgroundColor: color ?? AppColors.secondaryColor,
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _showEditTaskDialog(
    Task task,
    List<TaskCategory> categories,
  ) async {
    final result = await showDialog(
      context: context,
      builder: (_) {
        return EditTaskDialog(
          task: task,
          categories: categories,
          showMessage: _showMessage,
          supabaseService: ServiceLocator.get<SupabaseServiceProtocol>(),
          onUpdateCategories: (updatedCategories) {
            _homeBloc.add(HomeUpdateCategories(updatedCategories));
          },
        );
      },
    );

    if (result is Task) _homeBloc.add(HomeEditTask(result));
  }
}
