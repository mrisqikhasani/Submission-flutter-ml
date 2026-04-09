import 'dart:developer';
import 'package:flutter/material.dart';

import '../model/nutrition_model.dart';
import '../services/gemini_services.dart';

class ResultController extends ChangeNotifier {
  final GeminiServices _geminiServices;

  ResultController(this._geminiServices);

  NutritionData? _nutritionResult;
  NutritionData? get nutritionResult => _nutritionResult;

  bool _isNutritionLoading = false;
  bool get isNutritionLoading => _isNutritionLoading;

  Future<void> analyzeNutrition(String foodName) async {
    try {
      _isNutritionLoading = true;
      notifyListeners();
      
      _nutritionResult = await _geminiServices.getNutritionValue(foodName);
    } catch (e) {
      log("Nutrition Analysis Error: $e");
    } finally {
      _isNutritionLoading = false;
      notifyListeners();
    }
  }
}