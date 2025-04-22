import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chapter_model.dart';
import '../../providers/content_provider.dart';
import '../../utils/constants.dart';

class ChapterDetailScreen extends StatefulWidget {
  final dynamic chapter;
  
  ChapterDetailScreen({required this.chapter});
  
  @override
  _ChapterDetailScreenState createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter Details'),
        actions: [
          Consumer<ContentProvider>(
            builder: (context, contentProvider, _) {
              final isBookmarked = widget.chapter.isBookmarked;
              
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: isBookmarked ? Colors.amber : null,
                ),
                onPressed: () {
                  contentProvider.toggleBookmark(widget.chapter.id);
                },
                tooltip: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.blue.shade100,
              child: Center(
                child: Icon(
                  Icons.menu_book,
                  size: 80,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            
            // Title and Tags
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapter.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Tags
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTag(widget.chapter.subject, Colors.blue),
                      _buildTag(widget.chapter.grade, Colors.grey),
                      _buildTag(widget.chapter.curriculum, Colors.purple),
                      _buildTag(widget.chapter.semester, Colors.green),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    widget.chapter.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            Divider(),
            
            // Download Status and Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter Content',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  
                  SizedBox(height: 8),
                  
                  Consumer<ContentProvider>(
                    builder: (context, contentProvider, _) {
                      final isDownloaded = widget.chapter.isDownloaded;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status
                          Row(
                            children: [
                              Icon(
                                isDownloaded
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: isDownloaded ? Colors.green : Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Text(
                                isDownloaded
                                    ? 'Downloaded and ready to view'
                                    : 'Download required to view content',
                                style: TextStyle(
                                  color: isDownloaded ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Action Button
                          if (_isDownloading)
                            Column(
                              children: [
                                LinearProgressIndicator(
                                  value: _downloadProgress,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Downloading... ${(_downloadProgress * 100).toInt()}%',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            )
                          else if (isDownloaded)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('PDF Viewer will be implemented in the next phase'),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.visibility),
                                    label: Text('View PDF'),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    _showDeleteConfirmation(context, contentProvider);
                                  },
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                  tooltip: 'Delete Download',
                                ),
                              ],
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () {
                                _downloadChapter(contentProvider);
                              },
                              icon: Icon(Icons.download),
                              label: Text('Download Chapter'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            
            Divider(),
            
            // Lessons Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lessons in this Chapter',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  
                  SizedBox(height: 8),
                  
                  Consumer<ContentProvider>(
                    builder: (context, contentProvider, _) {
                      final isDownloaded = widget.chapter.isDownloaded;
                      
                      return isDownloaded
                          ? _buildLessonsList()
                          : Column(
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Download this chapter to access lessons',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build a tag widget
  Widget _buildTag(String text, MaterialColor color) {
    return Container(
      margin: EdgeInsets.only(right: 4, bottom: 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color.shade800,
        ),
      ),
    );
  }
  
  // Build lessons list
  Widget _buildLessonsList() {
    return Column(
      children: [
        ListTile(
          title: Text('Introduction to the Chapter'),
          leading: Icon(Icons.article),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lessons will be implemented in the next phase')),
            );
          },
        ),
        Divider(height: 1),
        ListTile(
          title: Text('Key Concepts'),
          leading: Icon(Icons.lightbulb),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lessons will be implemented in the next phase')),
            );
          },
        ),
        Divider(height: 1),
        ListTile(
          title: Text('Practice Exercises'),
          leading: Icon(Icons.edit),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lessons will be implemented in the next phase')),
            );
          },
        ),
        
        SizedBox(height: 16),
        
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lessons will be implemented in the next phase')),
            );
          },
          icon: Icon(Icons.list),
          label: Text('View All Lessons'),
        ),
      ],
    );
  }
  
  // Download chapter
  Future<void> _downloadChapter(ContentProvider contentProvider) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });
    
    // Simulate progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(Duration(milliseconds: 300));
      setState(() {
        _downloadProgress = i / 10;
      });
    }
    
    // Perform actual download
    final success = await contentProvider.downloadChapter(widget.chapter.id);
    
    setState(() {
      _isDownloading = false;
    });
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.errorDownloadFailed),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.successDownloadComplete),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, ContentProvider contentProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Download'),
        content: Text('Are you sure you want to delete this downloaded chapter? You will need to download it again to view its content.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await contentProvider.deleteDownloadedChapter(widget.chapter.id);
              
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete downloaded chapter'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}