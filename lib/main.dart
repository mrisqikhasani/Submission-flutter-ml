import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_ml/controller/home_controller.dart';
import 'package:submission_flutter_ml/controller/camera_state_controller.dart';
import 'package:submission_flutter_ml/controller/result_controller.dart';
import 'package:submission_flutter_ml/controller/detail_controller.dart';
import 'package:submission_flutter_ml/firebase_options.dart';
import 'package:submission_flutter_ml/services/firebase_ml_service.dart';
import 'package:submission_flutter_ml/services/gemini_services.dart';
import 'package:submission_flutter_ml/services/http_service.dart';
import 'package:submission_flutter_ml/services/image_recognizer_services.dart';
import 'package:submission_flutter_ml/ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (contet) => HttpService()),
        Provider(create: (contet) => GeminiServices()),
        Provider(
          create: (context) => ImageRecognizerServices(FirebaseMlService()),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeController(
            context.read<ImageRecognizerServices>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CameraStateController(
            context.read<ImageRecognizerServices>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ResultController(
            context.read<GeminiServices>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DetailController(
            context.read<HttpService>(),
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
