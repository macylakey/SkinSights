import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For decoding JSON responses
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/profile_page.dart';
import 'screens/book_appointment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          colorScheme: ColorScheme.highContrastLight(
              primary: const Color.fromARGB(255, 0, 0, 0))),
      home: MyHomePage(title: 'SkinSights', cameras: cameras),
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

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5) // Grid line color
      ..strokeWidth = 2.0;

    // Draw horizontal grid lines
    for (int i = 1; i < 3; i++) {
      double y = i * (size.height / 3); // 4 horizontal lines
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical grid lines
    for (int i = 1; i < 3; i++) {
      double x = i * (size.width / 3); // 4 vertical lines
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  XFile? _selectedImage;
  bool _isLoading = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> toggleFlash() async {
    try {
      if (_cameraController.value.isInitialized) {
        if (_isFlashOn) {
          await _cameraController.setFlashMode(FlashMode.off);
        } else {
          await _cameraController.setFlashMode(FlashMode.torch);
        }
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling flash: $e')),
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      setState(() {
        _selectedImage = image;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    }
  }

  Future<void> uploadImageToBackend() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('http://192.168.1.45:5000/predict');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('image', _selectedImage!.path),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);

        final result = jsonResponse['result'];
        if (result == null || result.isEmpty) {
          throw Exception('Result is null or empty.');
        }

        setState(() {
          _isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultsPage(result: result, selectedImage: _selectedImage),
          ),
        );
      } else {
        throw Exception('Failed to get a valid response from the backend.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 225, 122, 0),
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: TextStyle(
            fontFamily: 'ArimoHebrew', // Specify the custom font
            fontWeight: FontWeight.bold, // Make it bold
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: toggleFlash,
            color: _isFlashOn ? Colors.yellow : Colors.white,
          ),
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
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(userName: 'mj@mail.com'),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Skinsights',
                        style: TextStyle(
                          fontFamily: 'ArimoHebrew', // Custom font
                          fontWeight: FontWeight.bold, // Bolded font
                          fontSize: 48, // Font size
                          color: const Color.fromARGB(
                              255, 225, 122, 0), // Text color
                        ),
                      ),
                      SizedBox(width: 10),
                      Image.asset(
                        'assets/Skinsights_Mascot-ezgif.com-webp-to-jpg-converter.jpg',
                        width: 80, // Adjust the width of the mascot image
                        height: 80, // Adjust the height of the mascot image
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color.fromARGB(255, 225, 122, 0),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Center(
                          child: Stack(
                            children: [
                              // Camera Preview
                              GestureDetector(
                                onTapDown: (TapDownDetails details) async {
                                  if (_cameraController.value.isInitialized) {
                                    final RenderBox box =
                                        context.findRenderObject() as RenderBox;
                                    final Offset offset = box.globalToLocal(
                                        (details.globalPosition));
                                    final Size size = box.size;

                                    //tap to coord
                                    final double dx = offset.dx / size.width;
                                    final double dy = offset.dy / size.height;

                                    try {
                                      await _cameraController
                                          .setFocusPoint(Offset(dx, dy));
                                      await _cameraController
                                          .setFocusMode(FocusMode.auto);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text('Focus error: $e')));
                                    }
                                  }
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  child: CameraPreview(_cameraController),
                                ),
                              ),
                              CustomPaint(
                                size: Size(
                                  MediaQuery.of(context).size.width / 1.5,
                                  MediaQuery.of(context).size.height / 3,
                                ),
                                painter: GridPainter(),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: pickImageFromGallery,
                      child: const Text("Pick Image from Gallery"),
                    ),
                    ElevatedButton(
                      onPressed: takePicture,
                      child: const Text("Take Picture"),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                if (_selectedImage != null)
                  Column(
                    children: [
                      Image.file(
                        File(_selectedImage!.path),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: uploadImageToBackend,
                        child: const Text("Submit Image"),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
              ],
            ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final String result;
  final XFile? selectedImage;

  const ResultsPage({super.key, required this.result, this.selectedImage});

  // Modify the result message based on the updated requirements
  String getResultMessage(double resultValue) {
    if (resultValue < 10) {
      return "The analysis suggests everything is likely okay. However, always stay mindful of any changes.";
    } else if (resultValue >= 10 && resultValue <= 40) {
      return "There are some indications to be cautious about. It may be worth consulting a healthcare professional for further evaluation.";
    } else {
      return "The analysis shows significant signs of concern. We strongly recommend seeking advice from a medical professional.";
    }
  }

  @override
  Widget build(BuildContext context) {
    double resultValue;
    try {
      resultValue = double.parse(result.replaceAll('%', '').trim());
    } catch (e) {
      resultValue = -1;
    }

    String message = resultValue >= 0
        ? getResultMessage(resultValue)
        : "Unable to interpret the result. Please try again.";

    // Determine the text color based on resultValue
    Color resultColor;
    String resultLabel;
    if (resultValue < 10) {
      resultColor = Colors.green;
      resultLabel = 'Benign';
    } else if (resultValue >= 10 && resultValue <= 40) {
      resultColor = const Color.fromARGB(255, 167, 154, 36); // Yellowish color
      resultLabel = 'Unlikely Melanoma';
    } else {
      resultColor = Colors.red;
      resultLabel = 'Likely Melanoma';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bulleted list of things to look out for and prevent
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Things to Look Out For and How to Prevent:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    leading: Icon(Icons.check, color: Colors.black),
                    title: Text(
                        'Monitor any moles or birthmarks for changes in size, shape, or color. Irregular borders, multiple colors, or an increase in size can be warning signs.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.check, color: Colors.black),
                    title: Text(
                        'Apply broad-spectrum sunscreen with an SPF of 30 or higher, and reapply every two hours, especially when outdoors.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.check, color: Colors.black),
                    title: Text(
                        'The UV radiation from tanning beds can significantly increase the risk of skin cancer, including melanoma.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Display the submitted image
            Image.file(
              File(selectedImage!.path),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            // Display the analysis result label (Benign, Unlikely Melanoma, Likely Melanoma)
            Text(
              'Analysis Result: $resultLabel',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Display the message
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: resultColor, // Set the text color based on result
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Buttons for appointment and folder options
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the book appointment page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookAppointmentPage()),
                    );
                  },
                  child: const Text("Book Appointment"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle adding to folder or creating a new folder
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Log your Mole"),
                          content: const Text(
                              "Would you like to add this image to an existing folder or create a new folder?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                // Handle add to existing folder
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ));
                                // Add logic here to handle adding to an existing folder
                              },
                              child: const Text("Add to Existing Folder"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Handle create a new folder
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ));
                              },
                              child: const Text("Create New Folder"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text("Manage Folders"),
                ),
              ],
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
