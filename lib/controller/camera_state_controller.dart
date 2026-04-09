import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/image_recognizer_services.dart';

class CameraStateController extends ChangeNotifier {
  final ImageRecognizerServices _recognizerServices;

  CameraStateController(this._recognizerServices);

  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  Map<String, double> _cameraResults = {};
  Map<String, double> get cameraResults => _cameraResults;

  bool _isCameraInitialized = false;
  bool get isCameraInitialized => _isCameraInitialized;

  bool _isProcessingCameraImage = false;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _cameraController!.initialize();
      _isCameraInitialized = true;
      notifyListeners();

      _cameraController!.startImageStream((CameraImage image) {
        if (_isProcessingCameraImage || !_recognizerServices.isInitialized) return;

        _isProcessingCameraImage = true;
        _runClassificationCamera(image).then((_) {
          _isProcessingCameraImage = false;
        });
      });
    } catch (e) {
      log("Camera Error: $e");
    }
  }

  Future<void> _runClassificationCamera(CameraImage cameraImage) async {
    _cameraResults = await _recognizerServices.recognizeCameraFrame(cameraImage);
    notifyListeners();
  }

  void disposeCamera() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _cameraController = null;
    _isCameraInitialized = false;
    _cameraResults.clear();
  }

  Future<XFile?> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return null;
    try {
      return await _cameraController!.takePicture();
    } catch (e) {
      log("Capture Error: $e");
      return null;
    }
  }
}