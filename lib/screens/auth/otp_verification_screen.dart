import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../profile/profile_setup_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneOrEmail;
  final String authMethod;

  OtpVerificationScreen({
    required this.phoneOrEmail,
    required this.authMethod,
  });

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the OTP.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final success = await authProvider.verifyOTP(_otpController.text.trim());

    if (success) {
      // Create or update user
      await userProvider.createUser(
        phoneOrEmail: widget.phoneOrEmail,
        authMethod: widget.authMethod,
      );

      setState(() {
        _isLoading = false;
      });

      // Navigate to profile setup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.sendOTP(
      phoneOrEmail: widget.phoneOrEmail,
      method: widget.authMethod,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.verified_user,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              
              SizedBox(height: 24),
              
              Text(
                'Verification',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 8),
              
              Text(
                widget.authMethod == 'phone'
                    ? 'We have sent a verification code to ${widget.phoneOrEmail}'
                    : 'We have sent a verification code to ${widget.phoneOrEmail}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 32),
              
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, letterSpacing: 10),
                decoration: InputDecoration(
                  hintText: '- - - - - -',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Resend timer
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return authProvider.resendTimeLeft > 0
                      ? Text(
                          'Resend OTP in ${authProvider.resendTimeLeft} seconds',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        )
                      : TextButton(
                          onPressed: _resendOTP,
                          child: Text('Resend OTP'),
                        );
                },
              ),
              
              SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Verify'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              SizedBox(height: 16),
              
              // For demo - Auto-fill OTP (remove in production)
              TextButton(
                onPressed: () {
                  _otpController.text = '123456'; // Use the fixed OTP from AuthProvider
                },
                child: Text(
                  'Demo: Auto-fill OTP (123456)',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
