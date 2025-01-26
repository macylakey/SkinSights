import 'package:flutter/material.dart';

class MolePhotosPage extends StatelessWidget {
  final String moleName;
  final List<String> photos;

  const MolePhotosPage({Key? key, required this.moleName, required this.photos})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(moleName),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: photos.isEmpty
            ? const Center(
                child: Text(
                  "No photos added yet.",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    photos[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
      ),
    );
  }
}
