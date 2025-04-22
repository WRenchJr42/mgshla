import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../chapter/chapter_selection_screen.dart';

class SchoolSelectionScreen extends StatefulWidget {
  @override
  _SchoolSelectionScreenState createState() => _SchoolSelectionScreenState();
}

class _SchoolSelectionScreenState extends State<SchoolSelectionScreen> {
  final _searchController = TextEditingController();
  final _newSchoolController = TextEditingController();
  String? _selectedSchoolId;
  bool _isLoading = false;
  bool _isAddingSchool = false;

  @override
  void dispose() {
    _searchController.dispose();
    _newSchoolController.dispose();
    super.dispose();
  }

  void _showAddSchoolDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New School'),
        content: TextField(
          controller: _newSchoolController,
          decoration: InputDecoration(
            labelText: 'School Name',
            hintText: 'Enter the name of your school',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_newSchoolController.text.trim().isEmpty) {
                return;
              }
              
              Navigator.of(context).pop();
              
              setState(() {
                _isAddingSchool = true;
              });
              
              try {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final newSchool = await userProvider.addSchool(_newSchoolController.text.trim());
                
                setState(() {
                  _selectedSchoolId = newSchool.id;
                  _isAddingSchool = false;
                });
                
                _newSchoolController.clear();
              } catch (e) {
                setState(() {
                  _isAddingSchool = false;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add school. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _continueWithSelectedSchool() async {
    if (_selectedSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a school.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      await userProvider.setUserSchool(_selectedSchoolId!);
      
      setState(() {
        _isLoading = false;
      });
      
      // Navigate to chapter selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChapterSelectionScreen()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save school selection. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your School'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Find your school',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 8),
              
              Text(
                'Search for your school or add a new one',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 24),
              
              // Search Box
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search for your school',
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
              
              SizedBox(height: 16),
              
              // Add School Button
              OutlinedButton.icon(
                onPressed: _isAddingSchool ? null : _showAddSchoolDialog,
                icon: _isAddingSchool
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.add),
                label: Text('Add New School'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              
              SizedBox(height: 16),
              
              // School List
              Expanded(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    final searchQuery = _searchController.text.trim().toLowerCase();
                    final filteredSchools = userProvider.searchSchools(searchQuery);
                    
                    if (filteredSchools.isEmpty) {
                      return Center(
                        child: Text(
                          searchQuery.isEmpty
                              ? 'No schools available. Add a new one.'
                              : 'No schools found matching "$searchQuery"',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: filteredSchools.length,
                      itemBuilder: (context, index) {
                        final school = filteredSchools[index];
                        final isSelected = _selectedSchoolId == school.id;
                        
                        return Card(
                          elevation: isSelected ? 4 : 1,
                          margin: EdgeInsets.symmetric(vertical: 4),
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
                              setState(() {
                                _selectedSchoolId = school.id;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.withOpacity(0.2),
                                    child: Text(
                                      school.name[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      school.name,
                                      style: TextStyle(
                                        fontSize: 16,
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
                ),
              ),
              
              SizedBox(height: 16),
              
              // Continue Button
              ElevatedButton(
                onPressed: _isLoading ? null : _continueWithSelectedSchool,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Continue'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
