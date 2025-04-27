import 'package:flutter/material.dart';
import '../school/school_selection_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  void _selectRole(BuildContext context, String role) {
    // Save the selected role to the database or backend

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SchoolSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Who Are You?'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select your role to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _selectRole(context, 'Student'),
                child: const Text('Student'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _selectRole(context, 'Parent'),
                child: const Text('Parent'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _selectRole(context, 'School Admin/Owner'),
                child: const Text('School Admin/Owner'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _selectRole(context, 'Other'),
                child: const Text('Other'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}