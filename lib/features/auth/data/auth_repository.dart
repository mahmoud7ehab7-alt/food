import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/features/auth/data/auth_service.dart';
import 'package:food/features/auth/domain/user_model.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user and save their data to Firestore
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.register(email, password);
      final userId = credential!.user!.uid;

      final newUser = UserModel(
        id: userId,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore.collection('users').doc(userId).set(newUser.toMap());

      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  // Get current Firebase user
  User? getCurrentUser() => _authService.currentUser;

  // Fetch user data from Firestore
  Future<UserModel> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, userId);
      } else {
        throw Exception("بيانات المستخدم غير موجودة");
      }
    } catch (e) {
      rethrow;
    }
  }

  // Login user and fetch their data from Firestore
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _authService.login(email, password);
      return await getUserData(credential!.user!.uid);
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> logout() async {
    await _authService.logout();
  }
}
