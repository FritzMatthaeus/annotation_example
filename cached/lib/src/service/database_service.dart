import 'package:cached/cached.dart';

class CachedModelManager<
  T extends CachedModel,
  K extends CachedGeneratedModel<T>
> {
  final Store store;

  const CachedModelManager(this.store);

  Stream<List<T>> get items => store
      .box<K>()
      .query()
      .build()
      .stream()
      .map((e) => e.toModel())
      .toList()
      .asStream()
      .asBroadcastStream();

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

  CachedModelManager<T, K>
  getManager<T extends CachedModel, K extends CachedGeneratedModel<T>>() {
    // Use the runtime type of the manager as key
    final managerType = CachedModelManager<T, K>;

    // Check if manager already exists
    final existingManager = _managers[managerType];
    if (existingManager != null) {
      return existingManager as CachedModelManager<T, K>;
    }

    // Create and store new manager
    final newManager = CachedModelManager<T, K>(store);
    _managers[managerType] = newManager;
    return newManager;
  }

  // Optional: Method to check if manager exists
  bool hasManager<T extends CachedModel, K extends CachedGeneratedModel<T>>() {
    return _managers.containsKey(CachedModelManager<T, K>);
  }

  static Future<DatabaseService> create({
    required Store Function() getStore,
  }) async {
    return DatabaseService._(getStore());
  }
}
