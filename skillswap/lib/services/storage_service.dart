import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(File image, String userId) async {
    try {
      // Create a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child('profile_images/$userId/profile_$timestamp.jpg');
      
      // Set metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': timestamp.toString(),
        },
      );

      // Upload file
      final uploadTask = ref.putFile(image, metadata);
      final snapshot = await uploadTask;
      
      // Return download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    try {
      // List all files in the user's profile images folder
      final ref = _storage.ref().child('profile_images/$userId');
      final result = await ref.listAll();
      
      // Delete all files (in case there are multiple)
      for (final item in result.items) {
        await item.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}