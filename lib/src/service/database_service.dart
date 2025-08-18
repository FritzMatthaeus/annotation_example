import 'package:cached/cached.dart';

class CachedModelManager<
  T extends CachedModel,
  K extends CachedGeneratedModel<T>
> {
  final Store store;

  const CachedModelManager(this.store);

  T? getByDatabaseId(int? id) =>
      id == 0 ? null : store.box<K>().get(id!)?.toModel();

  T? getById(String id, QueryStringProperty<K> p) {
    final query = store.box<K>().query(p.equals(id)).build();
    final item = query.findFirst()?.toModel();
    query.close();
    return item;
  }

  int put(K item) {
    return store.box<K>().put(item);
  }

  List<int> putMany(List<K> items) {
    return store.box<K>().putMany(items);
  }

  void remove(K item) {
    item.remove(store);
  }

  void removeAll() {
    store.box<K>().removeAll();
  }
}

class DatabaseService {
  final Store store;
  // Type-safe storage using runtimeType as key
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
