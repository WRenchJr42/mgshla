import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';

import '../../models/chapter_model.dart';

class PdfViewerScreen extends StatefulWidget {
  final ChapterModel chapter;
  final bool teachMode;

  const PdfViewerScreen({super.key, 
    required this.chapter,
    this.teachMode = false,
  });

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isPortrait = true;
  bool _isFullScreen = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setInitialOrientation();
    _validateAndLoadPdf();
  }

  Future<void> _validateAndLoadPdf() async {
    if (widget.chapter.localPath == null) {
      setState(() {
        _hasError = true;
        _errorMessage = 'PDF path is not available';
        _isLoading = false;
      });
      return;
    }

    try {
      final file = File(widget.chapter.localPath!);
      if (!await file.exists()) {
        setState(() {
          _hasError = true;
          _errorMessage = 'PDF file not found';
          _isLoading = false;
        });
        return;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty || bytes.length < 4) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Invalid PDF file';
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _setInitialOrientation() async {
    if (widget.teachMode) {
      // Start in landscape for teach mode
      await _setOrientation(false);
    }
  }

  Future<void> _toggleOrientation() async {
    await _setOrientation(!_isPortrait);
  }

  Future<void> _setOrientation(bool isPortrait) async {
    _isPortrait = isPortrait;
    
    if (isPortrait) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    
    setState(() {});
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _nextPage() {
    if (_pdfViewerController.pageNumber < _pdfViewerController.pageCount) {
      _pdfViewerController.nextPage();
    }
  }

  void _previousPage() {
    if (_pdfViewerController.pageNumber > 1) {
      _pdfViewerController.previousPage();
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    // Reset to portrait mode when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If not in portrait mode, return to portrait first
        if (!_isPortrait) {
          await _setOrientation(true);
          return false; // Prevent immediate pop
        }
        return true;
      },
      child: Scaffold(
        appBar: _isFullScreen
            ? null
            : AppBar(
                title: Text(
                  widget.chapter.title,
                  style: const TextStyle(fontSize: 16),
                ),
                actions: [
                  IconButton(
                    icon: Icon(_isPortrait
                        ? Icons.screen_rotation
                        : Icons.screen_lock_portrait),
                    onPressed: _toggleOrientation,
                    tooltip: _isPortrait
                        ? 'Switch to Landscape'
                        : 'Switch to Portrait',
                  ),
                  IconButton(
                    icon: Icon(_isFullScreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen),
                    onPressed: _toggleFullScreen,
                    tooltip: _isFullScreen
                        ? 'Exit Fullscreen'
                        : 'Enter Fullscreen',
                  ),
                ],
              ),
        body: SafeArea(
          child: Stack(
            children: [
              // PDF Viewer
              Positioned.fill(
                child: Container(
                  color: Colors.grey.shade900,
                  child: _hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage ?? 'Failed to load PDF',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : SfPdfViewer.file(
                          File(widget.chapter.localPath!),
                          controller: _pdfViewerController,
                          onDocumentLoaded: (details) {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          onDocumentLoadFailed: (details) {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                                _hasError = true;
                                _errorMessage = 'Failed to load PDF: ${details.error}';
                              });
                            }
                          },
                          pageSpacing: 2.0,
                          enableDoubleTapZooming: true,
                        ),
                ),
              ),
              
              // Loading indicator
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              
              // Navigation arrows
              if (!_isLoading && !_hasError && widget.teachMode)
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: 'prev',
                    onPressed: _previousPage,
                    mini: true,
                    backgroundColor: Colors.black45,
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
              
              if (!_isLoading && !_hasError && widget.teachMode)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: 'next',
                    onPressed: _nextPage,
                    backgroundColor: Colors.black45,
                    child: const Icon(Icons.arrow_forward),
                  ),
                ),
              
              // Fullscreen exit button
              if (_isFullScreen)
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.fullscreen_exit,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFullScreen,
                    ),
                  ),
                ),
              
              // Page indicator
              if (!_isLoading && !_hasError)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Page ${_pdfViewerController.pageNumber} of ${_pdfViewerController.pageCount}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
