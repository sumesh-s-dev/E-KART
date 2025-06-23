import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // ✅ Supabase credentials configured
  static const String url = 'https://otcyffwfdruqrpazbrhs.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90Y3lmZndmZHJ1cXJwYXpicmhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2MTg3OTEsImV4cCI6MjA2NjE5NDc5MX0.4qGfDG4F_xF_IpkOBOLNv1CT8DCdIYPXbW0J9KCgH-I';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      print('✅ Supabase initialized successfully');
      print('📡 Project URL: $url');

      // Test database connection
      await testDatabaseConnection();
    } catch (e) {
      print('❌ Error initializing Supabase: $e');
      rethrow;
    }
  }

  static Future<void> testDatabaseConnection() async {
    try {
      print('🔍 Testing database connection...');

      // Test if users table exists
      final result = await client.from('users').select('count').limit(1);
      print('✅ Users table exists and is accessible');

      // Test if products table exists
      final productsResult =
          await client.from('products').select('count').limit(1);
      print('✅ Products table exists and is accessible');

      // Test if orders table exists
      final ordersResult = await client.from('orders').select('count').limit(1);
      print('✅ Orders table exists and is accessible');

      print('🎉 All database tables are ready!');
    } catch (e) {
      print('❌ Database test failed: $e');
      print(
          '💡 Please run the SQL script in Supabase dashboard to create tables');
    }
  }

  static User? get currentUser => client.auth.currentUser;

  static bool get isAuthenticated => currentUser != null;

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }

  // Helper method to get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response =
          await client.from('users').select().eq('id', userId).single();
      return response;
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      return null;
    }
  }
}
