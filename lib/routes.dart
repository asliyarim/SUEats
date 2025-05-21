import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/restaurant_listing_screen.dart';
import 'screens/restaurant_menu_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/delivery_address_screen.dart';
import 'screens/payment_screen.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String categories = '/categories';
  static const String restaurantListing = '/restaurant-listing';
  static const String restaurantMenu = '/restaurant-menu';
  static const String cart = '/cart';
  static const String deliveryAddress = '/delivery-address';
  static const String payment = '/payment';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      case restaurantListing:
        return MaterialPageRoute(builder: (_) => const RestaurantListingScreen());
      case restaurantMenu:
        final args = settings.arguments as Map<String, dynamic>?;
        final restaurantId = args?['restaurantId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => RestaurantMenuScreen(restaurantId: restaurantId),
        );
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case deliveryAddress:
        return MaterialPageRoute(builder: (_) => const DeliveryAddressScreen());
      case payment:
        return MaterialPageRoute(builder: (_) => const PaymentScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}