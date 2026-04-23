import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/config/env.dart';
import '../data/auth_repository.dart';

class AuthUser {
  final String id;
  final String? email;
  final String createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? json['_id'] ?? '') as String,
      email: json['email'] as String?,
      createdAt:
          (json['created_at'] ??
                  json['createdAt'] ??
                  DateTime.now().toIso8601String())
              as String,
    );
  }
}

final _authUserStateProvider = StateProvider<AuthUser?>((ref) => null);
final _authProfileStateProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

class AuthStatusNotifier extends StateNotifier<bool> {
  final Ref _ref;
  final AuthRepository _repository;

  AuthStatusNotifier({required Ref ref, required AuthRepository repository})
    : _ref = ref,
      _repository = repository,
      super(false) {
    _bootstrapAuthState();
  }

  Future<void> _bootstrapAuthState() async {
    final hasToken = await _repository.isAuthenticated;
    if (!hasToken) {
      state = false;
      return;
    }

    try {
      final profile = await _repository.getProfile();
      _ref.read(_authProfileStateProvider.notifier).state = profile;
      _ref.read(_authUserStateProvider.notifier).state = AuthUser.fromJson(
        profile,
      );
      state = true;
    } catch (_) {
      await _repository.logout();
      clearAuthMemory();
      state = false;
    }
  }

  void markAuthenticated({Map<String, dynamic>? profile}) {
    if (profile != null) {
      _ref.read(_authProfileStateProvider.notifier).state = profile;
      _ref.read(_authUserStateProvider.notifier).state = AuthUser.fromJson(
        profile,
      );
    }
    state = true;
  }

  void clearAuthMemory() {
    _ref.read(_authUserStateProvider.notifier).state = null;
    _ref.read(_authProfileStateProvider.notifier).state = null;
  }

  void markLoggedOut() {
    clearAuthMemory();
    state = false;
  }
}

/// Authentication status used by router guard.
///
/// `true`  => user has valid login session
/// `false` => user is logged out
final authStateProvider = StateNotifierProvider<AuthStatusNotifier, bool>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthStatusNotifier(ref: ref, repository: repository);
});

/// Current authenticated user information.
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(_authUserStateProvider);
});

/// Synchronous access to cached profile data (used by router guard for role check).
final userProfileRawProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(_authProfileStateProvider);
});

/// Full profile payload returned by `/auth/profile`.
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final isAuthenticated = ref.watch(authStateProvider);
  if (!isAuthenticated) return null;

  final repository = ref.watch(authRepositoryProvider);
  try {
    final profile = await repository.getProfile();
    
    // Update synchronous cache
    ref.read(_authProfileStateProvider.notifier).state = profile;

    final currentUser = ref.read(_authUserStateProvider);
    if (currentUser == null) {
      ref.read(_authUserStateProvider.notifier).state = AuthUser.fromJson(
        profile,
      );
    }

    return profile;
  } catch (e) {
    // If API fails, fall back to cached profile if available
    final cached = ref.read(_authProfileStateProvider);
    if (cached != null) return cached;
    rethrow;
  }
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final AuthRepository _repository;

  AuthNotifier({required Ref ref, required AuthRepository repository})
    : _ref = ref,
      _repository = repository,
      super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.login(email: email, password: password);

      Map<String, dynamic>? profile;
      try {
        profile = await _repository.getProfile();
      } catch (_) {
        // Keep authenticated if login succeeded and token was stored.
      }

      _ref.read(authStateProvider.notifier).markAuthenticated(profile: profile);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
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
      await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      final hasToken = await _repository.isAuthenticated;
      if (hasToken) {
        Map<String, dynamic>? profile;
        try {
          profile = await _repository.getProfile();
        } catch (_) {
          // Registration can be successful even if profile endpoint is not ready.
        }
        _ref
            .read(authStateProvider.notifier)
            .markAuthenticated(profile: profile);
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: EnvConfig.googleWebClientId,
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        state = const AsyncValue.data(null);
        return; // User cancelled
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw Exception('Không lấy được token từ Google');
      }

      final profile = await _repository.socialLogin(
        provider: 'google',
        token: idToken,
        email: account.email,
        providerId: account.id,
        fullName: account.displayName,
        avatarUrl: account.photoUrl,
      );

      Map<String, dynamic>? userProfile;
      try {
        userProfile = await _repository.getProfile();
      } catch (_) {}

      _ref
          .read(authStateProvider.notifier)
          .markAuthenticated(profile: userProfile ?? profile);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }


  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return _repository.forgotPassword(email: email);
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return _repository.resetPassword(token: token, newPassword: newPassword);
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    return _repository.verifyEmail(token: token);
  }

  Future<Map<String, dynamic>> resendVerification() async {
    final result = await _repository.resendVerification();
    // Refresh profile in case it was already verified or just updated
    _ref.invalidate(userProfileProvider);
    return result;
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      _ref.read(authStateProvider.notifier).markLoggedOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Auth controller used by existing login/register screens.
final authControllerProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthNotifier(ref: ref, repository: repository);
    });
