import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';

class LessonScreen extends StatelessWidget {
  final String chapterName;
  final String pdfPath;

  const LessonScreen({Key? key, required this.chapterName, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chapterName),
        actions: [
          IconButton(
            icon: const Icon(Icons.screen_rotation),
            onPressed: () {
              // Handle portrait/landscape toggle
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(File(pdfPath)),
    );
  }
}