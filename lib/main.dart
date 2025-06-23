import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/product_bloc.dart';
import 'blocs/order_bloc.dart';
import 'screens/initial_screen.dart';
import 'screens/customer_home_screen.dart';
import 'screens/seller_home_screen.dart';
import 'screens/customer_signup_screen.dart';
import 'screens/customer_login_screen.dart';
import 'screens/seller_signup_screen.dart';
import 'screens/seller_login_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/product_add_screen.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';
import 'utils/supabase_client.dart' as app_supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await app_supabase.SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AuthCheckRequested()),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(),
        ),
        BlocProvider<OrderBloc>(
          create: (context) => OrderBloc(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.primaryColor,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(
              color: AppConstants.textPrimaryColor,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppConstants.primaryColor,
            selectedItemColor: AppConstants.accentColor,
            unselectedItemColor: AppConstants.textSecondaryColor,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppConstants.surfaceColor,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: const BorderSide(
                color: AppConstants.secondaryColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: const BorderSide(
                color: AppConstants.secondaryColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: const BorderSide(
                color: AppConstants.accentColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: const BorderSide(
                color: AppConstants.errorColor,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingMedium,
            ),
            hintStyle: const TextStyle(
              color: AppConstants.textSecondaryColor,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.accentColor,
              foregroundColor: AppConstants.textPrimaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: AppConstants.surfaceColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusLarge),
            ),
          ),
          dialogTheme: DialogTheme(
            backgroundColor: AppConstants.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusLarge),
            ),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppConstants.surfaceColor,
            contentTextStyle: const TextStyle(
              color: AppConstants.textPrimaryColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/customer_signup': (context) => CustomerSignupScreen(),
          '/customer_login': (context) => CustomerLoginScreen(),
          '/seller_signup': (context) => SellerSignupScreen(),
          '/seller_login': (context) => SellerLoginScreen(),
          '/customer_home': (context) => CustomerHomeScreen(),
          '/seller_home': (context) => SellerHomeScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/profile': (context) => ProfileScreen(),
          '/product_add': (context) => ProductAddScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is CustomerAuthenticated) {
          return const CustomerHomeScreen();
        } else if (state is SellerAuthenticated) {
          return const SellerHomeScreen();
        } else if (state is AuthLoading) {
          return const SplashScreen();
        } else {
          return const InitialScreen();
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppConstants.accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.shopping_cart,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Lead Kart',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'College E-Commerce Platform',
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppConstants.accentColor),
            ),
          ],
        ),
      ),
    );
  }
}
