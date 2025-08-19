import 'package:cached/cached.dart';

class DatabaseService {
  final Store store;

  final Map<Type, CachedModelManager> _managers = {};

  DatabaseService._(this.store);

  void clearManagers() {
    _managers.clear();
  }

  T getManager<
    T extends CachedModelManager<CachedModel, CachedGeneratedModel<CachedModel>>
  >() {
    // Check if manager already exists
    final manager = _managers[T] as T?;
    if (manager == null) {
      throw CachedModelManagerException(
        'Manager for type ${T.runtimeType} not found',
        StackTrace.current,
      );
    }
    return manager;
  }

  // Optional: Method to check if manager exists
  bool hasManager<T extends CachedModel, K extends CachedGeneratedModel<T>>() {
    return _managers.containsKey(CachedModelManager<T, K>);
  }

  void registerManagerFactory<
    T extends CachedModelManager<CachedModel, CachedGeneratedModel<CachedModel>>
  >(T Function(Store store) factory) {
    _managers[T] = factory(store);
  }

  static Future<DatabaseService> create({
    required Store Function() getStore,
  }) async {
    return DatabaseService._(getStore());
  }
}
