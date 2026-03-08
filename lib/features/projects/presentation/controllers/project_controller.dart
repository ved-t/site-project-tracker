import 'package:flutter/material.dart';
import 'package:site_project_tracker/core/services/sync_manager.dart';
import '../../../../core/utils/dio_error_handler.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/add_project.dart';
import '../../domain/usecases/get_projects.dart';
import '../../domain/usecases/delete_project.dart';
import '../../domain/usecases/update_project.dart';

class ProjectController extends ChangeNotifier {
  final AddProject addProject;
  final GetProjects getProjects;
  final DeleteProject deleteProject;
  final UpdateProject updateProject;

  final SyncManager syncManager;

  ProjectController({
    required this.addProject,
    required this.getProjects,
    required this.deleteProject,
    required this.updateProject,
    required this.syncManager,
  });

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  Future<void> loadProjects() async {
    try {
      _projects = await getProjects();
      notifyListeners();
    } catch (e) {
      AppLogger.error(
        'Failed to load projects',
        error: e,
        name: 'PROJECT_CTRL',
      );
      final msg = DioErrorHandler.getErrorMessage(e);
      ToastUtils.show(msg, isError: true);
    }
  }

  Future<void> createProject(Project project) async {
    try {
      await addProject(project);
      await loadProjects();
      await syncManager.sync();
    } catch (e) {
      AppLogger.error(
        'Failed to create project',
        error: e,
        name: 'PROJECT_CTRL',
      );
      final msg = DioErrorHandler.getErrorMessage(e);
      ToastUtils.show(msg, isError: true);
    }
  }

  Future<void> editProject(Project project) async {
    try {
      await updateProject(project);
      await loadProjects();
      await syncManager.sync();
    } catch (e) {
      AppLogger.error(
        'Failed to update project',
        error: e,
        name: 'PROJECT_CTRL',
      );
      final msg = DioErrorHandler.getErrorMessage(e);
      ToastUtils.show(msg, isError: true);
    }
  }

  Future<void> removeProject(String siteId) async {
    try {
      await deleteProject(siteId);
      await loadProjects();
      await syncManager.sync();
    } catch (e) {
      AppLogger.error(
        'Failed to remove project',
        error: e,
        name: 'PROJECT_CTRL',
      );
      final msg = DioErrorHandler.getErrorMessage(e);
      ToastUtils.show(msg, isError: true);
    }
  }
}
