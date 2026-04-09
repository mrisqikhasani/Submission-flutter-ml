import 'dart:developer';
import 'package:flutter/material.dart';

import '../model/meal_model.dart';
import '../services/http_service.dart';
import '../ui/detail_page.dart';

class DetailController extends ChangeNotifier {
  final HttpService _httpService;

  DetailController(this._httpService);

  MealModel? _mealDetail;
  MealModel? get mealDetail => _mealDetail;

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

  Future<void> fetchMealDetail(String foodName) async {
    try {
      _isDetailLoading = true;
      _mealDetail = null;
      notifyListeners();

      _mealDetail = await _httpService.searchMealByName(foodName);
    } catch (e) {
      log("Fetch Detail Error: $e");
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> goToDetailPage(BuildContext context, String foodName) async {
    try {
      _isDetailLoading = true;
      _mealDetail = null;
      notifyListeners();

      _mealDetail = await _httpService.searchMealByName(foodName);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DetailPage()),
        );
      }
    } catch (e) {
      log("Detail Error: $e");
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }
}
