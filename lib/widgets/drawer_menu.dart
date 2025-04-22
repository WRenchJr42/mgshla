import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/chapter/chapter_selection_screen.dart';
import '../screens/lesson/lessons_list_screen.dart';
import '../screens/bookmarks/bookmarks_screen.dart';
import '../screens/downloads/downloads_screen.dart';
import '../screens/auth/phone_email_screen.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.user;
          
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header with user info
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: user?.profileImagePath != null
                          ? FileImage(user!.profileImagePath as dynamic)
                          : null,
                      child: user?.profileImagePath == null
                          ? Text(
                              user?.firstName.isNotEmpty == true
                                  ? user!.firstName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user?.email ?? user?.phoneNumber ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Navigation Items
              _buildNavItem(
                context,
                'Home',
                Icons.home,
                () => _navigateTo(context, HomeScreen()),
              ),
              _buildNavItem(
                context,
                'Chapters',
                Icons.menu_book,
                () => _navigateTo(context, ChapterSelectionScreen()),
              ),
              _buildNavItem(
                context,
                'Lessons',
                Icons.school,
                () => _navigateTo(context, LessonsListScreen()),
              ),
              _buildNavItem(
                context,
                'Bookmarks',
                Icons.bookmark,
                () => _navigateTo(context, BookmarksScreen()),
              ),
              _buildNavItem(
                context,
                'My Downloads',
                Icons.download_done,
                () => _navigateTo(context, DownloadsScreen()),
              ),
              
              Divider(),
              
              // Settings and Logout
              _buildNavItem(
                context,
                'Settings',
                Icons.settings,
                () {},
              ),
              _buildNavItem(
                context,
                'Logout',
                Icons.logout,
                () => _confirmLogout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
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
              
              // Perform logout
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              
              authProvider.logout();
              userProvider.clearUserData();
              
              // Navigate to login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PhoneEmailScreen()),
              );
            },
            child: Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
