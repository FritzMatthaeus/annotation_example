import 'package:annotation_example/src/src.dart';

abstract class Repository<T extends Model> {
  StorageService<T> get storageService;
  void dispose();
}
