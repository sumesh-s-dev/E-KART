import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import '../models/seller.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CustomerLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const CustomerLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SellerLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const SellerLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class CustomerSignupRequested extends AuthEvent {
  final String username;
  final String userType; // 'Student' or 'Staff'
  final String email;
  final String phone;
  final String password;

  const CustomerSignupRequested({
    required this.username,
    required this.userType,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [username, userType, email, phone, password];
}

class SellerSignupRequested extends AuthEvent {
  final String username;
  final String brandName;
  final String email;
  final String phone;
  final String password;

  const SellerSignupRequested({
    required this.username,
    required this.brandName,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [username, brandName, email, phone, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class DeleteAccountRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class CustomerAuthenticated extends AuthState {
  final app_user.User user;

  const CustomerAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class SellerAuthenticated extends AuthState {
  final Seller seller;

  const SellerAuthenticated(this.seller);

  @override
  List<Object?> get props => [seller];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabaseClient;

  AuthBloc({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client,
        super(AuthInitial()) {
    on<CustomerLoginRequested>(_onCustomerLoginRequested);
    on<SellerLoginRequested>(_onSellerLoginRequested);
    on<CustomerSignupRequested>(_onCustomerSignupRequested);
    on<SellerSignupRequested>(_onSellerSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
  }

  Future<void> _onCustomerLoginRequested(
    CustomerLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      print('🔐 Attempting customer login for: ${event.email}');

      final response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        print('✅ Login successful, fetching customer profile...');

        try {
          final userData = await _supabaseClient
              .from('users')
              .select()
              .eq('user_id', response.user!.id)
              .single();

          print('📋 Customer profile data: $userData');
          final user = app_user.User.fromJson(userData);
          emit(CustomerAuthenticated(user));
          print('🎉 Customer login completed successfully!');
        } catch (dbError) {
          print('❌ Error fetching customer profile: $dbError');
          emit(const AuthError(
              'Customer profile not found. Please sign up first.'));
        }
      } else {
        print('❌ Login failed - no user returned');
        emit(const AuthError('Login failed. Please check your credentials.'));
      }
    } catch (e) {
      print('❌ Customer login error: $e');
      String errorMessage = 'Login failed';

      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Please confirm your email address';
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'User not found. Please sign up first.';
      } else if (e.toString().contains('Too many requests')) {
        errorMessage = 'Too many login attempts. Please try again later.';
      }

      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSellerLoginRequested(
    SellerLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      print('🔐 Attempting seller login for: ${event.email}');

      final response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        print('✅ Login successful, fetching seller profile...');

        try {
          final sellerData = await _supabaseClient
              .from('sellers')
              .select()
              .eq('seller_id', response.user!.id)
              .single();

          print('📋 Seller profile data: $sellerData');
          final seller = Seller.fromJson(sellerData);
          emit(SellerAuthenticated(seller));
          print('🎉 Seller login completed successfully!');
        } catch (dbError) {
          print('❌ Error fetching seller profile: $dbError');
          emit(const AuthError(
              'Seller profile not found. Please sign up first.'));
        }
      } else {
        print('❌ Login failed - no user returned');
        emit(const AuthError('Login failed. Please check your credentials.'));
      }
    } catch (e) {
      print('❌ Seller login error: $e');
      String errorMessage = 'Login failed';

      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Please confirm your email address';
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'User not found. Please sign up first.';
      } else if (e.toString().contains('Too many requests')) {
        errorMessage = 'Too many login attempts. Please try again later.';
      }

      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onCustomerSignupRequested(
    CustomerSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      print('🚀 Starting customer signup process...');
      print('👤 Username: ${event.username}');
      print('🎓 User Type: ${event.userType}');
      print('📧 Email: ${event.email}');
      print('📱 Phone: ${event.phone}');

      // First, create the auth user
      final response = await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        print('✅ Auth user created successfully');

        // Create customer profile in database
        try {
          print('📝 Creating customer profile in database...');

          final userData = {
            'user_id': response.user!.id,
            'username': event.username,
            'user_type': event.userType,
            'email': event.email,
            'phone': event.phone,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };

          print('📋 Inserting customer data: $userData');

          await _supabaseClient.from('users').insert(userData);
          print('✅ Customer profile created successfully');

          // Create user object
          final user = app_user.User.fromJson(userData);
          emit(CustomerAuthenticated(user));
          print('🎉 Customer signup completed successfully!');
        } catch (dbError) {
          print('❌ Error creating customer profile: $dbError');
          emit(AuthError(
              'Failed to create customer profile. Please try again.'));
        }
      } else {
        print('❌ Signup failed - no user returned');
        emit(const AuthError('Signup failed. Please try again.'));
      }
    } catch (e) {
      print('❌ Customer signup error: $e');
      String errorMessage = 'Signup failed';

      if (e.toString().contains('over_email_send_rate_limit')) {
        errorMessage =
            'You are trying too frequently. Please wait a minute before trying again.';
      } else if (e.toString().contains('User already registered')) {
        errorMessage = 'User already exists with this email';
      } else if (e.toString().contains('Password should be at least')) {
        errorMessage = 'Password should be at least 6 characters long';
      } else if (e.toString().contains('Invalid email')) {
        errorMessage = 'Please enter a valid email address';
      }

      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSellerSignupRequested(
    SellerSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      print('🚀 Starting seller signup process...');
      print('👤 Username: ${event.username}');
      print('🏢 Brand Name: ${event.brandName}');
      print('📧 Email: ${event.email}');
      print('📱 Phone: ${event.phone}');

      // First, create the auth user
      final response = await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        print('✅ Auth user created successfully');

        // Create seller profile in database
        try {
          print('📝 Creating seller profile in database...');

          final sellerData = {
            'seller_id': response.user!.id,
            'username': event.username,
            'brand_name': event.brandName,
            'email': event.email,
            'phone': event.phone,
            'status': 'offline',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };

          print('📋 Inserting seller data: $sellerData');

          await _supabaseClient.from('sellers').insert(sellerData);
          print('✅ Seller profile created successfully');

          // Create seller object
          final seller = Seller.fromJson(sellerData);
          emit(SellerAuthenticated(seller));
          print('🎉 Seller signup completed successfully!');
        } catch (dbError) {
          print('❌ Error creating seller profile: $dbError');
          emit(AuthError('Failed to create seller profile. Please try again.'));
        }
      } else {
        print('❌ Signup failed - no user returned');
        emit(const AuthError('Signup failed. Please try again.'));
      }
    } catch (e) {
      print('❌ Seller signup error: $e');
      String errorMessage = 'Signup failed';

      if (e.toString().contains('over_email_send_rate_limit')) {
        errorMessage =
            'You are trying too frequently. Please wait a minute before trying again.';
      } else if (e.toString().contains('User already registered')) {
        errorMessage = 'User already exists with this email';
      } else if (e.toString().contains('Password should be at least')) {
        errorMessage = 'Password should be at least 6 characters long';
      } else if (e.toString().contains('Invalid email')) {
        errorMessage = 'Please enter a valid email address';
      }

      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await _supabaseClient.auth.signOut();
      emit(AuthUnauthenticated());
      print('👋 Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
      emit(AuthError('Logout failed. Please try again.'));
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = _supabaseClient.auth.currentUser;

      if (user != null) {
        print('🔍 Checking authentication for user: ${user.email}');

        // Try to find user in customers table first
        try {
          final userData = await _supabaseClient
              .from('users')
              .select()
              .eq('user_id', user.id)
              .single();

          final customer = app_user.User.fromJson(userData);
          emit(CustomerAuthenticated(customer));
          print('✅ Customer authenticated');
          return;
        } catch (e) {
          print('User not found in customers table, checking sellers...');
        }

        // Try to find user in sellers table
        try {
          final sellerData = await _supabaseClient
              .from('sellers')
              .select()
              .eq('seller_id', user.id)
              .single();

          final seller = Seller.fromJson(sellerData);
          emit(SellerAuthenticated(seller));
          print('✅ Seller authenticated');
          return;
        } catch (e) {
          print('User not found in sellers table either');
        }

        // If user exists in auth but not in either table, logout
        await _supabaseClient.auth.signOut();
        emit(AuthUnauthenticated());
        print('⚠️ User not found in database, logged out');
      } else {
        emit(AuthUnauthenticated());
        print('❌ No authenticated user found');
      }
    } catch (e) {
      print('❌ Auth check error: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onDeleteAccountRequested(
      DeleteAccountRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final user = _supabaseClient.auth.currentUser;
      if (user != null) {
        // Try to delete from users table
        await _supabaseClient.from('users').delete().eq('user_id', user.id);
        // Try to delete from sellers table
        await _supabaseClient.from('sellers').delete().eq('seller_id', user.id);
        // Delete from auth
        await _supabaseClient.auth.admin.deleteUser(user.id);
      }
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to delete account: \\${e.toString()}'));
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      emit(AuthLoading());
      final res = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);
      if (res.user != null) {
        // Fetch user profile from users table
        final userData = await _supabaseClient
            .from('users')
            .select()
            .eq('user_id', res.user!.id)
            .single();
        final user = app_user.User.fromJson(userData);
        emit(CustomerAuthenticated(user));
      } else {
        emit(AuthError('Login failed.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> loginSeller(String email, String password) async {
    try {
      emit(AuthLoading());
      final res = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);
      if (res.user != null) {
        // Fetch seller profile from sellers table
        final sellerData = await _supabaseClient
            .from('sellers')
            .select()
            .eq('seller_id', res.user!.id)
            .single();
        final seller = Seller.fromJson(sellerData);
        emit(SellerAuthenticated(seller));
      } else {
        emit(AuthError('Login failed.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUpUser(String email, String password, String username,
      String userType, String phone) async {
    try {
      emit(AuthLoading());
      final AuthResponse res = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      if (res.user != null) {
        await _supabaseClient.from('users').insert({
          'user_id': res.user!.id,
          'username': username,
          'user_type': userType,
          'email': email,
          'phone': phone,
        });
        // Fetch user profile after signup
        final userData = await _supabaseClient
            .from('users')
            .select()
            .eq('user_id', res.user!.id)
            .single();
        final user = app_user.User.fromJson(userData);
        emit(CustomerAuthenticated(user));
      } else {
        emit(AuthError('Sign up failed.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUpSeller(String email, String password, String username,
      String brandName, String phone) async {
    try {
      emit(AuthLoading());
      final AuthResponse res = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      if (res.user != null) {
        await _supabaseClient.from('sellers').insert({
          'seller_id': res.user!.id,
          'username': username,
          'brand_name': brandName,
          'email': email,
          'phone': phone,
          'status': 'offline',
        });
        // Fetch seller profile after signup
        final sellerData = await _supabaseClient
            .from('sellers')
            .select()
            .eq('seller_id', res.user!.id)
            .single();
        final seller = Seller.fromJson(sellerData);
        emit(SellerAuthenticated(seller));
      } else {
        emit(AuthError('Sign up failed.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _supabaseClient.auth.signOut();
      emit(AuthUnauthenticated());
      print('👋 Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }
}
