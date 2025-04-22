import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chapter_model.dart';
import '../../providers/content_provider.dart';
import '../lesson/lesson_view_screen.dart';

class ChapterDetailScreen extends StatefulWidget {
  final ChapterModel chapter;

  ChapterDetailScreen({required this.chapter});

  @override
  _ChapterDetailScreenState createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  bool _isDownloading = false;

  Future<void> _toggleBookmark() async {
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);
    await contentProvider.toggleBookmark(widget.chapter.id);
  }

  Future<void> _downloadChapter() async {
    if (widget.chapter.isDownloaded) {
      // Already downloaded, go directly to lesson view
      _openLessonView();
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      final contentProvider = Provider.of<ContentProvider>(context, listen: false);
      final success = await contentProvider.downloadChapter(widget.chapter.id);

      setState(() {
        _isDownloading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chapter downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Open lesson view after successful download
        _openLessonView();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download chapter. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openLessonView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonViewScreen(chapter: widget.chapter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter Details'),
        actions: [
          Consumer<ContentProvider>(
            builder: (context, contentProvider, _) {
              // Find the updated chapter from the provider
              final updatedChapter = contentProvider.chapters.firstWhere(
                (c) => c.id == widget.chapter.id, 
                orElse: () => widget.chapter
              );
              
              return IconButton(
                icon: Icon(
                  updatedChapter.isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                onPressed: _toggleBookmark,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<ContentProvider>(
          builder: (context, contentProvider, _) {
            // Find the updated chapter from the provider
            final updatedChapter = contentProvider.chapters.firstWhere(
              (c) => c.id == widget.chapter.id, 
              orElse: () => widget.chapter
            );
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter Header
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          updatedChapter.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(updatedChapter.grade),
                              backgroundColor: Colors.blue.shade100,
                            ),
                            SizedBox(width: 8),
                            Chip(
                              label: Text(updatedChapter.subject),
                              backgroundColor: Colors.green.shade100,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(updatedChapter.curriculum),
                              backgroundColor: Colors.purple.shade100,
                            ),
                            SizedBox(width: 8),
                            Chip(
                              label: Text(updatedChapter.language),
                              backgroundColor: Colors.orange.shade100,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    updatedChapter.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Chapter Stats
                  Text(
                    'Chapter Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow('Total Pages', '${updatedChapter.totalPages}'),
                          Divider(),
                          _buildDetailRow('Semester', updatedChapter.semester),
                          Divider(),
                          _buildDetailRow(
                            'Status',
                            updatedChapter.isDownloaded
                                ? 'Downloaded'
                                : 'Not Downloaded',
                            iconData: updatedChapter.isDownloaded
                                ? Icons.check_circle
                                : Icons.cloud_download,
                            iconColor: updatedChapter.isDownloaded
                                ? Colors.green
                                : Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Prepare Button (access content)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isDownloading ? null : _downloadChapter,
                          icon: _isDownloading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(updatedChapter.isDownloaded
                                  ? Icons.visibility
                                  : Icons.download),
                          label: Text(updatedChapter.isDownloaded
                              ? 'View Content'
                              : 'Download & Prepare'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Teach Button (open in presentation mode)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: updatedChapter.isDownloaded
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LessonViewScreen(
                                        chapter: updatedChapter,
                                        teachMode: true,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          icon: Icon(Icons.present_to_all),
                          label: Text('Teach'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? iconData, Color? iconColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              if (iconData != null) ...[
                Icon(
                  iconData,
                  size: 16,
                  color: iconColor,
                ),
                SizedBox(width: 4),
              ],
              Text(value),
            ],
          ),
        ],
      ),
    );
  }
}
