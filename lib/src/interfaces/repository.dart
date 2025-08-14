import 'package:annotation_example/src/src.dart';

abstract interface class CachedRepository<T extends CachedModel>
    extends Repository {
  StorageService get storageService;
  Future<void> delete(String key);
  Future<T?> get(String key);
  Future<void> post(T model);
  Future<void> update(T model);
}

base class CachedRepositoryBase<T extends CachedModel>
    implements CachedRepository<T> {
  @override
  final StorageService<T> storageService;

  CachedRepositoryBase({required this.storageService});

  @override
  Future<void> delete(String key) => storageService.delete(key);

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future<T?> get(String key) => storageService.get(key);

  @override
  Future<void> post(T model) => storageService.save(model.id, model);

  @override
  Future<void> update(T model) => storageService.save(model.id, model);
}

abstract interface class Repository<T extends CachedModel> {
  void dispose();
}
