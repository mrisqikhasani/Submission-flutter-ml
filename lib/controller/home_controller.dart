import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:submission_flutter_ml/services/image_recognizer_services.dart';
import 'package:submission_flutter_ml/ui/result_page.dart';
// import 'package:submission_flutter_ml/ui/camera_page.dart';

class HomeController extends ChangeNotifier {
  final ImageRecognizerServices _services;

  HomeController(this._services) {
    _services.initialize();
  }

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
  Future<void> goToResultPage(BuildContext context) async {
    if (_image == null) return;

    try {
      _setLoading(true);
      _setError(null);

      // 1. Jalankan Isolate Inference lewat service
      final results = await _services.recognizeFile(_image!);

      if (results.isEmpty) {
        _setError("Makanan tidak terdeteksi. Coba foto lebih jelas.");
        return;
      }

      // 2. LOGIKA: Mencari skor tertinggi (Best Practice: Olah di Controller)
      final sorted = results.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topResult = sorted.first;
      final String label = topResult.key; // Ambil Nama Makanan
      final double score = topResult.value; // Ambil Confidence Score

      log('Best Result: $label with score $score');

      // 3. Navigasi: Kirim variabel label dan score saja ke ResultPage
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultPage(
              imagePath: _image!.path,
              labelResult: label,
              scoreResult: score,
            ),
          ),
        );
      }
    } catch (e) {
      log("Error during navigation logic: $e");
      _setError("Gagal menganalisis gambar: $e");
    } finally {
      _setLoading(false);
    }
  }
}
