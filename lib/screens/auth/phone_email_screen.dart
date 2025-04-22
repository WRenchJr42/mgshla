import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import 'otp_verification_screen.dart';

class PhoneEmailScreen extends StatefulWidget {
  @override
  _PhoneEmailScreenState createState() => _PhoneEmailScreenState();
}

class _PhoneEmailScreenState extends State<PhoneEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _authMethod = 'phone'; // Default to phone authentication
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    String phoneOrEmail = _authMethod == 'phone'
        ? _phoneController.text.trim()
        : _emailController.text.trim();

    final success = await authProvider.sendOTP(
      phoneOrEmail: phoneOrEmail,
      method: _authMethod,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            phoneOrEmail: phoneOrEmail,
            authMethod: _authMethod,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo or Icon Placeholder
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.school,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                
                SizedBox(height: 24),
                Text(
                  'Welcome to Educational App',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 8),
                Text(
                  'Please sign in to continue',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 32),
                
                // Authentication Method Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _authMethod = 'phone';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _authMethod == 'phone'
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          foregroundColor: _authMethod == 'phone'
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: Text('Phone'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _authMethod = 'email';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _authMethod == 'email'
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          foregroundColor: _authMethod == 'email'
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: Text('Email'),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Phone field
                if (_authMethod == 'phone')
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      hintText: 'Enter your phone number',
                    ),
                    validator: (value) => Validators.validatePhone(value),
                  ),
                
                // Email field
                if (_authMethod == 'email')
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                      hintText: 'Enter your email address',
                    ),
                    validator: (value) => Validators.validateEmail(value),
                  ),
                
                SizedBox(height: 32),
                
                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Send OTP'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
