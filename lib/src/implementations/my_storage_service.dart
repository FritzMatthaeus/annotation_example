import 'package:annotation_example/src/src.dart';

class MyStorageService implements StorageService<User> {
  const MyStorageService();

  @override
  Future<void> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String key) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<User?> get(String key) async {
    return User(
      name: "Fritz",
      id: key,
      info: Info(lastName: 'Matthäus', firstName: 'Fritz'),
    );
  }

  @override
  Future<void> save(String key, value) {
    // TODO: implement save
    throw UnimplementedError();
  }
}
