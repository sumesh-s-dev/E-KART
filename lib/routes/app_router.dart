import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/main/main_navigation_screen.dart';
import '../screens/product/my_products_screen.dart';
import '../screens/order/orders_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case '/main':
        return MaterialPageRoute(builder: (_) => MainNavigationScreen());
      case '/products':
        return MaterialPageRoute(builder: (_) => MyProductsScreen());
      case '/orders':
        return MaterialPageRoute(builder: (_) => OrdersScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
