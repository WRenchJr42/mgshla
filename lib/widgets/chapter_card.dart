import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chapter_model.dart';
import '../providers/content_provider.dart';
import '../screens/chapter/chapter_detail_screen.dart';

class ChapterCard extends StatelessWidget {
  final ChapterModel chapter;
  final bool showDeleteOption;

  ChapterCard({
    required this.chapter,
    this.showDeleteOption = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChapterDetailScreen(chapter: chapter),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter Header Color
            Container(
              color: _getHeaderColor(chapter.subject),
              height: 8,
            ),
            
            // Chapter Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject & Grade Row
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getSubjectColor(chapter.subject).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            chapter.subject,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getSubjectColor(chapter.subject),
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          chapter.grade,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Chapter Title
                    Text(
                      chapter.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 8),
                    
                    // Chapter Description
                    Text(
                      chapter.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    Spacer(),
                    
                    // Bottom Row - Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Download Status
                        if (chapter.isDownloaded)
                          Icon(
                            Icons.download_done,
                            size: 16,
                            color: Colors.green,
                          )
                        else
                          Icon(
                            Icons.download_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          
                        // Bookmark/Delete Button
                        showDeleteOption
                            ? _buildDeleteButton(context)
                            : _buildBookmarkButton(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<ContentProvider>(context, listen: false)
            .toggleBookmark(chapter.id);
      },
      child: Icon(
        chapter.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        size: 20,
        color: chapter.isBookmarked ? Colors.amber : Colors.grey,
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showDeleteConfirmation(context);
      },
      child: Icon(
        Icons.delete_outline,
        size: 20,
        color: Colors.red,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Download'),
        content: Text('Are you sure you want to delete this downloaded chapter?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ContentProvider>(context, listen: false)
                  .deleteDownloadedChapter(chapter.id);
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

  Color _getHeaderColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Colors.blue;
      case 'science':
        return Colors.green;
      case 'english':
        return Colors.purple;
      case 'social studies':
        return Colors.orange;
      case 'computer science':
        return Colors.teal;
      case 'physics':
        return Colors.indigo;
      case 'chemistry':
        return Colors.red;
      case 'biology':
        return Colors.lightGreen;
      default:
        return Colors.blueGrey;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Colors.blue.shade700;
      case 'science':
        return Colors.green.shade700;
      case 'english':
        return Colors.purple.shade700;
      case 'social studies':
        return Colors.orange.shade700;
      case 'computer science':
        return Colors.teal.shade700;
      case 'physics':
        return Colors.indigo.shade700;
      case 'chemistry':
        return Colors.red.shade700;
      case 'biology':
        return Colors.lightGreen.shade700;
      default:
        return Colors.blueGrey.shade700;
    }
  }
}
