import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/user_provider.dart';
import '../../widgets/drawer_menu.dart';
import '../chapter/subjects_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, int> _subjectsCount = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubjectsCount();
  }

  Future<void> _loadSubjectsCount() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final List<FileObject> files = await _supabase.storage
          .from('pdf')
          .list();

      final Map<String, int> counts = {};
      for (var file in files) {
        final parts = file.name.split('/');
        if (parts.isNotEmpty) {
          final subject = parts[0];
          counts[subject] = (counts[subject] ?? 0) + 1;
        }
      }

      setState(() {
        _subjectsCount = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
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
                            style: const TextStyle(
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
      drawer: const DrawerMenu(),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadSubjectsCount,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                            final user = userProvider.user;
                            return Text(
                              'Welcome back, ${user?.firstName ?? 'Student'}!',
                              style: Theme.of(context).textTheme.headlineMedium,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your Subjects',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: _subjectsCount.length,
                          itemBuilder: (context, index) {
                            final subject = _subjectsCount.keys.elementAt(index);
                            final count = _subjectsCount[subject] ?? 0;
                            
                            return Card(
                              elevation: 4,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SubjectsScreen(
                                        initialSubject: subject,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _getSubjectIcon(subject),
                                        size: 48,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        subject.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '$count chapters',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'physics':
        return Icons.science;
      case 'chemistry':
        return Icons.science_outlined;
      case 'biology':
        return Icons.biotech;
      default:
        return Icons.book;
    }
  }
}
