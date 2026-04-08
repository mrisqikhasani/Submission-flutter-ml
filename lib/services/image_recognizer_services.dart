import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:submission_flutter_ml/services/firebase_ml_service.dart';
import 'package:submission_flutter_ml/services/isolate_inference.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageRecognizerServices {
  // final FirebaseMlService _mlService;

  // ImageRecognizerServices(this._mlService);

  final modelPath = 'assets/vision-classifier-food-v1.tflite';
  // late final File modelFile;
  final labelsPath = 'assets/probability-labels-en.txt';

  late Interpreter interpreter;
  late List<String> labels;
  late Tensor inputTensor;
  late Tensor outputTensor;
  late final IsolateInference isolateInference;


  Future<void> _loadModel() async {
    // modelFile = await _mlService.loadModel();

    final options = InterpreterOptions()
    ..useNnApiForAndroid = true
    ..useMetalDelegateForIOS  = true;

    // interpreter =  Interpreter.fromFile(modelFile, options: options);
    interpreter =  await Interpreter.fromAsset(modelPath, options: options);

    inputTensor = interpreter.getInputTensors().first;
    outputTensor = interpreter.getOutputTensors().first;
  }

  Future<void> _loadLabels() async {
     final labelTxt = await rootBundle.loadString(labelsPath);
     labels = labelTxt.split('\n');
  }

  Future<void> initialize() async {
    await _loadModel();
     await _loadLabels();

     isolateInference = IsolateInference();
     await isolateInference.start();
  }

  Future<Map<String, double>> recognize(CameraImage cameraImage) async {
    final responsePort = ReceivePort();
    isolateInference.sendPort.send(InferenceModel(
      cameraImage, 
      null, 
      interpreter.address,
      labels,
      inputTensor.shape,
      outputTensor.shape,
    )..responsePort = responsePort.sendPort);

    final result = await responsePort.first;
    return result as Map<String, double>;
  }

  Future<Map<String, double>> recognizeFile(File imageFile) async {
    final responsePort = ReceivePort();
    isolateInference.sendPort.send(InferenceModel(
      null, 
      imageFile, 
      interpreter.address,
      labels,
      inputTensor.shape,
      outputTensor.shape,
    )..responsePort = responsePort.sendPort);
    

    final result = await responsePort.first;
    log('result $result' );
    return result as Map<String, double>;
  }
}
