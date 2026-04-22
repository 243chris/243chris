class Constants {
  static const String appName = 'AfriConnect';
  static const String supabaseUrl = 'https://votre-projet.supabase.co';
  
  static const int maxPostLength = 500;
  static const int maxBioLength = 160;
  static const int feedPageSize = 20;
  static const int maxImagesPerPost = 4;
  
  static const String defaultLanguage = 'fr';
  static const List<String> supportedLanguages = ['fr', 'en', 'wo', 'ha'];
  
  static const List<String> mediaCategories = [
    'business',
    'education',
    'entertainment',
    'technology',
    'community',
  ];
}