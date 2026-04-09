import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../utils/image_utils.dart';

class IsolateInference {
  static const String _debugName = "TFLITE_INFERENCE";
  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _sendPort;
  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: _debugName,
    );
    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final InferenceModel isolateModel in port) {
      try{
      final inputShape = isolateModel.inputShape;
      final List<List<List<num>>> imageMatrix;
      if (isolateModel.cameraImage != null) {
        imageMatrix = _imagePreProcessing(isolateModel.cameraImage!, inputShape);
      } else if (isolateModel.imageFile != null) {
        imageMatrix = _imageFilePreProcessing(isolateModel.imageFile!, inputShape);
      } else {
        continue; // Lewati jika tidak ada gambar
      }
      // final imageMatrix = _imagePreProcessing(cameraImage, inputShape);

      final input = [imageMatrix];
      final output = [List<int>.filled(isolateModel.outputShape[1], 0)];
      final address = isolateModel.interpreterAddress;

      final result = _runInference(input, output, address);

      int maxScore = result.reduce((a, b) => a + b);
      final keys = isolateModel.labels;
      final values =
          result.map((e) => e.toDouble() / maxScore.toDouble()).toList();

      var classification = Map.fromIterables(keys, values);
      classification.removeWhere((key, value) => value == 0);

      isolateModel.responsePort.send(classification);
      }catch(e){
        log("Isolate Error: $e");
      }
    }
  }

  Future<void> close() async {
    _isolate.kill();
    _receivePort.close();
  }

  static List<List<List<num>>> _imagePreProcessing(
    CameraImage cameraImage,
    List<int> inputShape,
  ) {
    image_lib.Image? img;
    img = ImageUtils.convertCameraImage(cameraImage);

    // resize original image to match model shape.
    image_lib.Image imageInput = image_lib.copyResize(
      img!,
      width: inputShape[1],
      height: inputShape[2],
    );

    if (Platform.isAndroid) {
      imageInput = image_lib.copyRotate(imageInput, angle: 90);
    }

    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );
    return imageMatrix;
  }

  static List<List<List<num>>> _imageFilePreProcessing(
    File imageFile,
    List<int> inputShape,
  ) {
    final bytes = imageFile.readAsBytesSync();
    image_lib.Image? img = image_lib.decodeImage(bytes);

    image_lib.Image imageInput = image_lib.copyResize(
      img!,
      width: inputShape[1],
      height: inputShape[2],
    );

    // Generate matrix RGB
    return List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );
  }

  static List<int> _runInference(
    List<List<List<List<num>>>> input,
    List<List<int>> output,
    int interpreterAddress,
  ) {
    Interpreter interpreter = Interpreter.fromAddress(interpreterAddress);
    interpreter.run(input, output);
    // Get first output tensor
    final result = output.first;
    return result;
  }
}

class InferenceModel {
  CameraImage? cameraImage;
  File? imageFile;
  int interpreterAddress;
  List<String> labels;
  List<int> inputShape;
  List<int> outputShape;
  late SendPort responsePort;

  InferenceModel(this.cameraImage, this.imageFile, this.interpreterAddress, this.labels,
      this.inputShape, this.outputShape);
}