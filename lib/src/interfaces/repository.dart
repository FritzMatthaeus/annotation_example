import 'package:annotation_example/src/src.dart';

abstract class CachedRepository<T> extends Repository {
  StorageService get storageService;
}

abstract class Repository<T extends CachedModel> {
  void dispose();
}
