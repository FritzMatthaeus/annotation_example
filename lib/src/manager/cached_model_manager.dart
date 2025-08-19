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

  void removeAll(K item) {
    item.removeAll(store);
  }

  void removeMany(List<K> items) {
    for (final item in items) {
      item.remove(store);
    }
  }
}
