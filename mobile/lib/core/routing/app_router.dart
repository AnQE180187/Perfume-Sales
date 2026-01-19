
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/payment/presentation/payment_method_screen.dart';
import '../../features/payment/presentation/payment_result_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/wishlist/presentation/wishlist_screen.dart';
import '../widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final hasSeenOnboarding = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value?.session != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      // 1. Force Onboarding if not seen
      if (!hasSeenOnboarding) {
        if (!isOnboardingRoute) return '/onboarding';
        return null;
      }

      // 2. If already saw onboarding but at onboarding route, move to login/home
      if (isOnboardingRoute) {
        return isLoggedIn ? '/home' : '/login';
      }

      // 3. Force Login if not logged in and not on auth route
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // 4. Force Home if logged in but on auth route
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainShell(),
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
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PaymentMethodScreen(
            orderId: extra['orderId'] as String,
            amount: extra['amount'] as double,
            orderInfo: extra['orderInfo'] as String,
            shippingAddress: extra['shippingAddress'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/payment/result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PaymentResultScreen(
            success: extra['success'] as bool,
            message: extra['message'] as String,
            orderId: extra['orderId'] as String,
          );
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
    ],
  );
});
