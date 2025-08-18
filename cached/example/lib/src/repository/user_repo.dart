import 'package:cached/cached.dart';

class UserRepo<T extends CachedModel, K extends CachedGeneratedModel<T>> {
  final CachedModelManager<T, K> manager;

  const UserRepo(this.manager);

  T? getByDatabaseId(int? id) => manager.getByDatabaseId(id);
}
