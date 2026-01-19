import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:io' show Platform;

class AuthService {
  static final _supabase = Supabase.instance.client;

  /// Get current user
  static User? get currentUser => _supabase.auth.currentUser;

  /// Stream of auth changes
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Login with Email and Password
  static Future<AuthResponse> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Kiểm tra trạng thái tài khoản ngay sau khi đăng nhập
    if (response.user != null) {
      final profile = await getProfile(response.user!.id);
      if (profile != null && profile['account_status'] != 'active') {
        await logout();
        throw Exception('Account is ${profile['account_status']}. Please contact support.');
      }
    }

    return response;
  }

  /// Register new user
  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
      },
    );
  }

  /// Sign in with Google
  static Future<dynamic> signInWithGoogle() async {
    if (kIsWeb) {
      // Flow cho Web: Redirect về API callback của website
      return await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: '${dotenv.env['WEB_API_URL']}/auth/callback',
      );
    }

    /// Flow cho Android/iOS: Ưu tiên dùng Native SDK
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
    final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: Platform.isIOS ? iosClientId : webClientId,
      serverClientId: webClientId,
    );
    
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken != null) {
        return await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      }
    } catch (e) {
      // Nếu Native SDK lỗi, fallback sang luồng trình duyệt với Deep Link
      debugPrint('Google Native Error: $e. Falling back to OAuth.');
    }

    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.perfumegpt://login-callback',
    );
  }

  /// Sign in with Facebook
  /// Sign in with Facebook
  static Future<void> signInWithFacebook() async {
    try {
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.facebook,
          redirectTo: '${dotenv.env['WEB_API_URL']}/auth/callback',
        );
      } else {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.facebook,
          redirectTo: 'io.supabase.perfumegpt://login-callback',
          authScreenLaunchMode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Facebook Sign In Error: $e');
      rethrow;
    }
  }




  /// Reset password
  static Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Logout
  static Future<void> logout() async {
    try {
      await Future.wait([
        _supabase.auth.signOut(),
        GoogleSignIn().signOut(),
        FacebookAuth.instance.logOut(),
      ]);
    } catch (e) {
      // Ignore errors if already signed out
      await _supabase.auth.signOut();
    }
  }


  /// Get profile data
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select('*, user_roles(roles(code)), loyalty_accounts(current_points)')
        .eq('id', userId)
        .maybeSingle();

    if (data != null) {
      final roles = (data['user_roles'] as List?)
          ?.map((ur) => ((ur as Map)['roles'] as Map)['code'])
          .toList();
      final points = (data['loyalty_accounts'] as Map?)?['current_points'] ?? 0;
      return {...data, 'roles': roles, 'loyalty_points': points};
    }
    return data;
  }

}
