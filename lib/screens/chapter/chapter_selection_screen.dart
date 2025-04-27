import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/content_provider.dart';
import '../../widgets/filter_dialog.dart';
import '../home/home_screen.dart';

class ChapterSelectionScreen extends StatefulWidget {
  const ChapterSelectionScreen({super.key});

  @override
  _ChapterSelectionScreenState createState() => _ChapterSelectionScreenState();
}

class _ChapterSelectionScreenState extends State<ChapterSelectionScreen> {
  bool _isLoading = false;
  final List<String> _selectedFilters = [];

  @override
  void initState() {
    super.initState();
    // Reset all active filters when opening this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContentProvider>(context, listen: false).clearAllFilters();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => const FilterDialog(),
    );
  }

  Future<void> _continueToHome() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you might save user preferences or selected filters
      await Future.delayed(const Duration(seconds: 1)); // Simulate network request
      
      setState(() {
        _isLoading = false;
      });
      
      // Navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save preferences. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Chapters'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filter Content',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Select filters to find relevant chapters',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Filter Categories
              Consumer<ContentProvider>(
                builder: (context, contentProvider, _) {
                  final filterOptions = contentProvider.filterOptions;
                  final activeFilters = contentProvider.activeFilters;
                  
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFilterButton(
                        'Grade',
                        activeFilters['grade'],
                        () => _showFilterDialog(),
                      ),
                      _buildFilterButton(
                        'Subject',
                        activeFilters['subject'],
                        () => _showFilterDialog(),
                      ),
                      _buildFilterButton(
                        'Semester',
                        activeFilters['semester'],
                        () => _showFilterDialog(),
                      ),
                      _buildFilterButton(
                        'Curriculum',
                        activeFilters['curriculum'],
                        () => _showFilterDialog(),
                      ),
                      _buildFilterButton(
                        'Language',
                        activeFilters['language'],
                        () => _showFilterDialog(),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Selected Filters
              Consumer<ContentProvider>(
                builder: (context, contentProvider, _) {
                  final activeFilters = contentProvider.activeFilters;
                  
                  if (activeFilters.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No filters selected. Tap on any category to select filters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }
                  
                  return Wrap(
                    spacing: 8,
                    children: activeFilters.entries.map((entry) {
                      return Chip(
                        label: Text('${entry.key}: ${entry.value}'),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          contentProvider.clearFilter(entry.key);
                        },
                        backgroundColor: Colors.blue.shade100,
                      );
                    }).toList(),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Clear Filters Button
              Consumer<ContentProvider>(
                builder: (context, contentProvider, _) {
                  if (contentProvider.activeFilters.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  return TextButton.icon(
                    onPressed: () {
                      contentProvider.clearAllFilters();
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All Filters'),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Preview of filtered chapters
              Expanded(
                child: Consumer<ContentProvider>(
                  builder: (context, contentProvider, _) {
                    if (contentProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    
                    final filteredChapters = contentProvider.filteredChapters;
                    
                    if (filteredChapters.isEmpty) {
                      return const Center(
                        child: Text(
                          'No chapters found matching the selected filters.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: filteredChapters.length,
                      itemBuilder: (context, index) {
                        final chapter = filteredChapters[index];
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(chapter.title),
                            subtitle: Text(
                              '${chapter.subject} | ${chapter.grade} | ${chapter.curriculum}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Continue Button
              ElevatedButton(
                onPressed: _isLoading ? null : _continueToHome,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String? activeValue, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: activeValue != null
              ? Theme.of(context).primaryColor
              : Colors.grey.shade400,
        ),
        backgroundColor: activeValue != null
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(activeValue ?? label),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
    );
  }
}
