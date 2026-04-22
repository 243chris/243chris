class AppConfig {
  static const String appName = 'AfriConnect';
  static const String appVersion = '1.0.0';
  
  static const int maxPostLength = 500;
  static const int maxBioLength = 160;
  static const int feedPageSize = 20;
  static const int maxImagesPerPost = 4;
  
  static const Duration cachedFeedExpiry = Duration(minutes: 5);
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  static const List<String> supportedLanguages = ['fr', 'en', 'wo', 'ha'];
  static const String defaultLanguage = 'fr';
  
  static const List<String> postCategories = [
    'business',
    'education', 
    'entertainment',
    'technology',
    'community'
  ];
}