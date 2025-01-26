import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MolePhotosPage extends StatefulWidget {
  final String moleName;
  final List<String> photos;

  const MolePhotosPage({Key? key, required this.moleName, required this.photos})
      : super(key: key);

  @override
  _MolePhotosPageState createState() => _MolePhotosPageState();
}

class _MolePhotosPageState extends State<MolePhotosPage> {
  late List<XFile> _photos;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _photos = widget.photos.map((e) => XFile(e)).toList(); // Convert string paths to XFile
  }

  Future<void> _pickImage() async {
    // Pick an image from the gallery
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _photos.add(pickedFile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moleName),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Add Mole Image'),
            ),
            const SizedBox(height: 20),
            _photos.isEmpty
                ? const Center(
                    child: Text(
                      "No photos added yet.",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(_photos[index].path),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
