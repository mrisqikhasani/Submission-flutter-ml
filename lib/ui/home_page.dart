import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_ml/controller/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Food Recognizer App'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const _HomeBody(),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () {
              },
              child: Align(
                alignment: Alignment.center,
                child: Consumer<HomeController>(
                  builder: (context, controller, _) {
                    if (controller.image == null) {
                      return const Icon(Icons.image, size: 100);
                    }

                    return Image.file(controller.image!);
                  },
                ),
              ),
            ),
          ),
        ),
        Consumer<HomeController>(
          builder: (context, controller, _) {
            return Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    controller.pickFromGallery();
                  },
                  child: const Text("Gallery"),
                ),
                
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controller.isLoading
                        ? null
                        : () => controller.openCustomCamera(
                            context,
                          ), 
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Custom Camera"),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        Consumer<HomeController>(
          builder: (context, controller, _) {
            return FilledButton.tonal(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: (controller.image == null || controller.isLoading)
                  ? null
                  : () => controller.goToResultPage(context),
              child: controller.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Analyze",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            );
          },
        ),
      ],
    );
  }
}
