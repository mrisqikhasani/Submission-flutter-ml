import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:submission_flutter_ml/model/meal_model.dart';

class HttpService {
  Future<MealModel?> searchMealByName(String mealName) async {
    try {
      // Wajib pakai https:// agar tidak error
      final url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=$mealName';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);
        
        if (data['meals'] != null && (data['meals'] as List).isNotEmpty) {
          return MealModel.fromJson(data['meals'][0]);
        } else {
          return null; 
        }
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Caught an error: $e");
    }
  }
}