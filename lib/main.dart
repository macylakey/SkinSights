import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img; // For resizing
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File handling
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'screens/login_page.dart';
import 'screens/profile_page.dart';
import 'screens/book_appointment.dart';
import 'camera_img_funcs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // This is the generated Firebase configuration
  );
  // Get available cameras
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinSights',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0091FF)),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final List<CameraDescription> cameras;

  const MyHomePage({super.key, required this.title, required this.cameras});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  XFile? _capturedImage;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();

    // Initialize the camera
    _cameraController = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _cameraController!.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookAppointmentPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle), // Profile icon
            onPressed: () {
              // Navigate to the profile page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(userName: 'mj@mail.com'), // Pass user name or data
                ),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Once the camera is initialized, display the camera preview
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300, // Set width for square
                    height: 300, // Set height for square
                    child: AspectRatio(
                      aspectRatio: _cameraController.value.aspectRatio,
                      child: CameraPreview(_cameraController),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: captureImage,
                    child: const Text("Capture Image"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pickImageFromGallery,
                    child: const Text("Pick Image from Gallery"),
                  ),
                  const SizedBox(height: 20),
                  _selectedImage != null
                      ? Image.file(
                          File(_selectedImage!.path),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            );
          } else {
            // Show a loading indicator while the camera is initializing
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }


  void _submitImage() {
    if (_capturedImage != null) {
      print("Image submitted: ${_capturedImage!.path}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image submitted successfully!")),
      );
    }
  }
}
