import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chapter_screen.dart';

class SubjectsScreen extends StatefulWidget {
  final String? initialSubject;

  const SubjectsScreen({Key? key, this.initialSubject}) : super(key: key);

  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, List<String>> _subjectsData = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      debugPrint('Loading subjects from Supabase storage...');
      
      // Get all folders (subjects) from the pdf bucket
      final List<FileObject> rootFiles = await _supabase.storage
          .from('pdf')
          .list();
      
      // Extract unique folder names
      final Set<String> subjects = widget.initialSubject != null 
          ? {widget.initialSubject!}
          : rootFiles
              .where((file) => file.name.contains('/')) // Only get folders
              .map((file) => file.name.split('/')[0]) // Get folder name
              .toSet();
      
      final Map<String, List<String>> subjectsData = {};

      for (String subject in subjects) {
        try {
          debugPrint('Listing files for subject: $subject');
          final List<FileObject> subjectFiles = await _supabase.storage
              .from('pdf')
              .list(path: subject);

          if (subjectFiles.isNotEmpty) {
            subjectsData[subject] = subjectFiles.map((f) => f.name).toList();
          }
        } catch (e) {
          debugPrint('Error listing files for $subject: $e');
        }
      }

      setState(() {
        _subjectsData = subjectsData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'physics':
        return Colors.blue;
      case 'chemistry':
        return Colors.green;
      case 'biology':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'physics':
        return Icons.science;
      case 'chemistry':
        return Icons.science_outlined;
      case 'biology':
        return Icons.biotech;
      case 'civics':
        return Icons.gavel;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSubjects,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _subjectsData.length,
                  itemBuilder: (context, index) {
                    final subject = _subjectsData.keys.elementAt(index);
                    final files = _subjectsData[subject]!;
                    final color = _getSubjectColor(subject);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.2),
                              child: Icon(
                                _getSubjectIcon(subject),
                                color: color,
                              ),
                            ),
                            title: Text(
                              subject.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('${files.length} files available'),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChapterScreen(
                                            subjectName: subject,
                                            chapterName: subject,
                                            isTeachMode: false,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.book),
                                    label: const Text('Prepare'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: color.withOpacity(0.8),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChapterScreen(
                                            subjectName: subject,
                                            chapterName: subject,
                                            isTeachMode: true,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.school),
                                    label: const Text('Teach'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: color.withOpacity(0.8),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}