import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;

  late final StorageService _storageService;

  PdfService._internal();

  void initialize(StorageService storageService) {
    _storageService = storageService;
  }

  /// Downloads a PDF from network or copies it from assets.
  Future<String?> downloadPdf(String urlOrAssetPath, String fileName) async {
    try {
      if (urlOrAssetPath.startsWith('assets/')) {
        return await _copyAssetToLocal(urlOrAssetPath, fileName);
      }

      debugPrint('Fetching PDF from network: $urlOrAssetPath');
      final uri = Uri.parse(urlOrAssetPath);
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Download timed out'),
      );

      debugPrint('HTTP GET ${uri.toString()} -> ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF. Status code: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      debugPrint('Downloaded ${bytes.length} bytes');
      if (bytes.isEmpty) {
        throw Exception('Downloaded file is empty');
      }

      // Debug the first few bytes to see what we're receiving
      if (bytes.length >= 10) {
        final header = String.fromCharCodes(bytes.sublist(0, 10));
        debugPrint('First 10 bytes as string: "$header"');
      }

      if (!_isPdfFormat(bytes)) {
        // If validation fails, log the content type
        final contentType = response.headers['content-type'];
        debugPrint('Content-Type from response: $contentType');
        throw Exception('Downloaded file is not a valid PDF (Content-Type: $contentType)');
      }

      final savedPath = await _storageService.saveFile(fileName, bytes);
      if (savedPath == null) {
        throw Exception('Failed to save PDF');
      }

      final savedFile = File(savedPath);
      if (!await savedFile.exists()) {
        throw Exception('Saved file does not exist');
      }

      return savedPath;
    } catch (e, st) {
      debugPrint('Error in downloadPdf: $e');
      debugPrint(st.toString());
      return null;
    }
  }

  /// Copies an asset PDF into local storage.
  Future<String?> _copyAssetToLocal(String assetPath, String fileName) async {
    try {
      debugPrint('Copying asset PDF: $assetPath');
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final savedPath = await _storageService.saveFile('$fileName.pdf', bytes);
      debugPrint('Asset PDF saved to: $savedPath');
      return savedPath;
    } catch (e) {
      debugPrint('Error copying asset to local: $e');
      return null;
    }
  }

  /// Deletes a previously downloaded PDF.
  Future<bool> deletePdf(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted PDF at $localPath');
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting PDF: $e');
      return false;
    }
  }

  /// Checks if a PDF exists locally.
  Future<bool> pdfExists(String localPath) async {
    try {
      final file = File(localPath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking PDF existence: $e');
      return false;
    }
  }

  /// Validates if a local file is a valid PDF.
  Future<bool> validatePdf(String localPath) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      return _isPdfFormat(bytes);
    } catch (e) {
      debugPrint('Error validating PDF: $e');
      return false;
    }
  }

  /// Returns a human-readable file size for a local PDF.
  Future<String> getPdfSize(String localPath) async {
    try {
      final bytes = await _storageService.getFileSize(localPath);
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      debugPrint('Error getting PDF size: $e');
      return 'Unknown';
    }
  }

  /// Checks if the given bytes represent a valid PDF file.
  bool _isPdfFormat(Uint8List bytes) {
    if (bytes.length < 5) {
      debugPrint('PDF validation failed: file too short (${bytes.length} bytes)');
      return false;
    }

    // Check for PDF magic number (%PDF-)
    final header = String.fromCharCodes(bytes.sublist(0, 5));
    debugPrint('PDF header check: "$header"');
    return header == '%PDF-';
  }
}
