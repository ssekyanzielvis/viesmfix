/// Interface definitions for data sources

/// Base interface for remote data sources
abstract class RemoteDataSource {
  Future<void> initialize();
  Future<void> dispose();
}

/// Base interface for local data sources
abstract class LocalDataSource {
  Future<void> initialize();
  Future<void> clearCache();
  Future<void> dispose();
}

/// Interface for caching operations
abstract class CacheDataSource {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value, {Duration? ttl});
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> has(String key);
  Future<bool> isExpired(String key);
}
