import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../utils/constants.dart';

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  String? _documentsDirectory;

  // Initialize the service
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final directory = await getApplicationDocumentsDirectory();
      _documentsDirectory = directory.path;
      
      // Create necessary directories
      await _createDirectories();
    } catch (e) {
      debugPrint('Error initializing storage service: $e');
    }
  }

  // Create required directories
  Future<void> _createDirectories() async {
    if (_documentsDirectory != null) {
      final pdfDir = Directory('$_documentsDirectory/${AppConstants.pdfDownloadsDir}');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }
    }
  }

  // Get download directory path
  String? get downloadDirectoryPath {
    if (_documentsDirectory != null) {
      return '$_documentsDirectory/${AppConstants.pdfDownloadsDir}';
    }
    return null;
  }

  // USER DATA METHODS
  Future<void> saveUserData(String userData) async {
    await _prefs.setString(AppConstants.keyUserData, userData);
  }

  Future<String?> getUserData() async {
    return _prefs.getString(AppConstants.keyUserData);
  }

  Future<void> clearUserData() async {
    await _prefs.remove(AppConstants.keyUserData);
  }

  // SCHOOLS METHODS
  Future<void> saveSchools(String schoolsData) async {
    await _prefs.setString(AppConstants.keySchools, schoolsData);
  }

  Future<String?> getSchools() async {
    return _prefs.getString(AppConstants.keySchools);
  }

  // CHAPTERS METHODS
  Future<void> saveChapters(String chaptersData) async {
    await _prefs.setString(AppConstants.keyChapters, chaptersData);
  }

  Future<String?> getChapters() async {
    return _prefs.getString(AppConstants.keyChapters);
  }

  // FILE STORAGE METHODS
  // Save a file to local storage
  Future<String?> saveFile(String fileName, Uint8List bytes) async {
    try {
      if (_documentsDirectory == null) {
        final directory = await getApplicationDocumentsDirectory();
        _documentsDirectory = directory.path;
      }

      final pdfDir = Directory('$_documentsDirectory/${AppConstants.pdfDownloadsDir}');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      final filePath = '${pdfDir.path}/$fileName';
      final file = File(filePath);

      // Create parent directories if they don't exist
      final parent = file.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }

      // Write file with flush to ensure it's written to disk
      await file.writeAsBytes(bytes, flush: true);
      
      // Verify the file was written correctly
      if (!await file.exists()) {
        debugPrint('File was not saved successfully: $fileName');
        return null;
      }

      final savedSize = await file.length();
      if (savedSize != bytes.length) {
        debugPrint('File size mismatch. Expected: ${bytes.length}, Got: $savedSize');
        await file.delete();
        return null;
      }

      debugPrint('File saved successfully: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  // Delete a file from local storage
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  // Check if a file exists
  Future<bool> fileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking file existence: $e');
      return false;
    }
  }

  // Get file size
  Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return 0;
      return await file.length();
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  // Download a file from a URL
  Future<Uint8List?> downloadFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        debugPrint('Failed to download file. Status code: ${response.statusCode}');
        return null;
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        debugPrint('Downloaded file is empty');
        return null;
      }

      return bytes;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      return null;
    }
  }
}
