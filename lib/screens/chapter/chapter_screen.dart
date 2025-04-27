import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../models/chapter_model.dart';

class ChapterScreen extends StatefulWidget {
  final String subjectName;
  final String chapterName;
  final bool isTeachMode;

  const ChapterScreen({
    Key? key, 
    required this.subjectName,
    required this.chapterName,
    this.isTeachMode = false,
  }) : super(key: key);

  @override
  _ChapterScreenState createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  String? pdfPath;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  double _downloadProgress = 0;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isPdfLoaded = false;
  late ChapterModel _chapter;
  bool _isMounted = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _chapter = ChapterModel(
      id: widget.chapterName,
      title: widget.chapterName,
      description: '',
      grade: '',
      subject: widget.subjectName,
      semester: '',
      curriculum: '',
      language: '',
      isTeachMode: widget.isTeachMode,
    );
    _initializePdf();
  }

  void _safeSetState(VoidCallback fn) {
    if (_isMounted) {
      setState(fn);
    }
  }

  Future<void> _initializePdf() async {
    if (!_isMounted) return;

    _safeSetState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _downloadProgress = 0;
      _isPdfLoaded = false;
    });

    try {
      final pdfName = _chapter.isTeachMode ? 'teach.pdf' : 'prepare.pdf';
      final localFile = await _getLocalFile(pdfName);
      
      // Check if file exists and is valid
      if (await localFile.exists()) {
        final isValid = await _validatePdfFile(localFile);
        if (isValid) {
          if (!_isMounted) return;
          _safeSetState(() {
            pdfPath = localFile.path;
            _isLoading = false;
          });
          return;
        } else {
          // Delete invalid file
          await localFile.delete();
        }
      }

      // If we get here, we need to download the file
      await _fetchPdf();
    } catch (e) {
      if (!_isMounted) return;
      _safeSetState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to initialize PDF: $e';
      });
      debugPrint('Error initializing PDF: $e');
    }
  }

  Future<bool> _validatePdfFile(File file) async {
    try {
      if (!await file.exists()) return false;
      
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return false;
      
      // Check PDF magic number
      if (bytes.length < 5) return false;
      final header = String.fromCharCodes(bytes.sublist(0, 5));
      return header == '%PDF-';
    } catch (e) {
      debugPrint('Error validating PDF file: $e');
      return false;
    }
  }

  Future<void> _fetchPdf() async {
    if (!_isMounted || _isDownloading) return;
    
    _isDownloading = true;
    _safeSetState(() {
      _downloadProgress = 0.1;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      const bucketName = 'pdf';
      final pdfName = _chapter.isTeachMode ? 'teach.pdf' : 'prepare.pdf';
      final filePath = '${_chapter.subject}/$pdfName';

      debugPrint('Creating signed URL for PDF: $filePath');
      
      final signedUrl = await supabase.storage
          .from(bucketName)
          .createSignedUrl(filePath, 3600);
          
      if (signedUrl.isEmpty) {
        throw Exception('Failed to create download URL');
      }

      debugPrint('Downloading from signed URL: $signedUrl');
      
      if (!_isMounted) return;
      _safeSetState(() {
        _downloadProgress = 0.3;
      });

      final response = await supabase.storage
          .from(bucketName)
          .download(filePath);
          
      if (!_isMounted) return;
      _safeSetState(() {
        _downloadProgress = 0.8;
      });

      if (response.isEmpty) {
        throw Exception('Downloaded PDF is empty');
      }

      final file = await _saveFileLocally(pdfName, response);
      
      if (!await file.exists()) {
        throw Exception('Failed to save PDF file locally');
      }

      if (!await _validatePdfFile(file)) {
        await file.delete();
        throw Exception('Downloaded file is not a valid PDF');
      }

      if (!_isMounted) return;
      _safeSetState(() {
        pdfPath = file.path;
        _isLoading = false;
        _downloadProgress = 1.0;
      });
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      if (!_isMounted) return;
      _safeSetState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to download PDF: $e';
      });
    } finally {
      _isDownloading = false;
    }
  }

  Future<File> _getLocalFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${_chapter.subject}_$fileName';
    return File(path);
  }

  Future<File> _saveFileLocally(String fileName, Uint8List fileBytes) async {
    final file = await _getLocalFile(fileName);
    await file.writeAsBytes(fileBytes, flush: true);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_chapter.subject.toUpperCase()} - ${_chapter.isTeachMode ? 'Teach' : 'Prepare'}'),
      ),
      body: _isLoading 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_downloadProgress > 0)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(value: _downloadProgress),
                          const SizedBox(height: 8),
                          Text('Downloading: ${(_downloadProgress * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                    )
                  else
                    const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Loading PDF...'),
                ],
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'An error occurred',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (!_isDownloading)
                        ElevatedButton(
                          onPressed: _fetchPdf,
                          child: const Text('Retry Download'),
                        ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SfPdfViewer.file(
                      File(pdfPath!),
                      controller: _pdfViewerController,
                      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                        _safeSetState(() {
                          _isPdfLoaded = true;
                        });
                      },
                      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                        _safeSetState(() {
                          _hasError = true;
                          _errorMessage = 'Failed to load PDF: ${details.error}';
                          _isPdfLoaded = false;
                        });
                      },
                    ),
                    if (!_isPdfLoaded)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    _pdfViewerController.dispose();
    super.dispose();
  }
}