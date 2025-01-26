import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Method to add data to Firestore
  Future<void> addUser(String name, String email) async {
    try {
      await _db.collection('users').add({
        'name': name,
        'email': email,
      });
      print("User added successfully");
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  // Method to get users from Firestore
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      QuerySnapshot snapshot = await _db.collection('users').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error getting users: $e");
      return [];
    }
  }
}
