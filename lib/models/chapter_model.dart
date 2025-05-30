import 'package:flutter/foundation.dart';

@immutable
class ChapterModel {
  final String id;
  final String title;
  final String description;
  final String grade;
  final String subject;
  final String semester;
  final String curriculum;
  final String language;
  final String? pdfUrl; // URL for PDF file (or local path if downloaded)
  final bool isDownloaded;
  final bool isBookmarked;
  final String? localPath; // Local storage path after download
  final int? totalPages;
  final bool isTeachMode;

  const ChapterModel({
    required this.id,
    required this.title,
    required this.description,
    required this.grade,
    required this.subject,
    required this.semester,
    required this.curriculum,
    required this.language,
    this.pdfUrl,
    this.isDownloaded = false,
    this.isBookmarked = false,
    this.localPath,
    this.totalPages,
    this.isTeachMode = false,
  });

  // Create a copy with updated fields
  ChapterModel copyWith({
    String? id,
    String? title,
    String? description,
    String? grade,
    String? subject,
    String? semester,
    String? curriculum,
    String? language,
    String? pdfUrl,
    bool? isDownloaded,
    bool? isBookmarked,
    String? localPath,
    int? totalPages,
    bool? isTeachMode,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      grade: grade ?? this.grade,
      subject: subject ?? this.subject,
      semester: semester ?? this.semester,
      curriculum: curriculum ?? this.curriculum,
      language: language ?? this.language,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      localPath: localPath ?? this.localPath,
      totalPages: totalPages ?? this.totalPages,
      isTeachMode: isTeachMode ?? this.isTeachMode,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'grade': grade,
      'subject': subject,
      'semester': semester,
      'curriculum': curriculum,
      'language': language,
      'pdf_url': pdfUrl,
      'is_downloaded': isDownloaded,
      'is_bookmarked': isBookmarked,
      'local_path': localPath,
      'total_pages': totalPages,
      'is_teach_mode': isTeachMode,
    };
  }

  // Create from JSON
  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      grade: json['grade'],
      subject: json['subject'],
      semester: json['semester'],
      curriculum: json['curriculum'],
      language: json['language'],
      pdfUrl: json['pdf_url'],
      isDownloaded: json['is_downloaded'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
      localPath: json['local_path'],
      totalPages: json['total_pages'],
      isTeachMode: json['is_teach_mode'] ?? false,
    );
  }
}

class FilterOptions {
  final List<String> grades;
  final List<String> subjects;
  final List<String> semesters;
  final List<String> curriculums;
  final List<String> languages;

  FilterOptions({
    required this.grades,
    required this.subjects,
    required this.semesters,
    required this.curriculums,
    required this.languages,
  });

  // Default filter options for initial setup
  factory FilterOptions.defaultOptions() {
    return FilterOptions(
      grades: ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'],
      subjects: ['Mathematics', 'Science', 'English', 'Social Studies', 'Computer Science', 'Physics', 'Chemistry', 'Biology'],
      semesters: ['Semester 1', 'Semester 2'],
      curriculums: ['CBSE', 'ICSE', 'State Board', 'International'],
      languages: ['English', 'Hindi', 'Tamil', 'Telugu', 'Kannada', 'Malayalam', 'Marathi', 'Bengali'],
    );
  }
}
