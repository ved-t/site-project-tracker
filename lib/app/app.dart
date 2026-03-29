import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide Provider, ChangeNotifierProvider;
import 'package:google_sign_in/google_sign_in.dart' as gsign;
import '../core/services/local_storage_service.dart';
import '../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/controllers/auth_provider.dart';
import '../core/services/sync_providers.dart';
import '../core/utils/logger.dart';
import '../features/expenses/data/datasources/expense_local_ds.dart';
import '../features/expenses/data/repositories/expense_repository_impl.dart';
import '../features/projects/data/datasources/project_local_ds.dart';
import '../features/projects/data/repositories/project_repository_impl.dart';
import '../features/projects/domain/usecases/add_project.dart';
import '../features/projects/domain/usecases/delete_project.dart';
import '../features/projects/domain/usecases/get_projects.dart';
import '../features/projects/domain/usecases/update_project.dart';
import '../features/projects/presentation/controllers/project_controller.dart';
import '../theme/indigo_theme.dart';
import '../core/utils/toast_utils.dart';
import 'router.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final LocalStorageService _localStorageService;
  late final AuthProvider _authProvider;

  late final ProjectRepositoryImpl _projectRepository;
  late final ExpenseRepositoryImpl _expenseRepository;

  @override
  void initState() {
    super.initState();

    // Infrastructure
    _localStorageService = LocalStorageService();
    final firebaseAuth = firebase_auth.FirebaseAuth.instance;
    final googleSignIn = gsign.GoogleSignIn();

    // Auth Dependencies
    final authDataSource = FirebaseAuthDataSource(firebaseAuth, googleSignIn);
    final authRepository = AuthRepositoryImpl(authDataSource);
    _authProvider = AuthProvider(authRepository);

    // Project Dependencies
    final projectLocalDataSource = ProjectLocalDataSourceImpl(
      _localStorageService,
    );
    _projectRepository = ProjectRepositoryImpl(projectLocalDataSource);

    // Expense Dependencies
    final expenseLocalDataSource = ExpenseLocalDataSource(_localStorageService);
    _expenseRepository = ExpenseRepositoryImpl(expenseLocalDataSource);

    // Schedule sync after the first frame to ensure providers are ready
    // We add a small extra delay to ensure the initial route has built its Scaffold
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          AppLogger.sync('App Started - Triggering initial sync');
          ref.read(syncManagerProvider).sync();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get SyncManager for ProjectController
    final syncManager = ref.read(syncManagerProvider);

    // UseCases
    final addProject = AddProject(_projectRepository);
    final getProjects = GetProjects(_projectRepository);
    final deleteProject = DeleteProject(
      projectRepository: _projectRepository,
      expenseRepository: _expenseRepository,
    );
    final updateProject = UpdateProject(_projectRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        Provider<LocalStorageService>.value(value: _localStorageService),
        ChangeNotifierProvider(
          create: (_) => ProjectController(
            addProject: addProject,
            getProjects: getProjects,
            deleteProject: deleteProject,
            updateProject: updateProject,
            syncManager: syncManager,
          ),
        ),
      ],
      child: MaterialApp.router(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        title: 'Expense Tracker',
        theme: professionalIndigoTheme,
        routerConfig: createRouter(_authProvider, _localStorageService),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
