import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';

// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(const AuthState()) {
    _init();
  }

  final Ref ref;
  late final AuthService _authService;

  void _init() {
    _authService = ref.read(authServiceProvider);
    _checkAuthState();
    _listenToAuthChanges();
  }

  void _checkAuthState() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        final userModel = await _authService.getCurrentUser();
        state = state.copyWith(
          isAuthenticated: true,
          user: userModel,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          user: null,
        );
      }
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.signIn(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      // State will be updated by the auth state listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? studentId,
    String? phone,
    String? hostelRoom,
    String userType = 'customer',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        studentId: studentId,
        phone: phone,
        hostelRoom: hostelRoom,
        userType: userType,
      );
      // State will be updated by the auth state listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authService.signOut();
      // State will be updated by the auth state listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateProfile(UserModel user) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.updateUserProfile(user);
      state = state.copyWith(
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}