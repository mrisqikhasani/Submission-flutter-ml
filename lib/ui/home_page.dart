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
                // todo-01: tap this icon to open image picker feature
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
        Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FilledButton.tonal(
              onPressed: () {
                context.read<HomeController>().pickFromGallery();
              },
              child: const Text("Gallery"),
            ),
          ],
        ),
        FilledButton.tonal(
          onPressed: () {
            context.read<HomeController>().goToResultPage(context);
          },
          child: const Text("Analyze"),
        ),
      ],
    );
  }
}
