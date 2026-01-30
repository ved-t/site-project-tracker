import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/expenses/data/datasources/expense_local_ds.dart';
import '../features/expenses/data/repositories/expense_repository_impl.dart';
import '../features/projects/data/datasources/project_local_ds.dart';
import '../features/projects/data/repositories/project_repository_impl.dart';
import '../features/projects/domain/usecases/add_project.dart';
import '../features/projects/domain/usecases/delete_project.dart';
import '../features/projects/domain/usecases/get_projects.dart';
import '../features/projects/presentation/controllers/project_controller.dart';
import '../theme/indigo_theme.dart';
import 'router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Project Dependencies
    final projectLocalDataSource = ProjectLocalDataSourceImpl();
    final projectRepository = ProjectRepositoryImpl(projectLocalDataSource);

    // Expense Dependencies (for DeleteProject)
    final expenseLocalDataSource = ExpenseLocalDataSource();
    final expenseRepository = ExpenseRepositoryImpl(expenseLocalDataSource);

    // UseCases
    final addProject = AddProject(projectRepository);
    final getProjects = GetProjects(projectRepository);
    final deleteProject = DeleteProject(
      projectRepository: projectRepository,
      expenseRepository: expenseRepository,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProjectController(
            addProject: addProject,
            getProjects: getProjects,
            deleteProject: deleteProject,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Expense Tracker',
        theme: professionalIndigoTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
