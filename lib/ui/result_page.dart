import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_ml/controller/home_controller.dart';
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
    Future.microtask(() {
      // todo-02: run the inference model based on user picture
    });
  }

  @override
  Widget build(BuildContext context) {
    final String displayScore =
        "${(widget.scoreResult * 100).toStringAsFixed(2)}%";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Expanded(
          child: Center(
            child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          // todo-03: show the inference result (food name and the confidence score)
          child: ClassificatioinItem(
            item: widget.labelResult,
            value: displayScore,
          ),
        ),
        const Divider(),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              context.watch<HomeController>().isNutritionLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildNutritionTable(
                      context.watch<HomeController>().nutritionResult,
                    ),
            ],
          ),
        ),
        const Divider(),
        FilledButton.tonal(
          onPressed: () {
            context.read<HomeController>().goToDetailPage(
              context,
              widget.labelResult,
            );
          },
          child: const Text("Detail"),
        ),
      ],
    );
  }

  Widget _buildNutritionTable(NutritionData? data) {
    if (data == null) {
      return const Text("Data nutrisi tidak tersedia saat ini.");
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.1)),
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
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
