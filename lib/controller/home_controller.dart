import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:submission_flutter_ml/ui/result_page.dart';
// import 'package:submission_flutter_ml/ui/camera_page.dart';

class HomeController extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  File? _image;
  bool _isLoading = false;
  String? _error;

  File? get image => _image;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ======================
  // STATE
  // ======================
  void _setImage(File file) {
    _image = file;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void resetState() {
    _error = null;
    notifyListeners();
  }

  // ======================
  // IMAGE PICKER
  // ======================
  Future<void> pickFromGallery() async {
    try {
      _setLoading(true);

      final picked = await _picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        await _handleImage(File(picked.path));
      }
    } catch (e) {
      _setError("Failed to pick image");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pickFromCamera() async {
    try {
      _setLoading(true);

      final picked = await _picker.pickImage(source: ImageSource.camera);

      if (picked != null) {
        await _handleImage(File(picked.path));
      }
    } catch (e) {
      _setError("Failed to open camera");
    } finally {
      _setLoading(false);
    }
  }

  // ======================
  // CUSTOM CAMERA (🔥 4 PTS)
  // ======================
  // Future<void> openCustomCamera(BuildContext context) async {
  //   final XFile? result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => const CameraPage()),
  //   );

  //   if (result != null) {
  //     await _handleImage(File(result.path));
  //   }
  // }

  // ======================
  // IMAGE PIPELINE
  // ======================
  Future<void> _handleImage(File file) async {
    resetState();

    final cropped = await _cropImage(file);

    if (cropped != null) {
      _setImage(cropped);
    } else {
      _setImage(file);
    }
  }

  Future<File?> _cropImage(File file) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    return cropped != null ? File(cropped.path) : null;
  }

  // ======================
  // NAVIGATION
  // ======================
  void goToResultPage(BuildContext context) {
    if (_image == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(imagePath: _image!.path),
      ),
    );
  }
}