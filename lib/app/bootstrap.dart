import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_project_tracker/firebase_options.dart';
import 'package:uuid/uuid.dart';

import '../core/services/local_storage_service.dart';
import '../features/projects/data/datasources/project_local_ds.dart';
import '../features/projects/data/repositories/project_repository_impl.dart';
import '../features/projects/domain/entities/project.dart';
import 'app.dart';

Future<void> bootstrap() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await LocalStorageService.init();

  // Initialize repository to check for default site
  final localStorage = LocalStorageService();
  final projectLocalDs = ProjectLocalDataSourceImpl(localStorage);
  final projectRepository = ProjectRepositoryImpl(projectLocalDs);

  final projects = await projectRepository.getProjects();
  if (projects.isEmpty) {
    // Create default site
    final deviceId = await localStorage.getDeviceId();
    final now = DateTime.now();
    final defaultProject = Project(
      id: const Uuid().v4(),
      name: 'General Site',
      location: 'Main Location',
      createdAt: now,
      updatedAt: now,
      deviceId: deviceId,
    );
    await projectRepository.addProject(defaultProject);
    debugPrint(
      'Default site created: ${defaultProject.name} (${defaultProject.id})',
    );
  }

  runApp(const ProviderScope(child: MyApp()));
}
