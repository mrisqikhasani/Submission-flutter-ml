import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_ml/controller/home_controller.dart';
import 'package:submission_flutter_ml/services/gemini_services.dart';
import 'package:submission_flutter_ml/services/http_service.dart';
import 'package:submission_flutter_ml/services/image_recognizer_services.dart';
import 'package:submission_flutter_ml/ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => ImageRecognizerServices()),
        Provider(create: (contet) => HttpService()),
        Provider(create: (contet) => GeminiServices()),
        ChangeNotifierProvider(
          create: (context) => HomeController(
            context.read<ImageRecognizerServices>(),
            context.read<HttpService>(),
            context.read<GeminiServices>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
