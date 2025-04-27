import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chapter_model.dart';
import '../services/pdf_service.dart';

class ContentProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _pdfService = PdfService();
  
  List<ChapterModel> _chapters = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ChapterModel> get chapters => _chapters;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<ChapterModel> get downloadedChapters => 
    _chapters.where((chapter) => chapter.isDownloaded).toList();
  
  List<ChapterModel> get bookmarkedChapters =>
    _chapters.where((chapter) => chapter.isBookmarked).toList();

  // Filter related fields
  final Map<String, String> _activeFilters = {};
  Map<String, String> get activeFilters => _activeFilters;

  late final FilterOptions _filterOptions = FilterOptions.defaultOptions();
  FilterOptions get filterOptions => _filterOptions;

  void setFilter(String filterType, String value) {
    _activeFilters[filterType] = value;
    notifyListeners();
  }

  void clearFilter(String filterType) {
    _activeFilters.remove(filterType);
    notifyListeners();
  }

  void clearAllFilters() {
    _activeFilters.clear();
    notifyListeners();
  }

  List<ChapterModel> get filteredChapters {
    if (_activeFilters.isEmpty) {
      return _chapters;
    }
    return _chapters.where((chapter) {
      return _activeFilters.entries.every((filter) {
        switch (filter.key) {
          case 'grade':
            return chapter.grade == filter.value;
          case 'subject':
            return chapter.subject == filter.value;
          case 'semester':
            return chapter.semester == filter.value;
          case 'curriculum':
            return chapter.curriculum == filter.value;
          case 'language':
            return chapter.language == filter.value;
          default:
            return true;
        }
      });
    }).toList();
  }

  // Methods
  Future<void> loadChapters() async {
    _setLoading(true);
    try {
      final response = await _supabase.from('chapters').select();
      _chapters = (response as List)
          .map((data) => ChapterModel.fromJson(data))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load chapters: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> downloadChapter(String chapterId) async {
    final chapter = _chapters.firstWhere((c) => c.id == chapterId);
    if (chapter.isDownloaded) return true;

    _setLoading(true);
    try {
      final pdfName = chapter.isTeachMode ? 'teach.pdf' : 'prepare.pdf';
      final filePath = '${chapter.subject}/$pdfName';

      final pdfUrl = await _supabase.storage
          .from('pdf')
          .createSignedUrl(filePath, 3600);

      final localPath = await _pdfService.downloadPdf(pdfUrl, '${chapter.subject}_$pdfName');
      if (localPath == null) throw Exception('Failed to download PDF');

      // Update chapter in database
      await _supabase.from('chapters').update({
        'is_downloaded': true,
        'local_path': localPath,
      }).eq('id', chapterId);

      // Update local state
      final index = _chapters.indexWhere((c) => c.id == chapterId);
      _chapters[index] = chapter.copyWith(
        isDownloaded: true,
        localPath: localPath,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to download chapter: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteDownloadedChapter(String chapterId) async {
    final chapter = _chapters.firstWhere((c) => c.id == chapterId);
    if (!chapter.isDownloaded) return;

    _setLoading(true);
    try {
      if (chapter.localPath != null) {
        await _pdfService.deletePdf(chapter.localPath!);
      }

      // Update chapter in database
      await _supabase.from('chapters').update({
        'is_downloaded': false,
        'local_path': null,
      }).eq('id', chapterId);

      // Update local state
      final index = _chapters.indexWhere((c) => c.id == chapterId);
      _chapters[index] = chapter.copyWith(
        isDownloaded: false,
        localPath: null,
      );
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete chapter: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleBookmark(String chapterId) async {
    final chapter = _chapters.firstWhere((c) => c.id == chapterId);
    
    try {
      // Update chapter in database
      await _supabase.from('chapters').update({
        'is_bookmarked': !chapter.isBookmarked,
      }).eq('id', chapterId);

      // Update local state
      final index = _chapters.indexWhere((c) => c.id == chapterId);
      _chapters[index] = chapter.copyWith(
        isBookmarked: !chapter.isBookmarked,
      );
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update bookmark: $e';
    }
  }

  void addFilter(String filter) {
    if (!_activeFilters.containsKey(filter)) {
      _activeFilters[filter] = '';
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
