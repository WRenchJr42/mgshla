import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import 'filter_dialog.dart';

class FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Consumer<ContentProvider>(
        builder: (context, contentProvider, child) {
          final filterCount = contentProvider.activeFilters.length;
          
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.filter_alt),
              if (filterCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      filterCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      onPressed: () async {
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
      },
      tooltip: 'Filter',
    );
  }
}