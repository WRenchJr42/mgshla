import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../widgets/drawer_menu.dart';
import '../chapter/chapter_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
      ),
      drawer: DrawerMenu(),
      body: SafeArea(
        child: Consumer<ContentProvider>(
          builder: (context, contentProvider, _) {
            final bookmarkedChapters = contentProvider.bookmarkedChapters;
            
            if (contentProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (bookmarkedChapters.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No bookmarked chapters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bookmark chapters to find them here',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: bookmarkedChapters.length,
              itemBuilder: (context, index) {
                final chapter = bookmarkedChapters[index];
                
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.bookmark,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(chapter.title),
                    subtitle: Text(
                      '${chapter.subject} | ${chapter.grade}',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterDetailScreen(
                            chapter: chapter,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}