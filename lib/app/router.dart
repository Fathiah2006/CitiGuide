import 'package:flutter/material.dart';

import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/city/city_select_screen.dart';
import '../screens/details/listing_details_screen.dart';
import '../screens/details/map_screen.dart';
import '../screens/main_shell.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/reviews/add_review_screen.dart';
import '../screens/reviews/reviews_screen.dart';
import 'routes.dart';

/// Central route table. Routes carrying a listing id read it from
/// `settings.arguments`.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case Routes.splash:
        page = const SplashScreen();
        break;
      case Routes.login:
        page = const LoginScreen();
        break;
      case Routes.signup:
        page = const SignupScreen();
        break;
      case Routes.forgot:
        page = const ForgotPasswordScreen();
        break;
      case Routes.city:
        page = const CitySelectScreen();
        break;
      case Routes.main:
        page = const MainShell();
        break;
      case Routes.details:
        page = ListingDetailsScreen(listingId: settings.arguments as String);
        break;
      case Routes.map:
        page = MapScreen(listingId: settings.arguments as String);
        break;
      case Routes.reviews:
        page = ReviewsScreen(listingId: settings.arguments as String);
        break;
      case Routes.addReview:
        page = AddReviewScreen(listingId: settings.arguments as String);
        break;
      case Routes.editProfile:
        page = const EditProfileScreen();
        break;
      default:
        page = const SplashScreen();
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
