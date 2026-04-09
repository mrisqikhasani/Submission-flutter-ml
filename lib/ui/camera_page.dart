import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_ml/controller/camera_state_controller.dart';
import 'package:submission_flutter_ml/widget/classification_item.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraStateController _cameraStateController;

  @override
  void initState() {
    super.initState();
    _cameraStateController = context.read<CameraStateController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cameraStateController.initializeCamera();
    });
  }

  @override
  void dispose() {
    _cameraStateController.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<CameraStateController, bool>(
      selector: (_, controller) => controller.isCameraInitialized,
      builder: (context, isInitialized, _) {
        if (!isInitialized) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final cameraController = context.read<CameraStateController>().cameraController;
        if (cameraController == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: Text('Kamera tidak tersedia', style: TextStyle(color: Colors.white))),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: const Color(0xff1C2A3A),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Camera Page",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Live Feed Kamera
                      Center(
                        child: CameraPreview(cameraController),
                      ),
                      
                      // Tombol Capture (Di atas Live Feed)
                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () async {
                              try {
                              final image = await context.read<CameraStateController>().takePicture();
                                if (context.mounted && image != null) {
                                  Navigator.pop(context, image);
                                }
                              } catch (e) {
                                debugPrint("Capture Error: $e");
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                              ),
                              child: const CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                  size: 35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Consumer<CameraStateController>(
                    builder: (context, controller, _) {
                      if (controller.cameraResults.isEmpty) {
                        return const ClassificatioinItem(
                          item: "Scanning...",
                          value: "-",
                        );
                      }

                      // Mengambil hasil deteksi terbaik dari stream
                      final topResult = controller.cameraResults.entries.first;
                      final String displayScore =
                          "${(topResult.value * 100).toStringAsFixed(2)}%";

                      return ClassificatioinItem(
                        item: topResult.key,
                        value: displayScore,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}