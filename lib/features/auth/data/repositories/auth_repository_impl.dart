import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  AppUser _mapUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      isAnonymous: user.isAnonymous,
      providers: user.providerData
          .map((provider) => provider.providerId)
          .toList(),
    );
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final result = await dataSource.signIn(email, password);
    return _mapUser(result.user!);
  }

  @override
  Future<AppUser> signUpWithEmail(String email, String password) async {
    final result = await dataSource.signUp(email, password);
    return _mapUser(result.user!);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final result = await dataSource.signInWithGoogle();
    return _mapUser(result.user!);
  }

  @override
  Future<AppUser> signInAnonymously() async {
    final result = await dataSource.signInAnonymously();
    return _mapUser(result.user!);
  }

  @override
  Future<void> signOut() => dataSource.signOut();

  @override
  Future<String?> getIdToken() => dataSource.getIdToken();

  @override
  Stream<AppUser?> authStateChanges() {
    return dataSource.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapUser(user);
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return dataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<AppUser> linkWithEmail(String email, String password) async {
    final result = await dataSource.linkWithEmail(email, password);
    return _mapUser(result.user!);
  }

  @override
  Future<AppUser> linkWithGoogle() async {
    final result = await dataSource.linkWithGoogle();
    return _mapUser(result.user!);
  }

  @override
  Future<void> changePassword(
      String currentPassword,
      String newPassword) {
    return dataSource.changePassword(
        currentPassword, newPassword);
  }
}
