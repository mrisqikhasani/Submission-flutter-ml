import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_ml/controller/home_controller.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Detail page"),
      ),
      body: SafeArea(
        child: _buildBody(context, controller),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeController controller) {
    if (controller.isDetailLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final meal = controller.mealDetail;
    if (meal == null) {
      return const Center(child: Text("Resep tidak ditemukan."));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 300,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias, 
            child: Image.network(
              meal.strMealThumb,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50),
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.strMeal,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 16),

                _buildSectionTitle(context, "Ingredients"),
                const SizedBox(height: 8),
                ...meal.ingredientsWithMeasures.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline, 
                               size: 18, 
                               color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    )),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // SECTION INSTRUCTIONS
                _buildSectionTitle(context, "Instructions"),
                const SizedBox(height: 8),
                Text(
                  meal.strInstructions,
                  style: const TextStyle(height: 1.6, fontSize: 15),
                  textAlign: TextAlign.justify,
                ),
                
                const SizedBox(height: 40), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
    );
  }
}