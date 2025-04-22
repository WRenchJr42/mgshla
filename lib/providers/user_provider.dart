import 'package:flutter/material.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../models/school_model.dart';
import '../services/storage_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  List<SchoolModel> _schools = [];
  bool _isLoading = false;

  // Service instance for storage
  final StorageService _storageService = StorageService();

  // Getters
  UserModel? get user => _user;
  List<SchoolModel> get schools => _schools;
  bool get isLoading => _isLoading;
  bool get isProfileComplete => _user?.isProfileComplete ?? false;

  UserProvider() {
    _loadUserData();
    _loadSchools();
  }

  // Load user data from local storage
  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _storageService.getUserData();
      if (userData != null) {
        _user = UserModel.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load schools from local storage or initialize with mock data
  Future<void> _loadSchools() async {
    try {
      final schoolsData = await _storageService.getSchools();
      if (schoolsData != null) {
        final List<dynamic> decodedData = jsonDecode(schoolsData);
        _schools = decodedData.map((data) => SchoolModel.fromJson(data)).toList();
      } else {
        // Initialize with some mock schools if none are stored
        _schools = [
          SchoolModel(id: '1', name: 'Delhi Public School'),
          SchoolModel(id: '2', name: 'Kendriya Vidyalaya'),
          SchoolModel(id: '3', name: 'St. Xavier\'s High School'),
          SchoolModel(id: '4', name: 'DAV Public School'),
          SchoolModel(id: '5', name: 'Ryan International School'),
        ];
        // Save the mock schools
        await _saveSchools();
      }
    } catch (e) {
      debugPrint('Error loading schools: $e');
    }
    notifyListeners();
  }

  // Save user data to local storage
  Future<void> _saveUserData() async {
    if (_user != null) {
      await _storageService.saveUserData(jsonEncode(_user!.toJson()));
    }
  }

  // Save schools to local storage
  Future<void> _saveSchools() async {
    final schoolsJson = jsonEncode(_schools.map((school) => school.toJson()).toList());
    await _storageService.saveSchools(schoolsJson);
  }

  // Create new user
  Future<void> createUser({
    required String phoneOrEmail,
    required String authMethod,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      
      _user = UserModel(
        id: id,
        phoneNumber: authMethod == 'phone' ? phoneOrEmail : null,
        email: authMethod == 'email' ? phoneOrEmail : null,
        firstName: '',
        lastName: '',
        dateOfBirth: DateTime.now(),
        gender: '',
        role: '',
        profileImagePath: null,
        schoolId: null,
      );

      await _saveUserData();
    } catch (e) {
      debugPrint('Error creating user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile information
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
      _user = _user!.copyWith(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        profileImagePath: profileImagePath,
      );

      await _saveUserData();
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
      _user = _user!.copyWith(role: role);
      await _saveUserData();
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
      _user = _user!.copyWith(schoolId: schoolId);
      await _saveUserData();
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
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      final newSchool = SchoolModel(id: id, name: name);
      
      _schools.add(newSchool);
      await _saveSchools();
      
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
    await _storageService.clearUserData();
    notifyListeners();
  }
}
