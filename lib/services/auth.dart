import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Stream untuk mendengarkan perubahan auth state
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Register dengan email & password
  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  // Login dengan email & password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Check apakah user sudah login
  bool isLoggedIn() {
    return _supabase.auth.currentUser != null;
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      // Return null if user profile not found
      return null;
    }
  }

  // Ambil profil user yang sedang login
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      return await getUserProfile(userId);
    } catch (e) {
      // Return null if error getting current user profile
      return null;
    }
  }

  // Update profil user
  Future<UserModel> updateUserProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? bio,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (bio != null) updates['bio'] = bio;

      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal update profil: $e');
    }
  }

  // Stream user profile (real-time)
  Stream<UserModel?> getUserProfileStream(String userId) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) {
          if (data.isEmpty) return null;
          return UserModel.fromJson(data.first);
        });
  }
}
