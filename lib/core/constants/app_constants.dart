class AppConstants {
  // App Info
  static const String appName = 'Workshop Booking System';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String workshopsCollection = 'workshops';
  static const String timeSlotsCollection = 'timeSlots';
  static const String bookingsCollection = 'bookings';
  static const String paymentsCollection = 'payments';
  static const String feedbackCollection = 'feedback';
  
  // Storage Paths
  static const String workshopImagesPath = 'workshop_images';
  static const String userAvatarsPath = 'user_avatars';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);
}