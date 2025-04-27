import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:educational_app/providers/user_provider.dart' as user_provider;
import 'package:educational_app/providers/auth_provider.dart' as auth_provider;

import '../screens/home/home_screen.dart';
import '../screens/chapter/subjects_screen.dart';
import '../screens/lesson/lessons_list_screen.dart';
import '../screens/bookmarks/bookmarks_screen.dart';
import '../screens/downloads/downloads_screen.dart';
import '../screens/auth/login_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<user_provider.UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.user;
          if (user == null) {
            return const Text('No user available');
          }

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
                      backgroundImage: user.profileImagePath != null
                          ? FileImage(user.profileImagePath as dynamic)
                          : null,
                      child: user.profileImagePath == null
                          ? Text(
                              user.firstName.isNotEmpty
                                  ? user.firstName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? user.phoneNumber ?? user.username ?? '',
                      style: const TextStyle(
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
                () => _navigateTo(context, const HomeScreen()),
              ),
              _buildNavItem(
                context,
                'Subjects',
                Icons.school,
                () => _navigateTo(context, const SubjectsScreen()),
              ),
              _buildNavItem(
                context,
                'Lessons',
                Icons.school,
                () => _navigateTo(context, const LessonsListScreen()),
              ),
              _buildNavItem(
                context,
                'Bookmarks',
                Icons.bookmark,
                () => _navigateTo(context, const BookmarksScreen()),
              ),
              _buildNavItem(
                context,
                'My Downloads',
                Icons.download_done,
                () => _navigateTo(context, const DownloadsScreen()),
              ),
              
              const Divider(),
              
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
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Perform logout
              final authProvider = Provider.of<auth_provider.AuthProvider>(context, listen: false);
              final userProvider = Provider.of<user_provider.UserProvider>(context, listen: false);
              
              authProvider.logout();
              userProvider.clearUserData();
              
              // Navigate to login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
