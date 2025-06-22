import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_model.dart';
import 'storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storage = StorageService();
  
  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _supabase.auth.onAuthStateChange
      .map((data) => data.session?.user);
  
  // Current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
  
  // Check if onboarding is completed
  bool get isOnboardingCompleted => _storage.getBool('onboarding_completed') ?? false;
  
  // Set onboarding completed
  Future<void> setOnboardingCompleted() async {
    await _storage.setBool('onboarding_completed', true);
  }
  
  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? studentId,
    String? phone,
    String? hostelRoom,
    String userType = 'customer',
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'student_id': studentId,
          'phone': phone,
          'hostel_room': hostelRoom,
          'user_type': userType,
        },
      );
      
      if (response.user != null) {
        // Create user profile in database
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          studentId: studentId,
          phone: phone,
          hostelRoom: hostelRoom,
          userType: userType,
        );
      }
      
      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (rememberMe && response.user != null) {
        await _storage.setString('remembered_email', email);
      }
      
      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _storage.remove('remembered_email');
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // Get current user profile
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = currentUser;
      if (user == null) return null;
      
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _supabase
          .from('profiles')
          .update(user.toJson())
          .eq('id', user.id);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');
      
      // Delete user profile
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', user.id);
      
      // Sign out
      await signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // Get remembered email
  String? getRememberedEmail() {
    return _storage.getString('remembered_email');
  }
  
  // Verify email
  Future<void> resendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');
      
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: user.email,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // Check if email is verified
  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;
  
  // Private methods
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? studentId,
    String? phone,
    String? hostelRoom,
    required String userType,
  }) async {
    await _supabase.from('profiles').insert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'student_id': studentId,
      'phone': phone,
      'hostel_room': hostelRoom,
      'user_type': userType,
    });
  }
  
  Exception _handleAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.statusCode) {
        case '400':
          return Exception('Invalid email or password');
        case '422':
          return Exception('Email already registered');
        case '429':
          return Exception('Too many requests. Please try again later');
        default:
          return Exception(error.message);
      }
    } else if (error is PostgrestException) {
      return Exception('Database error: ${error.message}');
    } else {
      return Exception('An unexpected error occurred');
    }
  }
}