class ChapterModel {
  final String id;
  final String title;
  final String description;
  final String grade;
  final String subject;
  final String semester;
  final String curriculum;
  final String language;
  final String pdfUrl; // URL for PDF file (or local path if downloaded)
  final bool isDownloaded;
  final bool isBookmarked;
  final String? localPath; // Local storage path after download
  final int totalPages;

  ChapterModel({
    required this.id,
    required this.title,
    required this.description,
    required this.grade,
    required this.subject,
    required this.semester,
    required this.curriculum,
    required this.language,
    required this.pdfUrl,
    this.isDownloaded = false,
    this.isBookmarked = false,
    this.localPath,
    required this.totalPages,
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
      'pdfUrl': pdfUrl,
      'isDownloaded': isDownloaded,
      'isBookmarked': isBookmarked,
      'localPath': localPath,
      'totalPages': totalPages,
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
      pdfUrl: json['pdfUrl'],
      isDownloaded: json['isDownloaded'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      localPath: json['localPath'],
      totalPages: json['totalPages'] ?? 0,
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
