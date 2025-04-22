import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
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
  Future<String?> saveFile(
    String fileName,
    List<int> bytes, {
    String? customDirectory,
  }) async {
    try {
      final directory = customDirectory ?? downloadDirectoryPath;
      if (directory == null) return null;

      final file = File('$directory/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
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
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking if file exists: $e');
      return false;
    }
  }

  // Get file size
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }
}
