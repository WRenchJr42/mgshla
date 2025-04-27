import 'package:educational_app/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/app_theme.dart';
import 'package:educational_app/providers/auth_provider.dart' as providers;
import 'package:educational_app/providers/user_provider.dart' as providers;
import 'providers/content_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://jlifvxegyrwhhhkidehb.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsaWZ2eGVneXJ3aGhoa2lkZWhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU2MzU3NjIsImV4cCI6MjA2MTIxMTc2Mn0.emKRC313VoNn7qrJFm89i9YCnAf5t-lv5CLm8QzMIUA',
      authFlowType: AuthFlowType.pkce,
      debug: true
    );
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
    return;
  }
  
  // Lock orientation to portrait mode by default
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services
  final storageService = StorageService();
  await storageService.init();
  PdfService().initialize(storageService);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => providers.AuthProvider()),
        ChangeNotifierProvider(create: (_) => providers.UserProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        Provider.value(value: storageService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Delay the initialization to ensure the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      final authProvider = Provider.of<providers.AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();
      
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educational App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: !_isInitialized
          ? _buildSplashScreen()
          : Consumer<providers.AuthProvider>(
              builder: (context, authProvider, _) {
                return authProvider.isAuthenticated
                    ? const HomeScreen()
                    : const LoginScreen();
              },
            ),
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 80,
              color: AppTheme.lightTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Educational App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
