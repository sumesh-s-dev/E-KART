class AppConfig {
  static const String appName = 'LEAD KART';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'LEAD College of Management';
  
  // Environment Configuration
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const bool debugMode = bool.fromEnvironment('DEBUG_MODE', defaultValue: true);
  
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here',
  );
  
  // API Configuration
  static const String baseUrl = '$supabaseUrl/rest/v1';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  
  // Storage Configuration
  static const String productsBucket = 'products';
  static const String avatarsBucket = 'avatars';
  static const String reviewsBucket = 'reviews';
  
  // App Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImagesPerProduct = 5;
  static const double minOrderAmount = 50.0;
  static const double maxCodAmount = 5000.0;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // Animation Configuration
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePerformanceMonitoring = true;
  
  // Contact Information
  static const String supportEmail = 'support@leadkart.com';
  static const String supportPhone = '+91 9876543210';
  static const String websiteUrl = 'https://leadkart.com';
  static const String privacyPolicyUrl = 'https://leadkart.com/privacy';
  static const String termsOfServiceUrl = 'https://leadkart.com/terms';
}