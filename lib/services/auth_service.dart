import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Signup a new user
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String role = 'patient',
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Store user details in Firestore
        final user = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
          role: role,
        );

        await _db.collection('users').doc(user.uid).set(user.toMap());

        return {
          'status': true,
          'message': 'Registration successful',
        };
      }
      return {
        'status': false,
        'message': 'Signup failed',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'status': false,
        'message': e.message ?? 'Signup failed',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  /// Login an existing user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Fetch user details from Firestore
        DocumentSnapshot userDoc;
        try {
          userDoc = await _db.collection('users').doc(credential.user!.uid).get();
        } catch (e) {
          // If Firestore is locked, just continue as a placeholder patient 
          // or throw specific error based on project needs
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'Firestore permission error. Please check your security rules.',
          );
        }

        if (!userDoc.exists) {
          final user = UserModel(
            uid: credential.user!.uid,
            name: credential.user!.displayName ?? 'User',
            email: email,
            role: 'patient',
          );
          await _db.collection('users').doc(user.uid).set(user.toMap());
        }

        return {
          'status': true,
          'message': 'Login successful',
          'user': {
            'name': credential.user!.displayName,
            'email': email,
          }
        };
      }
      return {
        'status': false,
        'message': 'Login failed',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'status': false,
        'message': e.message ?? 'Login failed',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  /// Get logged in user name
  Future<String?> getUserName() async {
    return _auth.currentUser?.displayName;
  }

  /// Get current user ID
  String? get currentUid => _auth.currentUser?.uid;

  /// Logout the user
  Future<void> logout() async {
    await _auth.signOut();
  }
}
