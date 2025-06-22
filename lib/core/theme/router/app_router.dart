import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/auth_wrapper.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/products/product_details_screen.dart';
import '../../presentation/screens/products/products_list_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/checkout/checkout_screen.dart';
import '../../presentation/screens/checkout/order_confirmation_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/orders/order_details_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/address_management_screen.dart';
import '../../presentation/screens/seller/seller_dashboard.dart';
import '../../presentation/screens/seller/add_product_screen.dart';
import '../../presentation/screens/wishlist/wishlist_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/widgets/layout/main_layout.dart';
import '../services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authService.isAuthenticated;
      final isOnboardingCompleted = authService.isOnboardingCompleted;
      
      // Handle authentication redirects
      if (!isAuthenticated) {
        if (state.location.startsWith('/auth') || 
            state.location == '/' || 
            state.location == '/onboarding') {
          return null; // Allow access to auth screens and splash
        }
        return '/auth/login';
      }
      
      // Handle onboarding redirects
      if (isAuthenticated && !isOnboardingCompleted) {
        if (state.location == '/onboarding') {
          return null; // Allow access to onboarding
        }
        return '/onboarding';
      }
      
      // Redirect authenticated users from auth screens to home
      if (isAuthenticated && state.location.startsWith('/auth')) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthWrapper(),
        routes: [
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            name: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/forgot-password',
            name: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
        ],
      ),
      
      // Main App Routes (with bottom navigation)
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainLayout(shell: shell),
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: '/search',
                    name: 'search',
                    builder: (context, state) {
                      final query = state.uri.queryParameters['q'] ?? '';
                      return ProductsListScreen(searchQuery: query);
                    },
                  ),
                  GoRoute(
                    path: '/category/:categoryId',
                    name: 'category',
                    builder: (context, state) {
                      final categoryId = state.pathParameters['categoryId']!;
                      return ProductsListScreen(categoryId: categoryId);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Products Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                name: 'products',
                builder: (context, state) => const ProductsListScreen(),
                routes: [
                  GoRoute(
                    path: '/:productId',
                    name: 'product-details',
                    builder: (context, state) {
                      final productId = state.pathParameters['productId']!;
                      return ProductDetailsScreen(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Cart Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                name: 'cart',
                builder: (context, state) => const CartScreen(),
                routes: [
                  GoRoute(
                    path: '/checkout',
                    name: 'checkout',
                    builder: (context, state) => const CheckoutScreen(),
                    routes: [
                      GoRoute(
                        path: '/confirmation',
                        name: 'order-confirmation',
                        builder: (context, state) {
                          final orderId = state.uri.queryParameters['orderId'];
                          return OrderConfirmationScreen(orderId: orderId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: '/edit',
                    name: 'edit-profile',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: '/addresses',
                    name: 'addresses',
                    builder: (context, state) => const AddressManagementScreen(),
                  ),
                  GoRoute(
                    path: '/orders',
                    name: 'orders',
                    builder: (context, state) => const OrdersScreen(),
                    routes: [
                      GoRoute(
                        path: '/:orderId',
                        name: 'order-details',
                        builder: (context, state) {
                          final orderId = state.pathParameters['orderId']!;
                          return OrderDetailsScreen(orderId: orderId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: '/wishlist',
                    name: 'wishlist',
                    builder: (context, state) => const WishlistScreen(),
                  ),
                  GoRoute(
                    path: '/notifications',
                    name: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      
      // Seller Routes
      GoRoute(
        path: '/seller',
        name: 'seller',
        builder: (context, state) => const SellerDashboard(),
        routes: [
          GoRoute(
            path: '/add-product',
            name: 'add-product',
            builder: (context, state) => const AddProductScreen(),
          ),
          GoRoute(
            path: '/edit-product/:productId',
            name: 'edit-product',
            builder: (context, state) {
              final productId = state.pathParameters['productId']!;
              return AddProductScreen(productId: productId);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});