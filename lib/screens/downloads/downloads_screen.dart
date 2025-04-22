import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../widgets/drawer_menu.dart';
import '../lesson/lesson_view_screen.dart';

class DownloadsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Downloads'),
      ),
      drawer: DrawerMenu(),
      body: SafeArea(
        child: Consumer<ContentProvider>(
          builder: (context, contentProvider, _) {
            final downloadedChapters = contentProvider.downloadedChapters;
            
            if (contentProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (downloadedChapters.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_done_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No downloaded content',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Downloaded chapters will appear here',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: downloadedChapters.length,
              itemBuilder: (context, index) {
                final chapter = downloadedChapters[index];
                
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.download_done,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chapter.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${chapter.subject} | ${chapter.grade}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                _showDeleteConfirmation(context, contentProvider, chapter.id);
                              },
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              label: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red.shade200),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LessonViewScreen(
                                      chapter: chapter,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.visibility),
                              label: Text('View'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, ContentProvider contentProvider, String chapterId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Download'),
        content: Text('Are you sure you want to delete this downloaded chapter? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Delete the downloaded chapter
              await contentProvider.deleteDownloadedChapter(chapterId);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chapter deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}