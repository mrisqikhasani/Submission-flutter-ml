import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_ml/controller/detail_controller.dart';
import 'package:submission_flutter_ml/controller/result_controller.dart';
import 'package:submission_flutter_ml/model/nutrition_model.dart';
import 'package:submission_flutter_ml/widget/classification_item.dart';

class ResultPage extends StatelessWidget {
  final String imagePath;
  final String labelResult;
  final double scoreResult;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.labelResult,
    required this.scoreResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Result Page'),
      ),
      body: SafeArea(
        child: _ResultBody(
          imagePath: imagePath,
          labelResult: labelResult,
          scoreResult: scoreResult,
        ),
      ),
    );
  }
}

class _ResultBody extends StatefulWidget {
  final String imagePath;
  final String labelResult;
  final double scoreResult;

  const _ResultBody({
    required this.imagePath,
    required this.labelResult,
    required this.scoreResult,
  });

  @override
  State<_ResultBody> createState() => _ResultBodyState();
}

class _ResultBodyState extends State<_ResultBody> {
  @override
  void initState() {
    super.initState();
    // Ambil data referensi dari MealDB API segera setelah halaman dimuat
    Future.microtask(() {
      context.read<DetailController>().fetchMealDetail(widget.labelResult);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String displayScore = "${(widget.scoreResult * 100).toStringAsFixed(2)}%";
    final detailController = context.watch<DetailController>();

    return SingleChildScrollView( // Tambahkan scroll agar tidak overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Gambar Hasil Foto User
          SizedBox(
            height: 300,
            child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ClassificatioinItem(
              item: widget.labelResult,
              value: displayScore,
            ),
          ),
          
          const Divider(),
          
          // 2. Tabel Nutrisi (Gemini)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: context.watch<ResultController>().isNutritionLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildNutritionTable(context.watch<ResultController>().nutritionResult),
          ),
          
          const Divider(),

          // 3. SEKSI REFERENCE (Sesuai Gambar)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Reference",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // Tampilan List Tile untuk Reference
                InkWell(
                  onTap: () {
                    detailController.goToDetailPage(context, widget.labelResult);
                  },
                  child: detailController.isDetailLoading
                      ? const LinearProgressIndicator()
                      : Row(
                          children: [
                            // Gambar kecil dari API MealDB
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: detailController.mealDetail?.strMealThumb != null
                                  ? Image.network(
                                      detailController.mealDetail!.strMealThumb,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.fastfood),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            // Nama Makanan dari API
                            Expanded(
                              child: Text(
                                detailController.mealDetail?.strMeal ?? widget.labelResult,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNutritionTable(NutritionData? data) {
    if (data == null) return const Text("Data nutrisi tidak tersedia.");

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _nutritionRow("Calories", data.calories),
          const Divider(),
          _nutritionRow("Carbs", data.carbs),
          const Divider(),
          _nutritionRow("Fat", data.fat),
          const Divider(),
          _nutritionRow("Fiber", data.fiber),
          const Divider(),
          _nutritionRow("Protein", data.protein),
        ],
      ),
    );
  }

  Widget _nutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        ],
      ),
    );
  }
}