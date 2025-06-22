import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import your screen files
import '../../../screens/splash_screen.dart';
import '../../../screens/onboarding_screen.dart';
import '../../../screens/login_screen.dart';
import '../../../screens/register_screen.dart';
import '../../../screens/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}