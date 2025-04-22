import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../models/chapter_model.dart';

class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Grade', 'Subject', 'Semester', 'Curriculum', 'Language'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            // Dialog Header
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Chapters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Consumer<ContentProvider>(
                    builder: (context, contentProvider, _) {
                      final hasFilters = contentProvider.activeFilters.isNotEmpty;
                      
                      return hasFilters
                          ? TextButton.icon(
                              onPressed: () {
                                contentProvider.clearAllFilters();
                              },
                              icon: Icon(
                                Icons.clear_all,
                                color: Colors.white70,
                                size: 16,
                              ),
                              label: Text(
                                'Clear All',
                                style: TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            )
                          : SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            
            // Tab Bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
            
            Divider(height: 1),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFilterOptions('grade'),
                  _buildFilterOptions('subject'),
                  _buildFilterOptions('semester'),
                  _buildFilterOptions('curriculum'),
                  _buildFilterOptions('language'),
                ],
              ),
            ),
            
            // Footer Actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptions(String filterType) {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, _) {
        final filterOptions = contentProvider.filterOptions;
        final activeFilters = contentProvider.activeFilters;
        List<String> options = [];
        
        switch (filterType) {
          case 'grade':
            options = filterOptions.grades;
            break;
          case 'subject':
            options = filterOptions.subjects;
            break;
          case 'semester':
            options = filterOptions.semesters;
            break;
          case 'curriculum':
            options = filterOptions.curriculums;
            break;
          case 'language':
            options = filterOptions.languages;
            break;
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = activeFilters[filterType] == option;
            
            return Card(
              elevation: isSelected ? 2 : 0,
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () {
                  if (isSelected) {
                    contentProvider.clearFilter(filterType);
                  } else {
                    contentProvider.setFilter(filterType, option);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
