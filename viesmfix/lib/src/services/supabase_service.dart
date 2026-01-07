import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/environment.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;

  SupabaseService._internal();

  static SupabaseService get instance {
    _instance ??= SupabaseService._internal();
    return _instance!;
  }

  SupabaseClient get client => _client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    instance._client = Supabase.instance.client;
  }

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Sign in with OAuth provider
  Future<bool> signInWithOAuth({required OAuthProvider provider}) async {
    return await _client.auth.signInWithOAuth(
      provider,
      redirectTo: 'app://login-callback',
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Update user data
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.updateUser(
      UserAttributes(email: email, password: password, data: data),
    );
  }

  // Watchlist operations
  Future<List<Map<String, dynamic>>> getWatchlist(String userId) async {
    return await _client
        .from('watchlist_items')
        .select('*, movies(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  Future<void> addToWatchlist({
    required String userId,
    required int movieId,
    required Map<String, dynamic> movieData,
  }) async {
    // First, ensure movie exists in movies table
    final existingMovie = await _client
        .from('movies')
        .select('id')
        .eq('id', movieId)
        .maybeSingle();

    if (existingMovie == null) {
      // Insert movie data first
      await _client.from('movies').insert(movieData);
    }

    // Add to watchlist
    await _client.from('watchlist_items').insert({
      'user_id': userId,
      'movie_id': movieId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFromWatchlist({
    required String userId,
    required int movieId,
  }) async {
    await _client
        .from('watchlist_items')
        .delete()
        .eq('user_id', userId)
        .eq('movie_id', movieId);
  }

  Future<bool> isInWatchlist({
    required String userId,
    required int movieId,
  }) async {
    final result = await _client
        .from('watchlist_items')
        .select('id')
        .eq('user_id', userId)
        .eq('movie_id', movieId)
        .maybeSingle();

    return result != null;
  }

  // Real-time watchlist subscription
  RealtimeChannel subscribeToWatchlist(
    String userId,
    Function(dynamic) callback,
  ) {
    return _client
        .channel('watchlist:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'watchlist_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: callback,
        )
        .subscribe();
  }

  // Profile operations
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    return await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  Future<void> updateProfile({
    required String userId,
    String? username,
    String? avatarUrl,
    String? bio,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Rating operations
  Future<void> rateMovie({
    required String userId,
    required int movieId,
    required double rating,
  }) async {
    await _client.from('ratings').upsert({
      'user_id': userId,
      'movie_id': movieId,
      'rating': rating,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<double?> getUserRating({
    required String userId,
    required int movieId,
  }) async {
    final result = await _client
        .from('ratings')
        .select('rating')
        .eq('user_id', userId)
        .eq('movie_id', movieId)
        .maybeSingle();

    return result?['rating'];
  }

  Future<double> getAverageRating(int movieId) async {
    final result = await _client.rpc(
      'get_average_rating',
      params: {'movie_id_param': movieId},
    );

    return result ?? 0.0;
  }
}
