import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      rethrow; // Pass error to UI to show message
    }
  }

  // Register with email, password, and additional details
  Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Save user details in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'client', // Default role
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return result;
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  // Verify Phone Number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution (Android only)
        // We typically don't sign in automatically here for this flow
        // because we want to link email/pass, but we can store it.
      },
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  // Create PhoneAuthCredential from SMS Code
  PhoneAuthCredential getPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  // Register User with Phone Verification and Email/Password
  Future<UserCredential?> registerUserWithPhoneAndEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // 1. Create Phone Credential
      PhoneAuthCredential phoneCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // 2. Sign in with Phone first (to verify ownership)
      UserCredential phoneUserCredential = await _auth.signInWithCredential(
        phoneCredential,
      );
      User? tempUser = phoneUserCredential.user;

      if (tempUser != null) {
        // 3. Link Email/Password Credential
        AuthCredential emailCredential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );

        UserCredential finalCredential = await tempUser.linkWithCredential(
          emailCredential,
        );
        User? finalUser = finalCredential.user;

        if (finalUser != null) {
          // 4. Save user details in Firestore
          await _firestore.collection('users').doc(finalUser.uid).set({
            'uid': finalUser.uid,
            'name': name,
            'email': email,
            'phone': phone,
            'role': 'client',
            'createdAt': FieldValue.serverTimestamp(),
          });
          return finalCredential;
        }
      }
      return null;
    } catch (e) {
      print('Error registering user with phone: $e');
      rethrow;
    }
  }

  // Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      // Re-authenticate first
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
