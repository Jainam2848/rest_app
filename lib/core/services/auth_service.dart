import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Email/Password Sign Up
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      print('🔵 Starting signup for: $email');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
          'role': role.name,
        },
      );

      if (response.user == null) {
        throw Exception('Failed to create user');
      }

      print('✅ Auth user created: ${response.user!.id}');
      print('📧 Email confirmed: ${response.user!.emailConfirmedAt != null}');
      print('🔐 Session exists: ${response.session != null}');
      print('👤 Current auth.uid: ${_supabase.auth.currentUser?.id}');

      // Wait for trigger to create profile (DO NOT insert from client)
      return await _waitForProfile(response.user!.id);
    } catch (e) {
      print('❌ Signup error: $e');
      throw Exception('Sign up failed: $e');
    }
  }

  // Email/Password Sign In
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed');
      }

      return await _getUserProfile(response.user!.id);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Phone OTP Sign In
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );
    } catch (e) {
      throw Exception('Phone sign in failed: $e');
    }
  }

  // Verify OTP
  Future<AppUser> verifyOTP({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: token,
      );

      if (response.user == null) {
        throw Exception('OTP verification failed');
      }

      // Wait for trigger to create profile (DO NOT insert from client)
      // The trigger will create the profile based on auth.users data
      return await _waitForProfile(response.user!.id);
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // Google Sign In
  Future<AppUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user == null) {
        throw Exception('Google sign in failed');
      }

      // Wait for trigger to create profile (DO NOT insert from client)
      // For existing users, profile will be found immediately
      // For new users, trigger will create it from auth.users
      return await _waitForProfile(response.user!.id);
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Apple Sign In
  Future<AppUser> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
      );

      if (response.user == null) {
        throw Exception('Apple sign in failed');
      }

      // Wait for trigger to create profile (DO NOT insert from client)
      // For existing users, profile will be found immediately
      // For new users, trigger will create it from auth.users
      return await _waitForProfile(response.user!.id);
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Get user profile from database
  Future<AppUser> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return AppUser.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Wait for profile to be created by trigger (with retry logic)
  Future<AppUser> _waitForProfile(String userId, {int maxRetries = 10}) async {
    // Give trigger initial time to execute (1 second)
    await Future.delayed(Duration(milliseconds: 1000));
    
    for (int i = 0; i < maxRetries; i++) {
      try {
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (response != null) {
          print('✅ Profile found after ${i + 1} attempts');
          return AppUser.fromJson(response);
        }

        print('⏳ Retry ${i + 1}/$maxRetries - Profile not found yet, waiting...');
        
        // Wait between retries: 500ms each time
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        print('⚠️ Retry ${i + 1} error: $e');
        if (i == maxRetries - 1) {
          throw Exception('Profile not created by trigger after $maxRetries retries: $e');
        }
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
    throw Exception('Profile creation timeout - Check Supabase logs and verify trigger exists');
  }

  // Update user profile
  Future<AppUser> updateProfile({
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (displayName != null) updates['display_name'] = displayName;
      if (photoUrl != null) updates['photo_url'] = photoUrl;
      if (metadata != null) updates['metadata'] = metadata;

      await _supabase.from('users').update(updates).eq('id', userId);

      return await _getUserProfile(userId);
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  // Get current user profile
  Future<AppUser?> getCurrentUserProfile() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return null;
      return await _getUserProfile(userId);
    } catch (e) {
      return null;
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _supabase.from('users').update({
        'role': role.name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Role update failed: $e');
    }
  }
}
