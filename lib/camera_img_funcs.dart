import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

// Global variables for camera handling
CameraController? _cameraController;
Future<void>? _initializeControllerFuture;

// Initialize the camera
Future<void> initializeCamera(List<CameraDescription> cameras) async {
  if (cameras.isNotEmpty) {
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _cameraController!.initialize();
  } else {
    throw Exception("No cameras found.");
  }
}

// Capture an image with the camera
Future<XFile?> captureImage() async {
  try {
    await _initializeControllerFuture;
    final image = await _cameraController!.takePicture();
    return XFile(image.path);
  } catch (e) {
    print("Error capturing image: $e");
    return null;
  }
}

// Resize an image to 299x299
Future<XFile?> resizeImage(File imageFile) async {
  final rawImage = img.decodeImage(await imageFile.readAsBytes());
  if (rawImage == null) {
    throw Exception("Unable to decode image.");
  }

  final resizedImage = img.copyResize(rawImage, width: 299, height: 299);
  final resizedFilePath = "${imageFile.path}_resized.jpg";
  File(resizedFilePath).writeAsBytesSync(img.encodeJpg(resizedImage));

  return XFile(resizedFilePath);
}

// Pick an image from the gallery
Future<XFile?> pickImageFromGallery() async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: ImageSource.gallery);
  return pickedImage;
}

// Dispose of the camera controller
void disposeCamera() {
  _cameraController?.dispose();
}
