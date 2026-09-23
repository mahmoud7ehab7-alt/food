import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:food/features/auth/domain/user_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Update user text data (Name, Phone)
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Upload image to Firebase Storage and get URL
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('users').child(userId).child('profile.jpg');
      
      // Upload file
      await ref.putFile(imageFile);
      
      // Get download URL
      final url = await ref.getDownloadURL();
      
      // Update Firestore with the new URL
      await updateProfile(userId, {'profileImage': url});
      
      return url;
    } catch (e) {
      rethrow;
    }
  }

  // Stream user data for real-time profile updates
  Stream<UserModel> streamUserData(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, userId);
      } else {
        throw Exception("User not found");
      }
    });
  }
}
