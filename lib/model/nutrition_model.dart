class NutritionData {
  final String calories;
  final String carbs;
  final String fat;
  final String fiber;
  final String protein;

  NutritionData({
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.protein,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: json['calories'] ?? '-',
      carbs: json['carbs'] ?? '-',
      fat: json['fat'] ?? '-',
      fiber: json['fiber'] ?? '-',
      protein: json['protein'] ?? '-',
    );
  }
}