import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register new user
  Future<UserModel?> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        role: AppConstants.roleUser,
        createdAt: DateTime.now(),
      );

      try {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());
        print('User document created successfully: ${userCredential.user!.uid}');
      } catch (firestoreError) {
        print('Error creating user document: $firestoreError');
        // Still return the user even if Firestore write fails
        // The user is already created in Firebase Auth
        throw Exception('Failed to create user document in Firestore: $firestoreError');
      }

      return newUser;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Login user
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(userCredential.user!.uid, doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(uid, doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    try {
      UserModel? user = await getUserData(uid);
      return user?.isAdmin ?? false;
    } catch (e) {
      return false;
    }
  }
}

