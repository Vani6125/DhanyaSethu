import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _auth.currentUser;
      if (user != null) {
        final uid = user.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'income': '',
        });
      }

      // Update user display name and send verification email
      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        await result.user!.sendEmailVerification();

        // Don't sign out after registration - let user stay signed in
        // but verification will be required for certain actions
      }

      return AuthResult(user: result.user, success: true);
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      return AuthResult(success: false, errorMessage: message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'An unexpected error occurred');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (!result.user!.emailVerified) {
        // Don't sign out, just return error indicating verification needed
        return AuthResult(
          success: false,
          user: result.user,
          errorMessage: 'Please verify your email address first.',
          needsEmailVerification: true,
        );
      }

      return AuthResult(user: result.user, success: true);
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      return AuthResult(success: false, errorMessage: message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'An unexpected error occurred');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(success: true, errorMessage: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      return AuthResult(success: false, errorMessage: message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'An unexpected error occurred');
    }
  }

  // Resend verification email
  Future<AuthResult> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult(success: false, errorMessage: 'No user found');
      }

      await user.sendEmailVerification();
      return AuthResult(success: true, errorMessage: 'Verification email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'An unexpected error occurred');
    }
  }

  // Reload user to get updated verification status
  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
      }
    } catch (e) {
      print('Error reloading user: $e');
    }
  }

  // Check if current user's email is verified
  bool get isEmailVerified {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Force email verification check
  Future<bool> checkEmailVerified() async {
    try {
      await reloadUser();
      return isEmailVerified;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  // Get user-friendly error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}

// Result class to handle auth responses
class AuthResult {
  final User? user;
  final bool success;
  final String? errorMessage;
  final bool needsEmailVerification;

  AuthResult({
    this.user,
    required this.success,
    this.errorMessage,
    this.needsEmailVerification = false,
  });
}