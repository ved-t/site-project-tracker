import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsign;

class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final gsign.GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource(this._firebaseAuth, this._googleSignIn);

  Future<UserCredential> signUp(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInAnonymously() {
    return _firebaseAuth.signInAnonymously();
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null)
      throw FirebaseAuthException(
        code: 'sign_in_canceled',
        message: 'Sign in canceled',
      );
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  Future<String?> getIdToken() async {
    return await _firebaseAuth.currentUser?.getIdToken(true);
  }

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> linkWithEmail(String email, String password) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    return await _firebaseAuth.currentUser!.linkWithCredential(credential);
  }

  Future<UserCredential> linkWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null)
      throw FirebaseAuthException(
        code: 'sign_in_canceled',
        message: 'Sign in canceled',
      );
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.currentUser!.linkWithCredential(credential);
  }
}
