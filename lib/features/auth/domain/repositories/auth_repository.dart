import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUpWithEmail(String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInAnonymously();
  Future<void> signOut();
  Future<String?> getIdToken();
  Stream<AppUser?> authStateChanges();
  Future<void> sendPasswordResetEmail(String email);
  Future<AppUser> linkWithEmail(String email, String password);
  Future<AppUser> linkWithGoogle();
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  );
}
