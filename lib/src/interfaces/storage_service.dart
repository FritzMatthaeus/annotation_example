abstract class StorageService<T> {
  Future<void> clear();
  Future<void> delete(String key);
  Future<T?> get(String key);
  Future<void> save(String key, T value);
}
