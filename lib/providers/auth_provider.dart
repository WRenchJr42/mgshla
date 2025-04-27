import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'user_provider.dart';

class AuthProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _authMethod;
  String? _email;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get authMethod => _authMethod;
  String? get email => _email;

  Future<bool> login(String email, String password, {UserProvider? userProvider}) async {
    try {
      _isLoading = true;
      _authMethod = 'email';
      _email = email;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isAuthenticated = true;
        await _storeAuthData(
          token: response.session?.accessToken ?? '',
          method: 'email',
          identifier: email,
        );
        
        if (userProvider != null) {
          await userProvider.createOrUpdateUserWithEmail(email);
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      return response.user != null;
    } catch (e) {
      debugPrint('SignUp error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      final session = _supabase.auth.currentSession;
      _isAuthenticated = session != null;
      
      if (_isAuthenticated) {
        _authMethod = 'email';
        _email = session?.user.email;
      }
      
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _isAuthenticated = false;
      _authMethod = null;
      _email = null;
      
      // Clear stored login data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<void> _storeAuthData({
    required String token,
    required String method,
    required String identifier,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_method', method);
      await prefs.setString('email', identifier);
      await prefs.setBool('is_authenticated', true);
    } catch (e) {
      debugPrint('Error storing auth data: $e');
    }
  }

  // Check if user exists by email
  Future<bool> userExists(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('Error checking if user exists: $e');
      return false;
    }
  }
}
