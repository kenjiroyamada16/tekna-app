import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/domain/app_exception.dart';
import '../../data/entities/task.dart';
import '../../data/entities/task_category.dart';
import '../../data/entities/task_media.dart';
import '../../shared/enum/task_status.dart';
import '../../shared/utils/constants.dart';

abstract class SupabaseServiceProtocol {
  User? get user;
  Future<Session?> get currentSession;

  Future<void> initialize();
  Future<void> registerAccountEmailPassword({
    required String email,
    required String password,
  });
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> logoutUser();

  Future<List<Task>> getUserTasks();
  Future<void> createTask(Task newTask);
  Future<void> deleteTask(int taskId);
  Future<void> updateTask(Task updatedTask);
  Future<TaskCategory?> createCategory(String newCategory);
  Future<TaskCategory?> editCategory({
    required int id,
    required String newName,
  });
  Future<TaskCategory?> deleteCategory({required int id});
  Future<List<TaskCategory>> getUserCategories();

  Future<TaskMedia> uploadTaskMedia({
    required File file,
    required String fileName,
  });
  Future<TaskMedia?> editTaskMedia({
    required int taskId,
    XFile? newMediaFile,
    TaskMedia? currentMedia,
  });
  Future<void> deleteTaskMedia(int mediaId);
}

class SupabaseService extends SupabaseServiceProtocol {
  late final SupabaseClient _client;

  @override
  User? get user => _client.auth.currentSession?.user;

  @override
  Future<Session?> get currentSession async => _client.auth.currentSession;

  @override
  Future<void> initialize() async {
    final supabase = await Supabase.initialize(
      url: 'https://myzavtpabiqbhtztvwsi.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im15emF2dHBhYmlxYmh0enR2d3NpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1ODUzMDksImV4cCI6MjA2OTE2MTMwOX0.1g40at9Sresg09oQCWx241WMc5bUfG02ZTdB_MtIBZU',
    );

    _client = supabase.client;
  }

  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw AppException(
          userFriendlyMessage: 'There was an error with the request',
        );
      }
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          error: e,
          userFriendlyMessage: 'There was an error with the request',
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> registerAccountEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AppException(
          userFriendlyMessage: 'There was an error with the request',
        );
      }
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          error: e,
          userFriendlyMessage: 'There was an error with the request',
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<List<Task>> getUserTasks() async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      final response = await _client
          .from('tasks')
          .select(
            'id,title,description,status,expiry_date, category:categories(id,name), media(id,type,url,storage_path)',
          )
          .eq('user_id', user?.id ?? -1)
          .order('created_at', ascending: false);
      final tasksList = response.map((map) => Task.fromJson(map)).toList();

      tasksList.sort((a, b) {
        final aStatus = TaskStatus.values
            .where((status) => status.label == a.status)
            .firstOrNull;
        final bStatus = TaskStatus.values
            .where((status) => status.label == b.status)
            .firstOrNull;

        return aStatus?.index.compareTo(bStatus?.index ?? 0) ?? 0;
      });

      return tasksList;
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          error: e,
          userFriendlyMessage: 'There was an error with the request',
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> createTask(Task newTask) async {
    try {
      if (user == null) {
        throw AppException(userFriendlyMessage: 'User not authenticated');
      }

      final taskMap = newTask.toJson();
      taskMap['user_id'] = user?.id;

      await _client.from('tasks').insert(taskMap);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Error creating task'),
        stackTrace,
      );
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      await _client.from('tasks').delete().eq('id', taskId);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Error deleting task'),
        stackTrace,
      );
    }
  }

  @override
  Future<void> updateTask(Task updatedTask) async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      final taskMap = updatedTask.toJson();
      taskMap['user_id'] = user?.id;
      taskMap['id'] = updatedTask.id;

      await _client.from('tasks').update(taskMap).eq('id', updatedTask.id);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Error updating task'),
        stackTrace,
      );
    }
  }

  @override
  Future<List<TaskCategory>> getUserCategories() async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      final response = await _client
          .from('categories')
          .select('id, name')
          .eq('user_id', user?.id ?? -1);
      final categories = response.map((json) {
        return TaskCategory.fromJson(json);
      }).toList();

      categories.sort((a, b) => a.name.compareTo(b.name));

      return categories;
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          error: e,
          userFriendlyMessage: 'Error fetching categories',
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<TaskCategory> createCategory(String newCategory) async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      final data = {'name': newCategory, 'user_id': user?.id};

      final response = await _client
          .from('categories')
          .insert(data)
          .select('id, name')
          .single();

      return TaskCategory.fromJson(response);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Error creating category'),
        stackTrace,
      );
    }
  }

  @override
  Future<TaskCategory?> editCategory({
    required int id,
    required String newName,
  }) async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      final data = {'name': newName};

      final response = await _client
          .from('categories')
          .update(data)
          .eq('id', id)
          .select('id, name')
          .single();

      return TaskCategory.fromJson(response);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Error editting category'),
        stackTrace,
      );
    }
  }

  @override
  Future<TaskCategory?> deleteCategory({required int id}) async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      final response = await _client
          .from('categories')
          .delete()
          .eq('id', id)
          .select('id, name')
          .single();

      return TaskCategory.fromJson(response);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Error editting category'),
        stackTrace,
      );
    }
  }

  @override
  Future<void> logoutUser() async {
    try {
      await _client.auth.signOut();
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(error: e, userFriendlyMessage: 'Error signing you out'),
        stackTrace,
      );
    }
  }

  @override
  Future<TaskMedia> uploadTaskMedia({
    required File file,
    required String fileName,
  }) async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    if (await file.length() >= 1250000) {
      throw AppException(
        userFriendlyMessage:
            'Utilize um arquivo de mídia com menos de 10Mb de tamanho',
      );
    }

    try {
      final fileExt = fileName.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final mimeType = _getMimeType(fileExt);
      final filePath =
          'uploads/${timestamp}_${user?.email ?? 'anonym'}.$fileExt';

      await _client.storage
          .from(Constants.appBucketId)
          .upload(
            filePath,
            file,
            fileOptions: FileOptions(contentType: mimeType),
          );

      final publicUrl = _client.storage
          .from(Constants.appBucketId)
          .getPublicUrl(filePath);

      final mediaData = {
        'user_id': user?.id ?? -1,
        'type': mimeType,
        'url': publicUrl,
        'storage_path': filePath,
      };

      final response = await _client
          .from('media')
          .insert(mediaData)
          .select('id, type, url, storage_path')
          .single();

      return TaskMedia.fromJson(response);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          error: e,
          userFriendlyMessage: 'Error uploading media file',
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> deleteTaskMedia(int mediaId) async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'User not authenticated');
    }

    try {
      final mediaMap = await _client
          .from('media')
          .select('id, storage_path')
          .eq('id', mediaId)
          .single();

      final media = TaskMedia.fromJson(mediaMap);

      await _client.storage.from(Constants.appBucketId).remove([
        media.storagePath,
      ]);
      await _client.from('media').delete().eq('id', mediaId);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          error: e,
          userFriendlyMessage: 'Error deleting media file',
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<TaskMedia?> editTaskMedia({
    required int taskId,
    XFile? newMediaFile,
    TaskMedia? currentMedia,
  }) async {
    if (user == null) {
      throw AppException(userFriendlyMessage: 'Not authenticated');
    }

    final bucket = _client.storage.from(Constants.appBucketId);

    if (newMediaFile == null && currentMedia != null) {
      await bucket.remove([currentMedia.storagePath]);
      await _client.from('media').delete().eq('id', currentMedia.id);

      return null;
    }

    if (newMediaFile == null) return null;

    final file = File(newMediaFile.path);
    final ext = newMediaFile.name.split('.').last;
    final mime = _getMimeType(ext);
    final path = _getMediaPath(newMediaExtension: ext);

    if (currentMedia != null) {
      await bucket.update(
        path,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = bucket.getPublicUrl(path);
      final updatedMedia = await _client
          .from('media')
          .update({'type': mime, 'url': publicUrl, 'storage_path': path})
          .eq('id', currentMedia.id)
          .select()
          .single();

      return TaskMedia.fromJson(updatedMedia);
    }

    await bucket.upload(
      path,
      file,
      fileOptions: FileOptions(contentType: mime),
    );

    final publicUrl = bucket.getPublicUrl(path);
    final newMedia = await _client
        .from('media')
        .insert({
          'user_id': user?.id,
          'type': mime,
          'url': publicUrl,
          'storage_path': path,
          'task_id': taskId,
        })
        .select()
        .single();
    final media = TaskMedia.fromJson(newMedia);

    await _client.from('tasks').update({'media_id': media.id}).eq('id', taskId);

    return media;
  }

  String _getMimeType(String fileExt) {
    switch (fileExt.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      default:
        return 'application/octet-stream';
    }
  }

  String _getMediaPath({required String newMediaExtension}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return 'uploads/${timestamp}_${user?.email ?? 'anonym'}.$newMediaExtension';
  }
}
