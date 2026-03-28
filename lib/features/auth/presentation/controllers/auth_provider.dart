import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:site_project_tracker/core/utils/toast_utils.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AppUser? _user;
  bool _isLoading = false;

  AuthProvider(this.repository) {
    repository.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }   

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      _user = await repository.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      ToastUtils.show('Login failed: ${e.toString()}', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      _user = await repository.signUpWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      ToastUtils.show('Sign up failed: ${e.toString()}', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      _user = await repository.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      ToastUtils.show('Google sign in failed: ${e.toString()}', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginAsGuest() async {
    try {
      _isLoading = true;
      notifyListeners();
      _user = await repository.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      ToastUtils.show('Guest login failed: ${e.toString()}', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'invalid-credential':
        message = 'Invalid email or password.';
        break;
      case 'user-not-found':
        message = 'No user found for that email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        message = 'The account already exists for that email.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'sign_in_canceled':
        message = 'Sign in process was canceled.';
        break;
      default:
        message = 'Authentication failed: ${e.message ?? e.code}';
    }
    ToastUtils.show(message, isError: true);
  }

  Future<void> logout() async {
    await repository.signOut();
  }

  Future<String?> getToken() => repository.getIdToken();

  Future<void> forgotPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      await repository.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      ToastUtils.show('Password reset failed: ${e.toString()}', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> upgradeWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      _user = await repository.linkWithEmail(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      ToastUtils.show('Upgrade failed: ${e.toString()}', isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> upgradeWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      _user = await repository.linkWithGoogle();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      ToastUtils.show('Upgrade failed: ${e.toString()}', isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      await repository.changePassword(currentPassword, newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      ToastUtils.show('Password update failed: ${e.toString()}', isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
