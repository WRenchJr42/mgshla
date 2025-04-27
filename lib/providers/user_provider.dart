import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../models/school_model.dart';

class UserProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  UserModel? _user;
  List<SchoolModel> _schools = [];
  bool _isLoading = false;

  // Getters
  UserModel? get user => _user;
  List<SchoolModel> get schools => _schools;
  bool get isLoading => _isLoading;
  bool get isProfileComplete => _user?.isProfileComplete ?? false;

  UserProvider() {
    _loadUserData();
    _loadSchools();
  }

  // Load user data from Supabase
  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser != null) {
        final response = await _supabase
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();
        
        if (response != null) {
          _user = UserModel.fromJson({
            'id': response['id'],
            'phoneNumber': response['phone_number'],
            'email': response['email'],
            'username': response['username'],
            'firstName': response['first_name'] ?? '',
            'lastName': response['last_name'] ?? '',
            'dateOfBirth': response['date_of_birth'] ?? DateTime.now().toIso8601String(),
            'gender': response['gender'] ?? '',
            'profileImagePath': response['profile_image_path'],
            'role': response['role'] ?? '',
            'schoolId': response['school_id'],
          });
        } else {
          // Create initial user record
          final userData = {
            'id': authUser.id,
            'email': authUser.email,
            'created_at': DateTime.now().toIso8601String(),
            'first_name': '',
            'last_name': '',
            'date_of_birth': DateTime.now().toIso8601String(),
            'gender': '',
            'role': ''
          };

          await _supabase.from('users').insert(userData);
          
          _user = UserModel(
            id: authUser.id,
            email: authUser.email,
            firstName: '',
            lastName: '',
            dateOfBirth: DateTime.now(),
            gender: '',
            role: '',
            profileImagePath: null,
            schoolId: null,
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load schools from Supabase
  Future<void> _loadSchools() async {
    try {
      final response = await _supabase
        .from('schools')
        .select('id, name, created_at');
      
      _schools = (response as List).map((data) => SchoolModel(
        id: data['id'],
        name: data['name'],
      )).toList();
    } catch (e) {
      debugPrint('Error loading schools: $e');
    }
    notifyListeners();
  }

  // Create or update user with email
  Future<void> createOrUpdateUserWithEmail(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser != null) {
        // Check if user exists
        final existingUser = await _supabase
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

        if (existingUser != null) {
          // Update existing user
          _user = UserModel.fromJson({
            'id': existingUser['id'],
            'phoneNumber': existingUser['phone_number'],
            'email': existingUser['email'],
            'username': existingUser['username'],
            'firstName': existingUser['first_name'],
            'lastName': existingUser['last_name'],
            'dateOfBirth': existingUser['date_of_birth'],
            'gender': existingUser['gender'],
            'profileImagePath': existingUser['profile_image_path'],
            'role': existingUser['role'],
            'schoolId': existingUser['school_id'],
          });
        } else {
          // Create new user
          final userData = {
            'id': authUser.id,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
            'first_name': '',
            'last_name': '',
            'date_of_birth': DateTime.now().toIso8601String(),
            'gender': '',
            'role': '',
          };

          await _supabase.from('users').insert(userData);
          _user = UserModel(
            id: authUser.id,
            email: email,
            firstName: '',
            lastName: '',
            dateOfBirth: DateTime.now(),
            gender: '',
            role: '',
            profileImagePath: null,
            schoolId: null,
          );
        }
      }
    } catch (e) {
      debugPrint('Error creating/updating user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImagePath,
  }) async {
    if (_user == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final updates = {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String(),
        if (gender != null) 'gender': gender,
        if (profileImagePath != null) 'profile_image_path': profileImagePath,
      };

      await _supabase
        .from('users')
        .update(updates)
        .eq('id', _user!.id);

      _user = _user!.copyWith(
        firstName: firstName ?? _user!.firstName,
        lastName: lastName ?? _user!.lastName,
        dateOfBirth: dateOfBirth ?? _user!.dateOfBirth,
        gender: gender ?? _user!.gender,
        profileImagePath: profileImagePath ?? _user!.profileImagePath,
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set user role
  Future<void> setUserRole(String role) async {
    if (_user == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase
        .from('users')
        .update({'role': role})
        .eq('id', _user!.id);

      _user = _user!.copyWith(role: role);
    } catch (e) {
      debugPrint('Error setting user role: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set user school
  Future<void> setUserSchool(String schoolId) async {
    if (_user == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase
        .from('users')
        .update({'school_id': schoolId})
        .eq('id', _user!.id);

      _user = _user!.copyWith(schoolId: schoolId);
    } catch (e) {
      debugPrint('Error setting user school: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new school
  Future<SchoolModel> addSchool(String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
        .from('schools')
        .insert({'name': name})
        .select()
        .single();

      final newSchool = SchoolModel(
        id: response['id'],
        name: response['name'],
      );
      _schools.add(newSchool);
      return newSchool;
    } catch (e) {
      debugPrint('Error adding school: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search schools by name
  List<SchoolModel> searchSchools(String query) {
    if (query.isEmpty) {
      return _schools;
    }
    
    return _schools.where(
      (school) => school.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Clear user data (for logout)
  Future<void> clearUserData() async {
    _user = null;
    notifyListeners();
  }
}
