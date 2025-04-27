import 'package:flutter/material.dart';
import 'dart:io';

import '../../models/chapter_model.dart';
import 'pdf_viewer_screen.dart';

class LessonViewScreen extends StatefulWidget {
  final ChapterModel chapter;
  final bool teachMode;

  const LessonViewScreen({super.key, 
    required this.chapter, 
    this.teachMode = false
  });

  @override
  _LessonViewScreenState createState() => _LessonViewScreenState();
}

class _LessonViewScreenState extends State<LessonViewScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _prepareContent();
  }

  Future<void> _prepareContent() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Verify the PDF exists locally
      if (widget.chapter.localPath != null) {
        final file = File(widget.chapter.localPath!);
        if (await file.exists()) {
          setState(() {
            _isLoading = false;
          });

          // Directly navigate to PDF viewer after verifying
          _openPdfViewer();
          return;
        }
      }
      
      // If we got here, something is wrong
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _openPdfViewer() {
    // Small delay to allow the UI to update before navigation
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            chapter: widget.chapter,
            teachMode: widget.teachMode,
          ),
        ),
      ).then((_) {
        // If this screen is shown after returning from PDF viewer, pop it
        if (mounted) {
          Navigator.pop(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teachMode ? 'Teach Mode' : 'Lesson View'),
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Preparing lesson content...'),
                  ],
                )
              : _hasError
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load lesson content',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The content may be missing or corrupted.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _prepareContent,
                          child: const Text('Try Again'),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(), // Will navigate away immediately
        ),
      ),
    );
  }
}
