class Validators {
  // Validate Phone Number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Basic validation for phone number
    // In a real app, you'd want more sophisticated validation
    // based on country formats
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  // Validate Email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Validate Name
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    
    // Check for valid name (letters, spaces, hyphens, apostrophes)
    final nameRegExp = RegExp(r"^[a-zA-Z\s\-']+$");
    
    if (!nameRegExp.hasMatch(value)) {
      return 'Please enter a valid $fieldName';
    }
    
    return null;
  }
  
  // Validate Password (if needed in future)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  // Validate OTP (basic validation)
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    
    final otpRegExp = RegExp(r'^[0-9]{6}$');
    if (!otpRegExp.hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    
    return null;
  }
  
  // Validate School Name
  static String? validateSchoolName(String? value) {
    if (value == null || value.isEmpty) {
      return 'School name is required';
    }
    
    if (value.length < 3) {
      return 'School name must be at least 3 characters';
    }
    
    return null;
  }
}
