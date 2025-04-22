import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/content_provider.dart';
import '../../widgets/drawer_menu.dart';
import '../../widgets/chapter_card.dart';
import '../../widgets/filter_button.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search chapters...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {});
                },
                autofocus: true,
              )
            : Text('Home'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          FilterButton(),
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
        child: Consumer<ContentProvider>(
          builder: (context, contentProvider, _) {
            if (contentProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List<dynamic> chaptersToShow;
            
            if (_isSearching && _searchController.text.isNotEmpty) {
              chaptersToShow = contentProvider.searchChapters(_searchController.text.trim());
            } else {
              chaptersToShow = contentProvider.filteredChapters;
            }
            
            if (chaptersToShow.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _isSearching && _searchController.text.isNotEmpty
                          ? 'No chapters found matching "${_searchController.text}"'
                          : 'No chapters available with the current filters',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    if (_isSearching && _searchController.text.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        child: Text('Clear Search'),
                      ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: chaptersToShow.length,
                itemBuilder: (context, index) {
                  return ChapterCard(chapter: chaptersToShow[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
