class AppConstants {
  // App Info
  static const String appName = 'Educational App';
  static const String appVersion = '1.0.0';
  
  // SharedPreferences Keys
  static const String keyUserData = 'user_data';
  static const String keySchools = 'schools';
  static const String keyChapters = 'chapters';
  
  // Local Storage Directories
  static const String pdfDownloadsDir = 'downloads/pdf';
  
  // Gender Options
  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];
  
  // User Roles
  static const String roleStudent = 'student';
  static const String roleParent = 'parent';
  static const String roleSchoolAdmin = 'school_admin';
  static const String roleOther = 'other';
  
  // PDF Viewing Modes
  static const String modePrepare = 'prepare';
  static const String modeTeach = 'teach';
  
  // Timeouts (in seconds)
  static const int otpResendTimeout = 30;
  static const int downloadTimeout = 60;
  
  // Error Messages
  static const String errorPhoneInvalid = 'Please enter a valid phone number';
  static const String errorEmailInvalid = 'Please enter a valid email address';
  static const String errorFieldEmpty = 'This field cannot be empty';
  static const String errorNameInvalid = 'Please enter a valid name';
  static const String errorDownloadFailed = 'Failed to download the file. Please try again.';
  static const String errorPdfLoadFailed = 'Failed to load PDF. The file may be corrupted.';
  
  // Success Messages
  static const String successProfileUpdated = 'Profile updated successfully';
  static const String successDownloadComplete = 'Download completed successfully';
  static const String successBookmarkAdded = 'Bookmark added';
  static const String successBookmarkRemoved = 'Bookmark removed';
  
  // API Endpoints
  // These would be actual API URLs in a real app
  static const String apiBaseUrl = 'https://api.educationalapp.com';
  static const String apiDownloadPdf = '$apiBaseUrl/download/pdf';
  
  // Demo Assets
  static const String dummyPdfPath = 'assets/dummy.pdf';
}
