import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/home_bloc.dart';
import '../../core/di/injector.dart';
import '../../core/router/app_router.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppColors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
            child: Column(
              children: [
                Spacer(),
                Row(
                  spacing: 12,
                  children: [
                    Icon(Icons.account_circle, size: 40),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Signed in as'),
                          Text(
                            ServiceLocator.get<SupabaseServiceProtocol>()
                                    .user
                                    ?.email ??
                                '',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Spacer(),
                TextButton.icon(
                  onPressed: () => _homeBloc.add(HomeLogout()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.errorColor,
                  ),
                  icon: Icon(Icons.exit_to_app),
                  label: Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: () => _homeBloc.add(HomeLoadTasks()),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  onChanged: (text) {
                    _homeBloc.add(HomeSearchTask(text));
                  },
                  cursorColor: AppColors.black,
                  decoration: InputDecoration(
                    hint: Text('Search for your task!'),
                    filled: true,
                    fillColor: AppColors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: BlocConsumer<HomeBloc, HomeState>(
                bloc: _homeBloc,
                listener: (_, state) {
                  if (state is HomeGoBackToLogin) {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.loginRoute,
                    );
                  }

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
                    return SliverFillRemaining(
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is HomeError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.errorColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _homeBloc.add(HomeLoadTasks()),
                              child: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is HomeFilteredTasks) {
                    return SliverList.builder(
                      itemCount: state.filteredTasks.length,
                      itemBuilder: (_, index) {
                        final task = state.filteredTasks[index];

                        return TaskCard(
                          task: task,
                          onTapEditTask: (oldTask) {
                            _homeBloc.add(HomeShowEditTaskDialog(task));
                          },
                          onTapDeleteTask: (taskId) {
                            _homeBloc.add(
                              HomeShowDeleteTaskBottomSheet(taskId),
                            );
                          },
                        );
                      },
                    );
                  }

                  if (state is HomeSuccess) {
                    if (state.tasks.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 64,
                                color: AppColors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No task found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start creating a new task!',
                                style: TextStyle(color: AppColors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList.builder(
                      itemCount: state.tasks.length,
                      itemBuilder: (_, index) {
                        final task = state.tasks[index];

                        return TaskCard(
                          task: task,
                          onTapEditTask: (oldTask) {
                            _homeBloc.add(HomeShowEditTaskDialog(task));
                          },
                          onTapDeleteTask: (taskId) {
                            _homeBloc.add(
                              HomeShowDeleteTaskBottomSheet(taskId),
                            );
                          },
                        );
                      },
                    );
                  }

                  return SliverToBoxAdapter();
                },
              ),
            ),
            SliverPadding(padding: EdgeInsets.symmetric(vertical: 32)),
          ],
        ),
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
