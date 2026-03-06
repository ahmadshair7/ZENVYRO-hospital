import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initUser();
  }

  void _initUser() async {
    _auth.authStateChanges().listen((firebase_auth.User? user) async {
      _errorMessage = null;
      if (user != null) {
        await _fetchUserDetails(user.uid);
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserDetails(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data()!);
      } else {
        _userModel = null;
        _errorMessage = "User record not found in database.";
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      _userModel = null;
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> retryFetch() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _fetchUserDetails(user.uid);
    }
  }

  Future<void> updateUserDetails(UserModel updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _db.collection('users').doc(updatedUser.uid).set(updatedUser.toMap());
      _userModel = updatedUser;
    } catch (e) {
      debugPrint('Error updating user details: $e');
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }
}
