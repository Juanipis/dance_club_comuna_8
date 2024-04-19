import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final logger = Logger();

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    logger.d('Signing in with email and password');
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      logger.d('Sign in successful');
      return true;
    } catch (e) {
      logger.e('Sign in failed: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    logger.d('Signing out');
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    logger.d('Sending password reset email');
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
