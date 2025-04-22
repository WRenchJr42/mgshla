import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../models/chapter_model.dart';
import '../../widgets/filter_dialog.dart';
import '../../widgets/drawer_menu.dart';
import '../../widgets/filter_button.dart';
import '../../widgets/chapter_card.dart';
import 'chapter_detail_screen.dart';

class ChapterSelectionScreen extends StatefulWidget {
  @override
  _ChapterSelectionScreenState createState() => _ChapterSelectionScreenState();
}

class _ChapterSelectionScreenState extends State<ChapterSelectionScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = false;

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

  void _openFilterDialog() async {
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => FilterDialog(
        filterOptions: contentProvider.filterOptions,
        activeFilters: contentProvider.activeFilters,
      ),
    );
    
    if (result != null) {
      // Apply filters
      if (result.isEmpty) {
        contentProvider.clearAllFilters();
      } else {
        result.forEach((key, value) {
          contentProvider.setFilter(key, value);
        });
      }
    }
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
            : Text('Chapters'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          FilterButton(),
        ],
      ),
      drawer: DrawerMenu(),
      body: SafeArea(
        child: Consumer<ContentProvider>(
          builder: (context, contentProvider, _) {
            if (_isLoading || contentProvider.isLoading) {
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
                      _isSearching && _searchController.text.isNotEmpty
                          ? Icons.search_off
                          : Icons.filter_list_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _isSearching && _searchController.text.isNotEmpty
                          ? 'No chapters found matching "${_searchController.text}"'
                          : 'No chapters match your filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      _isSearching && _searchController.text.isNotEmpty
                          ? 'Try a different search term'
                          : 'Try removing some filters',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_isSearching && _searchController.text.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                        icon: Icon(Icons.clear),
                        label: Text('Clear Search'),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {
                          contentProvider.clearAllFilters();
                        },
                        icon: Icon(Icons.clear_all),
                        label: Text('Clear Filters'),
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
