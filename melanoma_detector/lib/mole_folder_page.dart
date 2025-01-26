import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MoleFolderPage extends StatefulWidget {
  @override
  _MoleFolderPageState createState() => _MoleFolderPageState();
}

class _MoleFolderPageState extends State<MoleFolderPage> {
  final _folderNameController = TextEditingController();

  // Get current user's UID
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to create a new folder
  Future<void> _createFolder(String folderName) async {
    try {
      // Reference to the user's mole_folders subcollection
      final userMoleFolderRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('mole_folders')
          .doc(folderName);

      // Set the folder data (you can add more fields here)
      await userMoleFolderRef.set({
        'folderName': folderName,
        'createdAt': Timestamp.now(),
        'images': [], // Initially empty image array
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Folder '$folderName' created!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create folder: $e")),
      );
    }
  }

  // Function to add a photo to a folder
  Future<void> _addPhoto(String folderName, String imageUrl) async {
    try {
      // Reference to the folder document
      final folderRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('mole_folders')
          .doc(folderName);

      // Add image URL to the images array
      await folderRef.update({
        'images': FieldValue.arrayUnion([imageUrl]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Photo added to $folderName!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add photo: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mole Folders')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _folderNameController,
              decoration: InputDecoration(
                labelText: 'Folder Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _createFolder(_folderNameController.text.trim());
              },
              child: Text('Create Folder'),
            ),
            // You can display the list of folders here (optional)
          ],
        ),
      ),
    );
  }
}