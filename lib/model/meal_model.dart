class MealModel {
  final String idMeal;
  final String strMeal;
  final String strInstructions;
  final String strMealThumb;
  final List<String> ingredientsWithMeasures; 

  MealModel({
    required this.idMeal,
    required this.strMeal,
    required this.strInstructions,
    required this.strMealThumb,
    required this.ingredientsWithMeasures,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    List<String> combinedList = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        // Gabungkan takaran dan bahan, contoh: "1 pound penne rigate"
        final String fullIngredient = "${measure?.toString().trim() ?? ""} ${ingredient.toString().trim()}".trim();
        combinedList.add(fullIngredient);
      }
    }

    return MealModel(
      idMeal: json['idMeal'] ?? "",
      strMeal: json['strMeal'] ?? "",
      strInstructions: json['strInstructions'] ?? "",
      strMealThumb: json['strMealThumb'] ?? "",
      ingredientsWithMeasures: combinedList,
    );
  }
}