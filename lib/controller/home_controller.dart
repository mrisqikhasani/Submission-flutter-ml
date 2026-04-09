import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

import '../services/image_recognizer_services.dart';
import '../ui/camera_page.dart';
import '../ui/result_page.dart';
import 'result_controller.dart';

class HomeController extends ChangeNotifier {
  final ImageRecognizerServices _recognizerServices;

  HomeController(
    this._recognizerServices,
  ) {
    _recognizerServices.initialize();
  }

  final ImagePicker _picker = ImagePicker();

  File? _image;
  File? get image => _image;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

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

  Future<void> pickFromGallery() async => _pickImage(ImageSource.gallery);
  Future<void> pickFromCamera() async => _pickImage(ImageSource.camera);

  Future<void> _pickImage(ImageSource source) async {
    try {
      _setLoading(true);
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        await _handleImagePipeline(File(picked.path));
      }
    } catch (e) {
      _setError("Gagal mengambil gambar: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleImagePipeline(File file) async {
    resetState();
    final cropped = await _cropImage(file);
    _image = cropped ?? file;
    notifyListeners();
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

  
  Future<void> openCustomCamera(BuildContext context) async {
    final XFile? capturedFile = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );

    if (capturedFile != null) {
      await _handleImagePipeline(File(capturedFile.path));
      if (context.mounted) goToResultPage(context);
    }
  }

  Future<void> goToResultPage(BuildContext context) async {
    if (_image == null) return;

    try {
      _setLoading(true);
      _setError(null);

      // 1. TFLite Classification
      if (!_recognizerServices.isInitialized) await _recognizerServices.initialize();
      final results = await _recognizerServices.recognizeFile(_image!);

      if (results.isEmpty) {
        _setError("Makanan tidak terdeteksi.");
        return;
      }

      final topResult = (results.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first;

      // 2. Gemini Nutrition Analysis
      if (context.mounted) {
        await context.read<ResultController>().analyzeNutrition(topResult.key);
      }

      // 3. Navigation
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultPage(
              imagePath: _image!.path,
              labelResult: topResult.key,
              scoreResult: topResult.value,
            ),
          ),
        );
      }
    } catch (e) {
      log("Navigation Error: $e");
      _setError("Gagal menganalisis: $e");
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
}