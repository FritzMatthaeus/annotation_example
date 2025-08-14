import 'package:annotation_example/src/src.dart';

abstract interface class Api<T extends CachedModel> {
  Future<void> delete(T model);
  Future<void> get(T model);
  Future<void> save(T model);
  Future<void> update(T model);
}
