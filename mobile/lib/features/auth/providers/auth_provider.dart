import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'mock_auth_provider.dart';
import '../../../core/config/app_config.dart';

/// Auth State Provider - Conditional based on AppConfig
final authStateProvider = StreamProvider<AuthState>((ref) {
  if (AppConfig.useMockAuth) {
    return ref.watch(mockAuthStateProvider.future).asStream();
  }
  return AuthService.authStateChanges;
});

/// Current User Provider - Conditional based on AppConfig
final currentUserProvider = Provider<User?>((ref) {
  if (AppConfig.useMockAuth) {
    return mockUser;
  }
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? AuthService.currentUser;
});

/// User Profile Provider - Conditional based on AppConfig
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  if (AppConfig.useMockAuth) {
    return ref.watch(mockUserProfileProvider.future);
  }
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return await AuthService.getProfile(user.id);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await AuthService.login(email, password);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AuthService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await AuthService.signInWithGoogle();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signInWithFacebook() async {
    state = const AsyncValue.loading();
    try {
      await AuthService.signInWithFacebook();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await AuthService.logout();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Mock Auth Notifier for Development Mode
/// Extends AuthNotifier to simulate auth operations without backend
class MockAuthNotifier extends AuthNotifier {
  @override
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 800));
    state = const AsyncValue.data(null);
    // ignore: avoid_print
    print('[MOCK AUTH] ✅ Login successful: $email');
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 1000));
    state = const AsyncValue.data(null);
    // ignore: avoid_print
    print('[MOCK AUTH] ✅ Register successful: $email ($fullName)');
  }

  @override
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 600));
    state = const AsyncValue.data(null);
    // ignore: avoid_print
    print('[MOCK AUTH] ✅ Google Sign-In successful');
  }

  @override
  Future<void> signInWithFacebook() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 600));
    state = const AsyncValue.data(null);
    // ignore: avoid_print
    print('[MOCK AUTH] ✅ Facebook Sign-In successful');
  }

  @override
  Future<void> logout() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 300));
    state = const AsyncValue.data(null);
    // ignore: avoid_print
    print('[MOCK AUTH] ✅ Logout successful');
  }
}

/// Auth Controller Provider - Conditional based on AppConfig
final authControllerProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  if (AppConfig.useMockAuth) {
    return MockAuthNotifier();
  }
  return AuthNotifier();
});
