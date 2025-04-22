import 'package:flutter/material.dart';
import 'dart:convert';

import '../models/chapter_model.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';

class ContentProvider with ChangeNotifier {
  List<ChapterModel> _chapters = [];
  List<ChapterModel> _filteredChapters = [];
  List<ChapterModel> _bookmarkedChapters = [];
  List<ChapterModel> _downloadedChapters = [];
  FilterOptions _filterOptions = FilterOptions.defaultOptions();
  Map<String, String> _activeFilters = {};
  bool _isLoading = false;

  // Service instances
  final StorageService _storageService = StorageService();
  final PdfService _pdfService = PdfService();

  // Getters
  List<ChapterModel> get chapters => _chapters;
  List<ChapterModel> get filteredChapters => _filteredChapters;
  List<ChapterModel> get bookmarkedChapters => _bookmarkedChapters;
  List<ChapterModel> get downloadedChapters => _downloadedChapters;
  FilterOptions get filterOptions => _filterOptions;
  Map<String, String> get activeFilters => _activeFilters;
  bool get isLoading => _isLoading;

  ContentProvider() {
    _loadChapters();
  }

  // Load chapters from local storage or initialize with mock data
  Future<void> _loadChapters() async {
    _isLoading = true;
    notifyListeners();

    try {
      final chaptersData = await _storageService.getChapters();
      if (chaptersData != null) {
        final List<dynamic> decodedData = jsonDecode(chaptersData);
        _chapters = decodedData.map((data) => ChapterModel.fromJson(data)).toList();
      } else {
        // Initialize with mock chapters
        _initializeMockChapters();
      }

      // Apply initial filtering
      _filterChapters();
      
      // Initialize bookmarked and downloaded lists
      _updateBookmarkedAndDownloadedLists();
    } catch (e) {
      debugPrint('Error loading chapters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save chapters to local storage
  Future<void> _saveChapters() async {
    final chaptersJson = jsonEncode(_chapters.map((chapter) => chapter.toJson()).toList());
    await _storageService.saveChapters(chaptersJson);
  }

  // Initialize with mock chapters for testing
  void _initializeMockChapters() {
    _chapters = List.generate(15, (index) {
      final id = (index + 1).toString();
      final grade = 'Grade ${(index % 12) + 1}';
      final subjects = ['Mathematics', 'Science', 'English', 'Social Studies', 'Computer Science'];
      final subject = subjects[index % subjects.length];
      final semester = 'Semester ${(index % 2) + 1}';
      final curriculums = ['CBSE', 'ICSE', 'State Board', 'International'];
      final curriculum = curriculums[index % curriculums.length];
      final languages = ['English', 'Hindi', 'Tamil'];
      final language = languages[index % languages.length];
      
      return ChapterModel(
        id: id,
        title: 'Chapter $id: Sample Chapter Title',
        description: 'This is a description for chapter $id. It contains important educational content.',
        grade: grade,
        subject: subject,
        semester: semester,
        curriculum: curriculum,
        language: language,
        pdfUrl: 'assets/dummy.pdf',
        totalPages: 10,
      );
    });
    
    _saveChapters();
  }

  // Filter chapters based on active filters
  void _filterChapters() {
    if (_activeFilters.isEmpty) {
      _filteredChapters = List.from(_chapters);
      return;
    }

    _filteredChapters = _chapters.where((chapter) {
      // Check if chapter matches all active filters
      for (var entry in _activeFilters.entries) {
        final filterType = entry.key;
        final filterValue = entry.value;
        
        if (filterType == 'grade' && chapter.grade != filterValue) return false;
        if (filterType == 'subject' && chapter.subject != filterValue) return false;
        if (filterType == 'semester' && chapter.semester != filterValue) return false;
        if (filterType == 'curriculum' && chapter.curriculum != filterValue) return false;
        if (filterType == 'language' && chapter.language != filterValue) return false;
      }
      return true;
    }).toList();
  }

  // Update bookmarked and downloaded lists
  void _updateBookmarkedAndDownloadedLists() {
    _bookmarkedChapters = _chapters.where((chapter) => chapter.isBookmarked).toList();
    _downloadedChapters = _chapters.where((chapter) => chapter.isDownloaded).toList();
  }

  // Set active filter
  void setFilter(String filterType, String filterValue) {
    _activeFilters[filterType] = filterValue;
    _filterChapters();
    notifyListeners();
  }

  // Clear a specific filter
  void clearFilter(String filterType) {
    _activeFilters.remove(filterType);
    _filterChapters();
    notifyListeners();
  }

  // Clear all filters
  void clearAllFilters() {
    _activeFilters.clear();
    _filterChapters();
    notifyListeners();
  }

  // Toggle chapter bookmark status
  Future<void> toggleBookmark(String chapterId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final chapterIndex = _chapters.indexWhere((chapter) => chapter.id == chapterId);
      if (chapterIndex != -1) {
        final chapter = _chapters[chapterIndex];
        _chapters[chapterIndex] = chapter.copyWith(
          isBookmarked: !chapter.isBookmarked,
        );
        
        await _saveChapters();
        _filterChapters();
        _updateBookmarkedAndDownloadedLists();
      }
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Download a chapter
  Future<bool> downloadChapter(String chapterId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final chapterIndex = _chapters.indexWhere((chapter) => chapter.id == chapterId);
      if (chapterIndex != -1) {
        final chapter = _chapters[chapterIndex];
        
        // For demo purposes, we'll simulate a download
        // In a real app, this would download from a remote URL
        final localPath = await _pdfService.downloadPdf(chapter.pdfUrl, chapterId);
        
        if (localPath != null) {
          _chapters[chapterIndex] = chapter.copyWith(
            isDownloaded: true,
            localPath: localPath,
          );
          
          await _saveChapters();
          _filterChapters();
          _updateBookmarkedAndDownloadedLists();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error downloading chapter: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a downloaded chapter
  Future<bool> deleteDownloadedChapter(String chapterId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final chapterIndex = _chapters.indexWhere((chapter) => chapter.id == chapterId);
      if (chapterIndex != -1) {
        final chapter = _chapters[chapterIndex];
        
        if (chapter.localPath != null) {
          final success = await _pdfService.deletePdf(chapter.localPath!);
          
          if (success) {
            _chapters[chapterIndex] = chapter.copyWith(
              isDownloaded: false,
              localPath: null,
            );
            
            await _saveChapters();
            _filterChapters();
            _updateBookmarkedAndDownloadedLists();
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting downloaded chapter: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search chapters by title or description
  List<ChapterModel> searchChapters(String query) {
    if (query.isEmpty) {
      return _filteredChapters;
    }
    
    return _filteredChapters.where(
      (chapter) => chapter.title.toLowerCase().contains(query.toLowerCase()) ||
                   chapter.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
