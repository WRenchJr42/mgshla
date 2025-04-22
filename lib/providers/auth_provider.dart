import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _authMethod; // 'phone' or 'email'
  String? _phoneNumber;
  String? _email;
  String? _verificationId;
  String? _otp;
  Timer? _resendTimer;
  int _resendTimeLeft = 0;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get authMethod => _authMethod;
  String? get phoneNumber => _phoneNumber;
  String? get email => _email;
  String? get verificationId => _verificationId;
  int get resendTimeLeft => _resendTimeLeft;

  // For demo purposes, we'll use a mock OTP verification
  // In a real app, this would use Firebase Auth or similar service
  Future<bool> sendOTP({required String phoneOrEmail, required String method}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Store the auth method and credential
      _authMethod = method;
      if (method == 'phone') {
        _phoneNumber = phoneOrEmail;
        _email = null;
      } else {
        _email = phoneOrEmail;
        _phoneNumber = null;
      }

      // Mock server delay
      await Future.delayed(Duration(seconds: 2));

      // Generate a random verification ID
      _verificationId = _generateRandomString(16);
      
      // For testing purposes, we'll set a fixed OTP
      // In production, this would be sent via SMS or email
      _otp = '123456';
      
      // Start the resend timer
      _startResendTimer();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOTP(String enteredOTP) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mock verification delay
      await Future.delayed(Duration(seconds: 1));

      // Check if the entered OTP matches the generated one
      if (enteredOTP == _otp) {
        _isAuthenticated = true;
        _cancelResendTimer();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _authMethod = null;
    _phoneNumber = null;
    _email = null;
    _verificationId = null;
    _otp = null;
    _cancelResendTimer();
    notifyListeners();
  }

  void _startResendTimer() {
    _resendTimeLeft = 30; // 30 seconds countdown
    _cancelResendTimer();
    
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimeLeft > 0) {
        _resendTimeLeft--;
        notifyListeners();
      } else {
        _cancelResendTimer();
      }
    });
  }

  void _cancelResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }

  // Helper method to generate a random string for verification ID
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      List.generate(length, (index) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  @override
  void dispose() {
    _cancelResendTimer();
    super.dispose();
  }
}
