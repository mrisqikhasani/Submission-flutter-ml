import 'dart:io';

import 'package:flutter/material.dart';
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
            children: [Text("Food Name")],
          ),
        ),
      ],
    );
  }
}
