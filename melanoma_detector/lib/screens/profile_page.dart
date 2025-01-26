import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'mole_photos_page.dart';
import '../camera_img_funcs.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final String userName;

  const ProfilePage({Key? key, required this.userName}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Declare the Firestore instance and current user
  final Map<String, List<String>> moles = {
    "Mole 1": ["assets/mole4_1.png", "assets/mole4_2.png"],
    "Mole 2": ["assets/mole2.jpeg"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.userName}'s Profile"),
        backgroundColor: const Color.fromARGB(255, 225, 122, 0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Moles",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: moles.keys.length,
                itemBuilder: (context, index) {
                  String moleName = moles.keys.elementAt(index);
                  return ListTile(
                    title: Text(moleName),
                    leading: const Icon(Icons.folder, color: Colors.blueGrey),
                    trailing: IconButton(
                      icon: const Icon(Icons.add, color: Colors.blue),
                      onPressed: () => _addPhoto(context, moleName),
                    ),
                    onTap: () => _viewMolePhotos(context, moleName),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add New Mole"),
                onPressed: _addNewMole,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add a new mole folder
  void _addNewMole() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController moleNameController = TextEditingController();
        return AlertDialog(
          title: const Text("Add New Mole"),
          content: TextField(
            controller: moleNameController,
            decoration: const InputDecoration(hintText: "Enter mole name"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Add"),
              onPressed: () {
                setState(() {
                  moles[moleNameController.text] = [];
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // View photos of a specific mole
  void _viewMolePhotos(BuildContext context, String moleName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MolePhotosPage(
          moleName: moleName,
          photos: moles[moleName]!,
        ),
      ),
    );
  }

  // Add a photo to a specific mole
  void _addPhoto(BuildContext context, String moleName) async {
  try {
    // Call the image picker or capture function
    final XFile? pickedImage = await pickImageFromGallery(); // Or call `_captureImage()` if needed

    if (pickedImage != null) {
      setState(() {
        // Add the file path of the picked or captured image to the mole folder
        moles[moleName]?.add(pickedImage.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Photo added to $moleName!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No photo was selected or captured.")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to add photo: $e")),
    );
  }
}

}
