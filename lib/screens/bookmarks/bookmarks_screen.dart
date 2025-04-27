import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../widgets/drawer_menu.dart';
import '../chapter/chapter_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      drawer: const DrawerMenu(),
      body: SafeArea(
        child: Consumer<ContentProvider>(
          builder: (context, contentProvider, _) {
            final bookmarkedChapters = contentProvider.bookmarkedChapters;
            
            if (contentProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (bookmarkedChapters.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bookmarked chapters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bookmark chapters to find them here',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedChapters.length,
              itemBuilder: (context, index) {
                final chapter = bookmarkedChapters[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.bookmark,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(chapter.title),
                    subtitle: Text(
                      '${chapter.subject} | ${chapter.grade}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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