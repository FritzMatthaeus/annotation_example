import 'package:annotation_example/src/src.dart';

abstract interface class CachedModel extends Model {
  Future<void> delete(CachedModel m, StorageService st);
  Future<CachedModel?> get(CachedModel m, StorageService st);
}

abstract interface class Model {
  String get id;
}
