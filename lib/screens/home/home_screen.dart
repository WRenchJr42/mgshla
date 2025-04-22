import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/content_provider.dart';
import '../../widgets/drawer_menu.dart';
import '../../widgets/chapter_card.dart';
import '../chapter/chapter_detail_screen.dart';
import '../lesson/lesson_view_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final user = userProvider.user;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to profile page
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: user?.profileImagePath != null
                        ? FileImage(user!.profileImagePath as dynamic)
                        : null,
                    child: user?.profileImagePath == null
                        ? Text(
                            user?.firstName.isNotEmpty == true
                                ? user!.firstName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: SafeArea(
        child: Consumer2<ContentProvider, UserProvider>(
          builder: (context, contentProvider, userProvider, _) {
            if (contentProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final recentChapters = contentProvider.downloadedChapters.take(3).toList();
            final bookmarkedChapters = contentProvider.bookmarkedChapters.take(3).toList();
            
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    _buildWelcomeSection(userProvider.user?.firstName ?? 'User'),
                    
                    SizedBox(height: 24),
                    
                    // Analytics section
                    _buildAnalyticsSection(contentProvider),
                    
                    SizedBox(height: 24),
                    
                    // Recent Chapters
                    _buildSectionHeader(
                      'Recently Downloaded',
                      contentProvider.downloadedChapters.length,
                      onViewAll: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DrawerMenu()),
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    recentChapters.isEmpty
                        ? _buildEmptyState('No downloaded chapters yet', 'Download chapters to see them here')
                        : _buildHorizontalChapterList(recentChapters),
                    
                    SizedBox(height: 24),
                    
                    // Bookmarked Chapters
                    _buildSectionHeader(
                      'Bookmarked',
                      contentProvider.bookmarkedChapters.length,
                      onViewAll: () {
                        Navigator.pushNamed(context, '/bookmarks');
                      },
                    ),
                    SizedBox(height: 8),
                    bookmarkedChapters.isEmpty
                        ? _buildEmptyState('No bookmarked chapters yet', 'Bookmark chapters to see them here')
                        : _buildHorizontalChapterList(bookmarkedChapters),
                    
                    SizedBox(height: 24),
                    
                    // Continue Learning Section
                    contentProvider.downloadedChapters.isNotEmpty
                        ? _buildContinueLearningSection(contentProvider.downloadedChapters.first)
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildWelcomeSection(String firstName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          firstName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAnalyticsSection(ContentProvider contentProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticItem(
                  contentProvider.downloadedChapters.length.toString(),
                  'Downloads',
                  Icons.download_done,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildAnalyticItem(
                  contentProvider.bookmarkedChapters.length.toString(),
                  'Bookmarks',
                  Icons.bookmark,
                  Colors.amber,
                ),
              ),
              Expanded(
                child: _buildAnalyticItem(
                  contentProvider.chapters.length.toString(),
                  'Available',
                  Icons.menu_book,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title, int count, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title ($count)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (count > 0 && onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text('View All'),
            style: TextButton.styleFrom(
              minimumSize: Size(50, 30),
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
      ],
    );
  }
  
  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildHorizontalChapterList(List<dynamic> chapters) {
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapterDetailScreen(chapter: chapter),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          chapter.subject,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Title
                      Text(
                        chapter.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      // Grade & curriculum
                      Text(
                        '${chapter.grade} | ${chapter.curriculum}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Spacer(),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (chapter.isDownloaded)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildContinueLearningSection(dynamic chapter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Continue Learning',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonViewScreen(chapter: chapter),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${chapter.subject} | ${chapter.grade}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
