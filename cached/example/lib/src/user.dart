import 'package:cached/cached.dart';
import 'package:example/src/info.dart';

@Cached()
class User extends CachedModel {
  @embedded()
  final Info info;

  final String? name;

  User({required super.id, required this.info, this.name, super.databaseId});

  @override
  String toString() =>
      "User(name: $name, id: $id, info: $info, ${super.toString()})";
}

@Cached()
class UserWithInfos extends CachedModel {
  @embedded()
  final List<Info> infos;

  final String? name;

  UserWithInfos({
    required super.id,
    required this.infos,
    this.name,
    super.databaseId,
  });

  @override
  String toString() =>
      "User(name: $name, id: $id, info: $infos, ${super.toString()})";
}
