import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:submission_flutter_ml/services/firebase_ml_service.dart';
import 'package:submission_flutter_ml/services/isolate_inference.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageRecognizerServices {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final FirebaseMlService _mlService;

  ImageRecognizerServices(this._mlService);

  late File modelFile;
  final labelsPath = 'assets/probability-labels-en.txt';

  late Interpreter interpreter;
  late List<String> labels;
  late Tensor inputTensor;
  late Tensor outputTensor;
  late IsolateInference isolateInference;

  Future<void> _loadModel() async {
    try {
      modelFile = await _mlService.loadModel();

      final options = InterpreterOptions()
        ..useNnApiForAndroid = true
        ..useMetalDelegateForIOS = true;

      interpreter = Interpreter.fromFile(modelFile, options: options);

      inputTensor = interpreter.getInputTensors().first;
      outputTensor = interpreter.getOutputTensors().first;
      log("Model loaded successfully from: ${modelFile.path}");
    } catch (e) {
      log("Error loading model: $e");
      rethrow;
    }
  }

  Future<void> _loadLabels() async {
    final labelTxt = await rootBundle.loadString(labelsPath);
    labels = labelTxt.split('\n');
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadModel();
      await _loadLabels();

      isolateInference = IsolateInference();
      await isolateInference.start();
      
      // Tandai inisialisasi SELESAI
      _isInitialized = true;
      log("ImageRecognizerServices: All systems initialized.");
    } catch (e) {
      log("ImageRecognizerServices: Failed to initialize: $e");
      _isInitialized = false;
      rethrow;
    }
  }

  Future<Map<String, double>> recognizeCameraFrame(CameraImage cameraImage) async {
    // PROTEKSI: Jika belum siap, jangan akses isolateInference
    if (!_isInitialized) {
      return {};
    }

    final responsePort = ReceivePort();
    isolateInference.sendPort.send(
      InferenceModel(
        cameraImage,
        null,
        interpreter.address,
        labels,
        inputTensor.shape,
        outputTensor.shape,
      )..responsePort = responsePort.sendPort,
    );

    final result = await responsePort.first;
    return result as Map<String, double>;
  }

  Future<Map<String, double>> recognizeFile(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    final responsePort = ReceivePort();
    isolateInference.sendPort.send(
      InferenceModel(
        null,
        imageFile,
        interpreter.address,
        labels,
        inputTensor.shape,
        outputTensor.shape,
      )..responsePort = responsePort.sendPort,
    );

    final result = await responsePort.first;
    log('Detection Result: $result');
    return result as Map<String, double>;
  }

  Future<void> close() async {
    if (_isInitialized) {
      await isolateInference.close();
      interpreter.close();
      _isInitialized = false;
    }
  }
}