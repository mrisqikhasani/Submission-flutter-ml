import 'dart:convert';
import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:submission_flutter_ml/env/env.dart';
import 'package:submission_flutter_ml/model/nutrition_model.dart';

class GeminiServices {
  late final GenerativeModel model;

  GeminiServices() {
    model = GenerativeModel( 
      model: 'gemini-3-flash-preview', 
      apiKey: Env.geminiApiKey, 
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
      systemInstruction: Content.system("""
      Saya adalah suatu mesin yang mampu mengidentifikasi nutrisi atau 
      kandungan gizi pada makanan layaknya uji laboratorium makanan. 
      Hal yang bisa diidentifikasi adalah kalori, karbohidrat, lemak, serat, dan protein pada makanan. 
      Satuan dari indikator tersebut berupa gram."""));
  }

  Future<NutritionData?> getNutritionValue(String foodName) async {
    final prompt = """nama makananya Nama makanannya adalah $foodName.
    Kembalikan data dalam format JSON dengan key: 
      "calories", "carbs", "fat", "fiber", "protein".
      Gunakan satuan (misal: "250 kcal", "30g")
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        final Map<String, dynamic> data = jsonDecode(response.text!);
        return NutritionData.fromJson(data);
      }      
    } catch (e) {
      log("Gemini Error: $e");
    }
    return null;
  }
}
