import 'package:flutter/material.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/add_project.dart';
import '../../domain/usecases/get_projects.dart';
import '../../domain/usecases/delete_project.dart';

class ProjectController extends ChangeNotifier {
  final AddProject addProject;
  final GetProjects getProjects;
  final DeleteProject deleteProject;

  ProjectController({
    required this.addProject,
    required this.getProjects,
    required this.deleteProject,
  });

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  Future<void> loadProjects() async {
    _projects = await getProjects();
    notifyListeners();
  }

  Future<void> createProject(Project project) async {
    await addProject(project);
    await loadProjects();
  }

  Future<void> removeProject(String siteId) async {
    await deleteProject(siteId);
    await loadProjects();
  }
}
