import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../school/school_selection_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roleOptions = [
    {
      'role': 'student',
      'title': 'Student',
      'icon': Icons.school,
      'color': Colors.blue,
      'description': 'Access study materials and lessons'
    },
    {
      'role': 'parent',
      'title': 'Parent',
      'icon': Icons.people,
      'color': Colors.green,
      'description': 'Monitor your child\'s progress'
    },
    {
      'role': 'school_admin',
      'title': 'School Admin/Owner',
      'icon': Icons.admin_panel_settings,
      'color': Colors.purple,
      'description': 'Manage school content and users'
    },
    {
      'role': 'other',
      'title': 'Other',
      'icon': Icons.person,
      'color': Colors.orange,
      'description': 'Access general educational content'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Check if user already has a role
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null && userProvider.user!.role.isNotEmpty) {
      _selectedRole = userProvider.user!.role;
    }
  }

  Future<void> _saveRole() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role.'),
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
      
      await userProvider.setUserRole(_selectedRole!);
      
      setState(() {
        _isLoading = false;
      });
      
      // Navigate to school selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SchoolSelectionScreen()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save role. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Who are you?'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select your role',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Choose the option that best describes you',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Role options
              Expanded(
                child: ListView.builder(
                  itemCount: _roleOptions.length,
                  itemBuilder: (context, index) {
                    final role = _roleOptions[index];
                    final isSelected = _selectedRole == role['role'];
                    
                    return Card(
                      elevation: isSelected ? 4 : 1,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? role['color']
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedRole = role['role'];
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: role['color'].withOpacity(0.2),
                                radius: 24,
                                child: Icon(
                                  role['icon'],
                                  color: role['color'],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      role['title'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      role['description'],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: role['color'],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Continue Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRole,
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
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
