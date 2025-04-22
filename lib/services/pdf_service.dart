import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../services/storage_service.dart';
import '../utils/constants.dart';

class PdfService {
  // Singleton pattern
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  final StorageService _storageService = StorageService();

  // Download PDF from URL or asset
  Future<String?> downloadPdf(String urlOrAssetPath, String fileName) async {
    try {
      // For demo purposes, we'll use a bundled asset
      // In a real app, you would download from a URL
      if (urlOrAssetPath.startsWith('assets/')) {
        return _copyAssetToLocal(urlOrAssetPath, fileName);
      } else {
        // Simulate download for demo
        // In real app, implement HTTP download here
        return _simulateDownload(fileName);
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      return null;
    }
  }
  
  // Copy asset to local storage
  Future<String?> _copyAssetToLocal(String assetPath, String fileName) async {
    try {
      // Load the PDF asset
      final ByteData data = await rootBundle.load(AppConstants.dummyPdfPath);
      final bytes = data.buffer.asUint8List();
      
      // Save to local storage
      final localPath = await _storageService.saveFile(
        '$fileName.pdf',
        bytes,
      );
      
      return localPath;
    } catch (e) {
      debugPrint('Error copying asset to local: $e');
      return null;
    }
  }
  
  // Simulate downloading for demo purposes
  Future<String?> _simulateDownload(String fileName) async {
    try {
      // Create a dummy PDF file with some content
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      
      // Generate some dummy PDF content
      // In a real app, this would be the downloaded content
      final List<int> pdfBytes = await _generateDummyPdf();
      
      // Save the dummy PDF
      final localPath = await _storageService.saveFile(
        '$fileName.pdf',
        pdfBytes,
      );
      
      return localPath;
    } catch (e) {
      debugPrint('Error simulating download: $e');
      return null;
    }
  }
  
  // Generate dummy PDF for testing
  Future<List<int>> _generateDummyPdf() async {
    try {
      // For simplicity, we'll just use a bundled asset
      final ByteData data = await rootBundle.load(AppConstants.dummyPdfPath);
      return data.buffer.asUint8List();
    } catch (e) {
      // If asset loading fails, create a minimal valid PDF
      debugPrint('Using fallback dummy PDF');
      return _createMinimalPdf();
    }
  }
  
  // Create a minimal valid PDF file for testing
  List<int> _createMinimalPdf() {
    // This is a minimal valid PDF structure
    // Not intended for actual use, just for testing
    final String pdf = '''%PDF-1.4
1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj
2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj
3 0 obj<</Type/Page/MediaBox[0 0 612 792]/Parent 2 0 R/Resources<<>>/Contents 4 0 R>>endobj
4 0 obj<</Length 21>>stream
BT /F1 12 Tf 100 700 Td (Educational App - Sample PDF) Tj ET
endstream
endobj
xref
0 5
0000000000 65535 f
0000000010 00000 n
0000000053 00000 n
0000000102 00000 n
0000000192 00000 n
trailer<</Size 5/Root 1 0 R>>
startxref
264
%%EOF''';
    
    return pdf.codeUnits;
  }
  
  // Delete PDF file
  Future<bool> deletePdf(String localPath) async {
    return await _storageService.deleteFile(localPath);
  }
  
  // Check if PDF exists locally
  Future<bool> pdfExists(String localPath) async {
    return await _storageService.fileExists(localPath);
  }
  
  // Get PDF file size
  Future<String> getPdfSize(String localPath) async {
    final int bytes = await _storageService.getFileSize(localPath);
    
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    }
  }
}
