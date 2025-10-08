import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/phone_login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/customer/screens/customer_home_screen.dart';
import '../../features/restaurant/screens/restaurant_home_screen.dart';
import '../../features/restaurant/screens/create_coupon_screen.dart';
import '../../features/restaurant/screens/manage_coupons_screen.dart';
import '../../features/restaurant/screens/analytics_screen.dart';
import '../../features/restaurant/screens/qr_code_screen.dart';
import '../../features/admin/screens/admin_home_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../models/user_role.dart';
import '../models/coupon.dart';
import '../providers/auth_provider.dart';
import 'route_transitions.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.value?.session != null;
      final isGoingToAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation.startsWith('/phone-login');
      
      final isGoingToSplash = state.matchedLocation == '/splash';

      // If not authenticated and not going to auth or splash, redirect to login
      if (!isAuthenticated && !isGoingToAuth && !isGoingToSplash) {
        return '/login';
      }

      // If authenticated and going to auth pages, redirect to home
      if (isAuthenticated && isGoingToAuth) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => RouteTransitions.fade(
          child: const SplashScreen(),
          state: state,
        ),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          child: const LoginScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          child: const SignupScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => RouteTransitions.slideUp(
          child: const ForgotPasswordScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/phone-login',
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          child: const PhoneLoginScreen(),
          state: state,
        ),
      ),

      // Home Route (Role-based)
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => RouteTransitions.fade(
          child: const RoleBasedHome(),
          state: state,
        ),
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          child: const ProfileScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          child: const EditProfileScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/profile/change-password',
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          child: const ChangePasswordScreen(),
          state: state,
        ),
      ),

      // Restaurant Routes
      GoRoute(
        path: '/restaurant/create-coupon',
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          child: CreateCouponScreen(coupon: state.extra as Coupon?),
          state: state,
        ),
      ),
      GoRoute(
        path: '/restaurant/manage-coupons',
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          child: const ManageCouponsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/restaurant/analytics',
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          child: const RestaurantAnalyticsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/restaurant/qr-scanner',
        pageBuilder: (context, state) => RouteTransitions.slideUp(
          child: const QRCodeScannerScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/restaurant/qr-code/:couponId',
        pageBuilder: (context, state) => RouteTransitions.slideRight(
          child: QRCodeGeneratorScreen(coupon: state.extra as Coupon),
          state: state,
        ),
      ),
    ],
  );
});

// Role-based home screen selector
class RoleBasedHome extends ConsumerWidget {
  const RoleBasedHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        switch (user.role) {
          case UserRole.customer:
            return const CustomerHomeScreen();
          case UserRole.restaurant:
            return const RestaurantHomeScreen();
          case UserRole.admin:
            return const AdminHomeScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
