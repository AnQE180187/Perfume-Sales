import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock User Data for Development
/// ID này match với format UUID của Supabase
final mockUser = User(
  id: '00000000-0000-0000-0000-000000000001',
  appMetadata: {},
  userMetadata: {
    'full_name': 'Test User',
    'phone': '0123456789',
  },
  aud: 'authenticated',
  createdAt: DateTime.now().toIso8601String(),
);

/// Mock Session
final mockSession = Session(
  accessToken: 'mock-access-token-for-development',
  tokenType: 'bearer',
  user: mockUser,
);

/// Mock Auth State - Luôn trả về trạng thái đã đăng nhập
final mockAuthStateProvider = StreamProvider<AuthState>((ref) {
  return Stream.value(
    AuthState(
      AuthChangeEvent.signedIn,
      mockSession,
    ),
  );
});

/// Mock Current User - Luôn trả về mock user
final mockCurrentUserProvider = Provider<User?>((ref) {
  return mockUser;
});

/// Mock User Profile - Trả về profile đầy đủ với roles và loyalty points
final mockUserProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 300));
  
  return {
    'id': mockUser.id,
    'full_name': 'Test User',
    'phone': '0123456789',
    'avatar_url': 'https://i.pravatar.cc/150?img=12',
    'scent_preferences': {
      'favorite_notes': ['Rose', 'Vanilla', 'Sandalwood'],
      'intensity': 'medium',
    },
    'budget_range': {
      'min': 500000,
      'max': 2000000,
    },
    'style_preferences': ['Elegant', 'Fresh', 'Romantic'],
    'account_status': 'active',
    'last_consulted_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    'created_at': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    
    // Relations
    'roles': ['customer'],
    'loyalty_points': 1250,
  };
});

// Note: MockAuthNotifier will be defined in auth_provider.dart as it extends AuthNotifier
